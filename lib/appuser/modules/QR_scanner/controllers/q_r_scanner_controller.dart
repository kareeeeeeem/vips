import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerController extends GetxController
    with GetTickerProviderStateMixin {
  late MobileScannerController scannerController;
  final isFlashOn = false.obs;
  final scannedCode = ''.obs;
  final isScanning = true.obs;

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

  void _handleScannedCode(String code) {
    isScanning.value = false;
    scannerController.stop();

    Get.snackbar(
      'QR Code Scanned',
      code,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.back(result: code);
    });
  }

  void pickImageFromGallery() {
    Get.snackbar(
      'Gallery',
      'Pick image from gallery to scan QR code',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 16.r,
    );
  }

  void showMyQRCode() {
    Get.back();
    // Navigate to VIPsID or show QR dialog
    Get.snackbar(
      'My QR Code',
      'Showing your QR code',
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 16.r,
    );
  }

  @override
  void onClose() {
    scanLineController.dispose();
    pulseController.dispose();
    scannerController.dispose();
    super.onClose();
  }
}
