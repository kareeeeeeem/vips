import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ResetPasswordController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isPasswordConfirmed = false.obs;
  final RxBool isResetting = false.obs;

  // Email passed from forgot-password screen
  late String email;

  @override
  void onInit() {
    super.onInit();

    // Get email (and OTP, already verified on the previous screen) from
    // navigation arguments so the user isn't forced to retype the code.
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    final otp = args?['otp'];
    if (otp != null) {
      otpController.text = otp.toString();
    }

    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validatePassword() {
    final password = passwordController.text;

    // At least 8 chars, 1 uppercase, 1 number
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    isPasswordValid.value = hasMinLength && hasUppercase && hasNumber;

    if (confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    isPasswordConfirmed.value =
        passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> resetPassword() async {
    if (!isPasswordValid.value || !isPasswordConfirmed.value) {
      safeSnackbar(
        'Validation Error',
        'Please ensure your password meets the requirements and matches.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      safeSnackbar(
        'Error',
        'Please enter the 6-digit code sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isResetting.value = true;

    try {
      final response = await ApiService().post('/auth/reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': passwordController.text,
      });

      if (response.success) {
        // If backend returns a new token, save it
        if (response.data != null && response.data['token'] != null) {
          await ApiService().setToken(response.data['token']);
          Get.offAllNamed('/main-app');
        } else {
          // Otherwise just go to login
          Get.offAllNamed('/login');
        }

        safeSnackbar(
          'Success',
          'Password reset successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        safeSnackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isResetting.value = false;
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
