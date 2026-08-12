import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../routes/merchant_routes.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantGiftBackController extends GetxController {
  // --- Step 1: Form ---
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final messageController = TextEditingController();

  // Reactive states
  final isFormValid = false.obs;
  final isSending = false.obs;

  // --- Step 2: PIN ---
  final pinCode = ''.obs;
  final isBiometricTab = false.obs;
  final rememberMe = false.obs;

  // --- Step 3: Status ---
  final statusLabel = 'Pending'.obs;
  final resolvedUserId = ''.obs;

  // --- Limits (from API) ---
  final currency = 'D'.obs;
  final dailyLimit = 1000.0.obs;
  final remainingDailyLimit = 1000.0.obs;
  final monthlyLimit = 10000.0.obs;
  final remainingMonthlyLimit = 10000.0.obs;
  final txMin = 1.0.obs;
  final txMax = 1000.0.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_validateForm);
    amountController.addListener(_validateForm);
    _loadLimits();
  }

  Future<void> _loadLimits() async {
    try {
      final response = await ApiService().get('/merchant/gift-back/limits');
      if (response.success && response.data != null) {
        final d = response.data as Map<String, dynamic>;
        currency.value = (d['currency'] ?? 'D').toString();
        dailyLimit.value = (d['dailyLimit'] ?? 0).toDouble();
        remainingDailyLimit.value = (d['remainingDailyLimit'] ?? 0).toDouble();
        monthlyLimit.value = (d['monthlyLimit'] ?? 0).toDouble();
        remainingMonthlyLimit.value = (d['remainingMonthlyLimit'] ?? 0).toDouble();
        txMin.value = (d['txMin'] ?? 0).toDouble();
        txMax.value = (d['txMax'] ?? 0).toDouble();
      }
    } catch (_) {}
  }

  void _validateForm() {
    isFormValid.value =
        phoneController.text.isNotEmpty && amountController.text.isNotEmpty;
  }

  void onScanQR() {
    Get.toNamed(MerchantRoutes.GIFT_BACK_SCAN_ME);
  }

  void onProceedToInquiry() {
    Get.toNamed(MerchantRoutes.GIFT_BACK_INQUIRY);
  }

  void onProceedToPin() {
    Get.toNamed(MerchantRoutes.GIFT_BACK_PIN);
  }

  Future<void> onAcceptRequest() async {
    isSending.value = true;
    try {
      final amount = double.tryParse(amountController.text) ?? 0;
      final response = await ApiService().post('/merchant/gift-back', {
        'userId': resolvedUserId.value,
        'amount': amount,
        'message': messageController.text.isNotEmpty
            ? messageController.text
            : 'Gift back from merchant',
      });

      if (response.success) {
        Get.toNamed(MerchantRoutes.GIFT_BACK_STATUS);
        statusLabel.value = 'Successful';
        safeSnackbar('Success', 'Gift back sent successfully!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        statusLabel.value = 'Failed';
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      statusLabel.value = 'Failed';
      safeSnackbar('Error', 'Failed to send gift back: $e');
    } finally {
      isSending.value = false;
    }
  }

  void updatePin(String digit) {
    if (pinCode.value.length < 4) {
      pinCode.value += digit;
    }

    if (pinCode.value.length == 4) {
      onAcceptRequest();
    }
  }

  void clearPin() {
    if (pinCode.value.isNotEmpty) {
      pinCode.value = pinCode.value.substring(0, pinCode.value.length - 1);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
