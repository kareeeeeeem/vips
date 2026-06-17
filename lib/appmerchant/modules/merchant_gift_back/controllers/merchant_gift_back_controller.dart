import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/merchant_routes.dart';

class MerchantGiftBackController extends GetxController {
  // --- Step 1: Form ---
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  
  // Reactive states for validation
  final isFormValid = false.obs;
  
  // --- Step 2: PIN ---
  final pinCode = ''.obs;
  final isBiometricTab = false.obs;
  final rememberMe = false.obs;

  // --- Step 3: Status ---
  final statusLabel = 'Pending'.obs;

  @override
  void onInit() {
    super.onInit();
    // Simple validation listener
    phoneController.addListener(_validateForm);
    amountController.addListener(_validateForm);
  }

  void _validateForm() {
    isFormValid.value = phoneController.text.isNotEmpty && amountController.text.isNotEmpty;
  }

  // --- Logic ---
  
  void onScanQR() {
    Get.toNamed(MerchantRoutes.GIFT_BACK_SCAN_ME);
  }

  void onProceedToInquiry() {
    // Navigate to step 2
    Get.toNamed(MerchantRoutes.GIFT_BACK_INQUIRY);
  }

  void onProceedToPin() {
    // Navigate to step 3
    Get.toNamed(MerchantRoutes.GIFT_BACK_PIN);
  }

  void onAcceptRequest() {
    // Move to step 4 (Status)
    Get.toNamed(MerchantRoutes.GIFT_BACK_STATUS);
    
    // Simulate a delay then change status to success
    Future.delayed(const Duration(seconds: 2), () {
      statusLabel.value = 'Successful';
    });
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
    super.onClose();
  }
}
