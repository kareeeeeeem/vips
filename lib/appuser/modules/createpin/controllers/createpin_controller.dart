import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class CreatepinController extends GetxController {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  final FocusNode pinFocusNode = FocusNode();
  final FocusNode confirmPinFocusNode = FocusNode();

  final RxBool isConfirmStep = false.obs;
  final RxBool isCreating = false.obs;
  final RxString firstPin = ''.obs;
  final RxBool hasError = false.obs;

  void onPinCompleted(String pin) {
    if (!isConfirmStep.value) {
      // Première étape - enregistrer le PIN
      firstPin.value = pin;
      isConfirmStep.value = true;

      // Délai pour l'animation puis focus sur la confirmation
      Future.delayed(const Duration(milliseconds: 300), () {
        confirmPinFocusNode.requestFocus();
      });
    } else {
      // Deuxième étape - vérifier la correspondance
      if (pin == firstPin.value) {
        createPin(pin);
      } else {
        // Erreur - les PINs ne correspondent pas
        hasError.value = true;
        confirmPinController.clear();

        // Vibration ou feedback
        Future.delayed(const Duration(milliseconds: 500), () {
          hasError.value = false;
        });
      }
    }
  }

  Future<void> createPin(String pin) async {
    isCreating.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', pin);
      Get.offAllNamed('/success-account');
    } catch (e) {
      safeSnackbar('Error', 'Failed to save PIN. Please try again.');
    } finally {
      isCreating.value = false;
    }
  }

  void goBack() {
    if (isConfirmStep.value) {
      // Retour à la première étape
      isConfirmStep.value = false;
      firstPin.value = '';
      pinController.clear();
      confirmPinController.clear();
      hasError.value = false;

      Future.delayed(const Duration(milliseconds: 100), () {
        pinFocusNode.requestFocus();
      });
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    confirmPinController.dispose();
    pinFocusNode.dispose();
    confirmPinFocusNode.dispose();
    super.onClose();
  }
}
