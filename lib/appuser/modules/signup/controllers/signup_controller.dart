import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

class SignupController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Text Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Animation controllers
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Observable state
  final RxBool isFullNameValid = false.obs;
  final RxBool isPhoneValid = false.obs;
  final RxBool isEmailValid = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isPasswordConfirmed = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

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

    animationController.forward();

    fullNameController.addListener(_validateFullName);
    phoneController.addListener(_validatePhone);
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validatePasswordConfirmation);
  }

  void _validateFullName() {
    isFullNameValid.value = fullNameController.text.trim().length >= 3;
  }

  void _validatePhone() {
    final phone = phoneController.text.trim();
    isPhoneValid.value = RegExp(r'^\+?[0-9]{8,15}$').hasMatch(phone);
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    isEmailValid.value = GetUtils.isEmail(email);
  }

  void _validatePassword() {
    final password = passwordController.text;
    isPasswordValid.value =
        password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));

    _validatePasswordConfirmation();
  }

  void _validatePasswordConfirmation() {
    isPasswordConfirmed.value =
        passwordController.text == confirmPasswordController.text &&
        isPasswordValid.value;
  }

  bool get canSubmit =>
      isFullNameValid.value &&
      isPhoneValid.value &&
      isEmailValid.value &&
      isPasswordConfirmed.value;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> createAccount() async {
    if (!canSubmit) {
      String error = 'Please fill out all fields correctly.';
      if (!isFullNameValid.value) {
        error = 'Please enter a valid full name (min 3 characters).';
      } else if (!isPhoneValid.value) {
        error = 'Please enter a valid phone number.';
      } else if (!isEmailValid.value) {
        error = 'Please enter a valid email address.';
      } else if (!isPasswordValid.value) {
        error = 'Password must be 8+ characters, with uppercase, lowercase, and numbers.';
      } else if (!isPasswordConfirmed.value) {
        error = 'Passwords do not match.';
      }

      Get.defaultDialog(
        title: 'Validation Error',
        middleText: error,
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () => Get.back(),
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService().post('/auth/register', {
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (response.success && response.data != null) {
        final token = response.data['token'];
        await ApiService().setToken(token);
        Get.offAllNamed('/main-app');
      } else {
        Get.defaultDialog(
          title: 'Error',
          middleText: response.message,
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: Colors.redAccent,
          onConfirm: () => Get.back(),
        );
      }
    } catch (e) {
      Get.defaultDialog(
        title: 'Error',
        middleText: e.toString(),
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void signUpWithGoogle() {
    // TODO: Implement Google sign up
  }

  void signUpWithFacebook() {
    // TODO: Implement Facebook sign up
  }

  void navigateToSignIn() {
    Get.offNamed('/login');
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
