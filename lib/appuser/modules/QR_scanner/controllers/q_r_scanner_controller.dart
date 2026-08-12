import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class QRScannerController extends GetxController
    with GetTickerProviderStateMixin {
  late MobileScannerController scannerController;
  final isFlashOn = false.obs;
  final scannedCode = ''.obs;
  final isScanning = true.obs;
  final isValidating = false.obs;

  late AnimationController scanLineController;
  late Animation<double> scanLineAnimation;

  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  @override
  void onInit() {
    super.onInit();

    // Initialiser le scanner
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // Animation de la ligne de scan
    scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: scanLineController, curve: Curves.easeInOut),
    );

    // Animation de pulsation pour les coins
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  void toggleFlash() async {
    isFlashOn.value = !isFlashOn.value;
    await scannerController.toggleTorch();
  }

  void handleBarcode(BarcodeCapture barcodeCapture) {
    if (isScanning.value && barcodeCapture.barcodes.isNotEmpty) {
      final barcode = barcodeCapture.barcodes.first;
      final code = barcode.rawValue ?? '';

      if (code.isNotEmpty) {
        scannedCode.value = code;
        _handleScannedCode(code);
      }
    }
  }

  Future<void> _handleScannedCode(String code) async {
    isScanning.value = false;
    isValidating.value = true;
    scannerController.stop();

    try {
      final response = await ApiService().post('/rewards/validate-qr', {'code': code});
      if (response.success) {
        final type = response.data?['type'] ?? 'unknown';
        String message = response.message;

        if (type == 'gift') {
          message = 'Gift redeemed! ${response.data?['amount']} added to wallet';
        } else if (type == 'merchant') {
          message = 'Merchant: ${response.data?['merchant']?['name'] ?? code}';
        } else if (type == 'coupon') {
          message = 'Coupon valid: ${response.data?['coupon']?['code'] ?? code}';
        }

        safeSnackbar(
          'QR Validated',
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
          borderRadius: 16.r,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        Future.delayed(const Duration(milliseconds: 2000), () => Get.back(result: response.data));
      } else {
        safeSnackbar('Invalid QR', response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(16.w),
          borderRadius: 16.r,
        );
        Future.delayed(const Duration(milliseconds: 2000), () {
          isScanning.value = true;
          scannerController.start();
        });
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not validate QR code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
      );
      Future.delayed(const Duration(milliseconds: 2000), () {
        isScanning.value = true;
        scannerController.start();
      });
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      isScanning.value = false;
      scannerController.stop();

      final result = await scannerController.analyzeImage(picked.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final code = result.barcodes.first.rawValue ?? '';
        if (code.isNotEmpty) {
          scannedCode.value = code;
          await _handleScannedCode(code);
          return;
        }
      }
      safeSnackbar('No QR Found', 'No QR code detected in the selected image',
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16.w),
          borderRadius: 16.r);
      isScanning.value = true;
      scannerController.start();
    } catch (_) {
      safeSnackbar('Error', 'Could not read image',
          snackPosition: SnackPosition.BOTTOM);
      isScanning.value = true;
      scannerController.start();
    }
  }

  void showMyQRCode() {
    Get.back();
    Get.toNamed('/vips-id');
  }

  @override
  void onClose() {
    scanLineController.dispose();
    pulseController.dispose();
    scannerController.dispose();
    super.onClose();
  }
}
