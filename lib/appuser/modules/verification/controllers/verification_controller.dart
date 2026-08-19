import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class VerificationController extends GetxController {
  final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final RxString email = ''.obs;
  final RxBool isVerifying = false.obs;
  final RxInt resendTimer = 60.obs;
  // Login's second factor — the OTP was already sent by POST /auth/login
  // itself (it doubles as the 2FA challenge trigger), so this screen
  // just needs to know to call /auth/2fa/verify instead of /auth/verify-otp
  // and finish like a normal login on success.
  bool isLogin2FA = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] != null) {
      email.value = args['email'].toString();
    }
    if (args is Map && args['isLogin2FA'] == true) {
      isLogin2FA = true;
    }
    startResendTimer();
  }

  void startResendTimer() {
    resendTimer.value = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendTimer.value > 0) {
        resendTimer.value--;
        return true;
      }
      return false;
    });
  }

  Future<void> verifyCode(String code, bool fromReset) async {
    isVerifying.value = true;
    try {
      final response = await ApiService().post(
        isLogin2FA ? '/auth/2fa/verify' : '/auth/verify-otp',
        {'email': email.value, 'otp': code},
      );
      isVerifying.value = false;
      if (response.success) {
        if (isLogin2FA) {
          final data = response.data;
          final token = data is Map ? data['token'] as String? : null;
          final userData = data is Map ? data['user'] : null;
          if (token != null && token.isNotEmpty) {
            await ApiService().setToken(token);
            final hasPin = userData is Map && userData['hasPin'] == true;
            Get.offAllNamed(hasPin ? '/main-app' : '/createpin');
          } else {
            safeSnackbar('Error', 'Could not complete sign-in. Please try again.',
                backgroundColor: Colors.red.withValues(alpha: 0.1), colorText: Colors.red,
                snackPosition: SnackPosition.BOTTOM);
          }
        } else if (fromReset) {
          Get.offAllNamed('/reset-password', arguments: {'email': email.value, 'otp': code});
        } else {
          Get.offAllNamed('/createpin');
        }
      } else {
        safeSnackbar(
          'Invalid Code',
          response.message,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      isVerifying.value = false;
      safeSnackbar(
        'Error',
        'Failed to verify code. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resendCode() async {
    if (resendTimer.value > 0) return;

    try {
      final response = await ApiService().post(
        '/auth/forgot-password',
        {'email': email.value},
      );
      if (response.success) {
        safeSnackbar(
          'Code Sent',
          'Code sent to ${email.value}',
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        safeSnackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        'Failed to resend code. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    startResendTimer();
  }

  void goBack() {
    Get.back();
  }

  // Only reachable from the post-signup path (fromReset: false) — email
  // delivery isn't guaranteed to be configured yet (needs SENDGRID_API_KEY),
  // so verification can't be a hard gate on using the app. The account can
  // still be verified later from Settings.
  void skipVerification() {
    Get.offAllNamed('/createpin');
  }

  @override
  void onClose() {
    pinController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
