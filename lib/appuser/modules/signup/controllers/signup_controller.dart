import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/services/auth_service.dart';

class SignupController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

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
    debugPrint('[SIGNUP] createAccount() started');

    try {
      debugPrint('[SIGNUP] POST /auth/register...');
      final response = await ApiService().post('/auth/register', {
        'fullName': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });
      debugPrint('[SIGNUP] createAccount() response received, success=${response.success}');

      final token =
          response.data is Map ? response.data['token'] as String? : null;
      if (response.success && token != null && token.isNotEmpty) {
        await ApiService().setToken(token);
        // A fresh email/password account can't have its email verified by
        // a third party the way social sign-in can — send them through the
        // real verify → PIN → welcome flow instead of straight into the app.
        Get.offAllNamed('/verification', arguments: {'email': emailController.text.trim()});
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
      debugPrint('[SIGNUP] createAccount() threw: $e');
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

  Future<void> signUpWithGoogle() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[SIGNUP] signUpWithGoogle() started');
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        debugPrint('[SIGNUP] signUpWithGoogle() canceled by user');
        return;
      }
      debugPrint('[SIGNUP] Google auth done, exchanging with backend...');
      await _signUpWithBackend(userCredential.user, 'google');
      debugPrint('[SIGNUP] signUpWithGoogle() finished');
    } catch (e) {
      debugPrint('[SIGNUP] signUpWithGoogle() threw: $e');
      _handleSignUpError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithFacebook() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[SIGNUP] signUpWithFacebook() started');
    try {
      final userCredential = await _authService.signInWithFacebook();
      if (userCredential == null) {
        debugPrint('[SIGNUP] signUpWithFacebook() canceled by user');
        return;
      }
      debugPrint('[SIGNUP] Facebook auth done, exchanging with backend...');
      await _signUpWithBackend(userCredential.user, 'facebook');
      debugPrint('[SIGNUP] signUpWithFacebook() finished');
    } catch (e) {
      debugPrint('[SIGNUP] signUpWithFacebook() threw: $e');
      _handleSignUpError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Exchange Firebase social credentials for a VIPs JWT token, mirroring
  // LoginController._loginWithBackend's pattern.
  Future<void> _signUpWithBackend(User? firebaseUser, String provider) async {
    try {
      debugPrint('[SIGNUP] _signUpWithBackend: getting Firebase ID token...');
      final idToken = await firebaseUser?.getIdToken();
      debugPrint('[SIGNUP] _signUpWithBackend: POST /auth/social (provider=$provider)...');
      final response = await ApiService().post('/auth/social', {
        'idToken' : idToken,
        'provider': provider,
      });
      debugPrint('[SIGNUP] _signUpWithBackend: response received, success=${response.success}');
      final token = response.data is Map ? response.data['token'] as String? : null;
      if (response.success && token != null && token.isNotEmpty) {
        await ApiService().setToken(token);
        // Firebase already verified this email to issue the token, so
        // there's no OTP step needed here — but a brand new social account
        // still needs a PIN, same as an email/password one.
        final userData = response.data is Map ? response.data['user'] : null;
        final hasPin = userData is Map && userData['hasPin'] == true;
        Get.offAllNamed(hasPin ? '/main-app' : '/createpin');
      } else {
        await _authService.signOut();
        _handleSignUpError(response.message.isNotEmpty
            ? response.message
            : 'Could not complete sign-up. Please try again.');
      }
    } catch (e) {
      debugPrint('[SIGNUP] _signUpWithBackend threw: $e');
      await _authService.signOut();
      _handleSignUpError('Could not complete sign-up. Please try again.');
    }
  }

  void _handleSignUpError(String message) {
    Get.defaultDialog(
      title: 'Error',
      middleText: message,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () => Get.back(),
    );
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
