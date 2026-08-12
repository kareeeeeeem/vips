import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantAuthController extends GetxController {
  final phoneController = TextEditingController();
  final pinController = TextEditingController(); // reserved for future use

  final isLoading = false.obs;
  final phoneNumber = ''.obs;

  // ── Send OTP ─────────────────────────────────────────────────
  Future<void> login() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      safeSnackbar('Error', 'Please enter your phone number');
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService().post(
        '/auth/merchant-login',
        {'phone': phone},
      );

      if (response.success) {
        phoneNumber.value = phone;
        Get.toNamed(MerchantRoutes.VERIFICATION);
      } else {
        safeSnackbar('Error', response.message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify OTP & obtain token ─────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    if (otp.length < 4) {
      safeSnackbar('Error', 'Please enter a valid OTP');
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService().post(
        '/auth/merchant-verify-otp',
        {'phone': phoneNumber.value, 'otp': otp},
      );

      if (response.success) {
        final token = response.data?['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await ApiService().setToken(token);
          // Also persist under the 'token' key used by ApiClient / SplashController
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        Get.offAllNamed(MerchantRoutes.HOME);
      } else {
        safeSnackbar('Error', response.message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiService().clearToken();
    Get.offAllNamed(MerchantRoutes.LOGIN);
  }
}
