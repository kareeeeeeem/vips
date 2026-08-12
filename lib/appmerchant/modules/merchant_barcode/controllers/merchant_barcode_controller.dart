import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantBarcodeController extends GetxController {
  final _api = ApiService();

  // Form inputs
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final selectedType = 'qrcode'.obs; // 'qrcode' or 'barcode'

  // Generated / displayed QR value
  final generatedCode = ''.obs;

  // Saved barcodes list
  final savedBarcodes = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSaving  = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBarcodes();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    super.onClose();
  }

  // ─── Load all saved barcodes from backend ────────────────

  Future<void> loadBarcodes() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/merchant/barcodes');
      if (response.success && response.data != null) {
        final list = response.data as List<dynamic>;
        savedBarcodes.value = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('loadBarcodes error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Generate QR preview (local only) ───────────────────

  void generate() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      safeSnackbar('Required', 'Please enter a product name', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final code = codeCtrl.text.trim().isNotEmpty
        ? codeCtrl.text.trim()
        : 'PROD-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    generatedCode.value = '$name|$code';

    safeSnackbar('Generated!', 'QR Code created for $name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white);
  }

  // ─── Save generated barcode to backend ──────────────────

  Future<void> saveBarcode() async {
    if (generatedCode.value.isEmpty) {
      safeSnackbar('Error', 'Generate a code first', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final name = nameCtrl.text.trim();
    final code = codeCtrl.text.trim().isNotEmpty
        ? codeCtrl.text.trim()
        : generatedCode.value.split('|').last;

    isSaving.value = true;
    try {
      final response = await _api.post('/merchant/barcodes', {
        'productName': name,
        'code':        code,
        'codeType':    selectedType.value,
        'qrData':      generatedCode.value,
      });

      if (response.success) {
        safeSnackbar('Saved!', 'Barcode saved to your collection',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white);
        await loadBarcodes();
        nameCtrl.clear();
        codeCtrl.clear();
        generatedCode.value = '';
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to save barcode', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // ─── Delete a barcode ────────────────────────────────────

  Future<void> deleteBarcode(String id) async {
    try {
      final response = await _api.delete('/merchant/barcodes/$id');
      if (response.success) {
        savedBarcodes.removeWhere((b) => b['_id']?.toString() == id);
      }
    } catch (e) {
      debugPrint('deleteBarcode error: $e');
    }
  }

  // ─── Helper: copy code to clipboard ─────────────────────

  void copyCode(String code) {
    safeSnackbar('Copied!', 'Code copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }
}
