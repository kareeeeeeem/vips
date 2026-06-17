import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../verification/views/verification_view.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();

  final RxBool isEmailValid = false.obs;
  final RxBool isSending = false.obs;

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

  Future<void> sendResetLink() async {
    if (!isEmailValid.value) return;

    isSending.value = true;

    // Simuler l'envoi
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implémenter la logique d'envoi du lien de réinitialisation
    print('Envoi du lien de réinitialisation à: ${emailController.text}');

    isSending.value = false;

    // Afficher un message de succès

    // Retourner à la page de connexion après 2 secondes
    Get.off(
      () => VerificationView(true),
      arguments: {'email': emailController.text},
    );
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
