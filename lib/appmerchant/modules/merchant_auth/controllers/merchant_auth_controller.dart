import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class MerchantAuthController extends GetxController {
  final phoneController = TextEditingController();
  final pinController = TextEditingController(); // This will be used for OTP as well
  
  final isLoading = false.obs;
  final phoneNumber = "".obs;

  void login() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number');
      return;
    }
    
    phoneNumber.value = phone;
    // Simulate API call to send OTP
    Get.toNamed(MerchantRoutes.VERIFICATION);
  }

  void verifyOtp(String otp) {
    if (otp.length < 4) {
      Get.snackbar('Error', 'Please enter a valid OTP');
      return;
    }
    
    isLoading.value = true;
    // Simulate verification
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      Get.offAllNamed(MerchantRoutes.HOME);
    });
  }

  void logout() {
    Get.offAllNamed(MerchantRoutes.LOGIN);
  }
}
