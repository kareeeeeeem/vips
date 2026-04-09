import 'package:flutter/material.dart' show TextEditingController;
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isPasswordConfirmed = false.obs;
  final RxBool isResetting = false.obs;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validatePassword() {
    final password = passwordController.text;

    // Au moins 8 caractères, 1 majuscule, 1 chiffre
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    isPasswordValid.value = hasMinLength && hasUppercase && hasNumber;

    // Re-valider la confirmation si elle existe
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
    if (!isPasswordValid.value || !isPasswordConfirmed.value) return;

    isResetting.value = true;

    // Simuler la réinitialisation
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implémenter la logique de réinitialisation du mot de passe
    print('Nouveau mot de passe: ${passwordController.text}');

    isResetting.value = false;

    // Afficher un message de succès

    // Naviguer vers la page de connexion
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/login');
    });
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
