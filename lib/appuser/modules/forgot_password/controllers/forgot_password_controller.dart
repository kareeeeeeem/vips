import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();

  final RxBool isEmailValid = false.obs;
  final RxBool isSending = false.obs;

  // Store the email used so reset-password screen can use it
  String get submittedEmail => emailController.text.trim();

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = emailController.text;
    isEmailValid.value = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  Future<void> sendResetCode() async {
    if (!isEmailValid.value) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSending.value = true;

    try {
      final response = await ApiService().post('/auth/forgot-password', {
        'email': emailController.text.trim(),
      });

      if (response.success) {
        // Navigate to reset password screen, passing the email
        Get.toNamed(
          '/reset-password',
          arguments: {'email': emailController.text.trim()},
        );

        Get.snackbar(
          'Code Sent',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSending.value = false;
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
