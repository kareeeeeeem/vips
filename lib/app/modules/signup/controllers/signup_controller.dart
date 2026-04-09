import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/verification/views/verification_view.dart';

class SignupController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Contrôleurs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Animation controllers
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Observable pour gérer l'état du formulaire
  final RxBool isEmailValid = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isPasswordConfirmed = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Configuration des animations
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Démarrer l'animation
    animationController.forward();

    // Écouter les changements du formulaire
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validatePasswordConfirmation);
  }

  // Validation de l'email
  void _validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = GetUtils.isEmail(email);
  }

  // Validation du mot de passe
  void _validatePassword() {
    final password = passwordController.text;
    // Critères de validation du mot de passe
    isPasswordValid.value =
        password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));

    // Vérifier la confirmation du mot de passe
    _validatePasswordConfirmation();
  }

  // Validation de la confirmation du mot de passe
  void _validatePasswordConfirmation() {
    isPasswordConfirmed.value =
        passwordController.text == confirmPasswordController.text &&
        isPasswordValid.value;
  }

  // Basculer la visibilité du mot de passe
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Basculer la visibilité de la confirmation du mot de passe
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Méthode pour créer un compte
  void createAccount() {
    Get.off(
      () => VerificationView(false),
      arguments: {'email': emailController.text},
    );
  }

  // Méthodes pour les connexions sociales
  void signUpWithGoogle() {
    // Logique de connexion Google
  }

  void signUpWithFacebook() {
    // Logique de connexion Facebook
  }

  // Aller à l'écran de connexion
  void navigateToSignIn() {
    Get.offNamed('/login');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
