import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationController extends GetxController {
  final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final RxString email = ''.obs;
  final RxBool isVerifying = false.obs;
  final RxInt resendTimer = 60.obs;

  @override
  void onInit() {
    super.onInit();
    email.value = 'your@email.com';
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

    await Future.delayed(const Duration(seconds: 2));

    isVerifying.value = false;
    if (fromReset) {
      Get.offAllNamed('/reset-password');
    } else {
      Get.offAllNamed('/createpin');
    }
  }

  Future<void> resendCode() async {
    if (resendTimer.value > 0) return;

    // TODO: Implémenter la logique de renvoi

    startResendTimer();
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    pinController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
