import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/services/auth_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpPhoneController = TextEditingController();

  // Reactive Variables
  final RxBool _rememberMe = false.obs;
  final RxBool _isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString phoneVerificationId = ''.obs;
  final RxString otpPhoneNumber = ''.obs;

  // Getters
  bool get rememberMe => _rememberMe.value;
  bool get isPasswordVisible => _isPasswordVisible.value;

  // Validation for Email Login
  bool get canEmailLogin =>
      emailController.text.isNotEmpty == true &&
      passwordController.text.isNotEmpty;

  // toggleRememberMe() had no checkbox behind it and _rememberMe was read
  // nowhere — there is no remember-me behaviour in the app.


  void togglePasswordVisibility() {
    _isPasswordVisible.toggle();
  }

  // Email Login Method
  void emailLogin() async {
    if (isLoading.value) return;
    if (!canEmailLogin) {
      safeSnackbar(
        'Validation Error',
        'Please enter a valid email and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    debugPrint('[LOGIN] emailLogin() started');
    try {
      debugPrint('[LOGIN] POST /auth/login (email)...');
      final response = await ApiService().post('/auth/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });
      debugPrint('[LOGIN] emailLogin() response received, success=${response.success}');

      if (response.success && response.data is Map && response.data['requires2FA'] == true) {
        Get.toNamed('/verification', arguments: {'email': response.data['email'], 'isLogin2FA': true});
        return;
      }

      final token =
          response.data is Map ? response.data['token'] as String? : null;
      if (response.success && token != null && token.isNotEmpty) {
        await ApiService().setToken(token);
        final userData = response.data is Map ? response.data['user'] : null;
        _handleSuccessfulLogin(userData is Map ? Map<String, dynamic>.from(userData) : null);
      } else {
        _handleLoginError(response.message);
      }
    } catch (e) {
      debugPrint('[LOGIN] emailLogin() threw: $e');
      _handleLoginError('Could not sign in. Please check your connection and try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Google Login Method
  Future<void> googleLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[LOGIN] googleLogin() started');
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        debugPrint('[LOGIN] googleLogin() canceled by user');
        return;
      }
      debugPrint('[LOGIN] Firebase auth done, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'google');
      debugPrint('[LOGIN] googleLogin() finished');
    } catch (e) {
      debugPrint('[LOGIN] googleLogin() threw: $e');
      _handleLoginError('Could not sign in with Google. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Facebook Login Method
  Future<void> facebookLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[LOGIN] facebookLogin() started');
    try {
      final userCredential = await _authService.signInWithFacebook();
      if (userCredential == null) {
        debugPrint('[LOGIN] facebookLogin() canceled by user');
        return;
      }
      debugPrint('[LOGIN] Facebook auth done, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'facebook');
      debugPrint('[LOGIN] facebookLogin() finished');
    } catch (e) {
      debugPrint('[LOGIN] facebookLogin() threw: $e');
      _handleLoginError('Could not sign in with Facebook. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Apple Login Method
  Future<void> appleLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[LOGIN] appleLogin() started');
    try {
      final userCredential = await _authService.signInWithApple();
      debugPrint('[LOGIN] Apple auth done, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'apple');
      debugPrint('[LOGIN] appleLogin() finished');
    } catch (e) {
      debugPrint('[LOGIN] appleLogin() threw: $e');
      _handleLoginError('Could not sign in with Apple. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to the phone-number entry screen for OTP sign-in
  void navigateToPhoneLogin() {
    Get.toNamed('/phone-login');
  }

  // Phone OTP Login — Step 1: send the code
  Future<void> sendPhoneOtp(String phoneNumber) async {
    if (isLoading.value) return;
    if (phoneNumber.trim().isEmpty) {
      safeSnackbar(
        'Validation Error',
        'Please enter a valid phone number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    debugPrint('[LOGIN] sendPhoneOtp() started for $phoneNumber');
    try {
      final verificationId = await _authService.signInWithPhone(phoneNumber.trim());
      if (verificationId.isEmpty) {
        // Device auto-verified the number — already signed in, no OTP needed.
        debugPrint('[LOGIN] sendPhoneOtp() auto-verified, exchanging with backend...');
        await _loginWithBackend(_authService.getCurrentUser(), 'phone');
        return;
      }
      debugPrint('[LOGIN] sendPhoneOtp() code sent, verificationId len=${verificationId.length}');
      phoneVerificationId.value = verificationId;
      otpPhoneNumber.value = phoneNumber.trim();
      Get.toNamed('/otp-verify');
    } on FirebaseAuthException catch (e) {
      debugPrint('[LOGIN] sendPhoneOtp() FirebaseAuthException: ${e.code} ${e.message}');
      _handleLoginError(_authService.mapFirebaseError(e));
    } catch (e) {
      debugPrint('[LOGIN] sendPhoneOtp() threw: $e');
      _handleLoginError('Could not send the verification code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Phone OTP Login — Step 2: verify the code
  Future<void> verifyPhoneOtp(String smsCode) async {
    if (isLoading.value) return;
    if (phoneVerificationId.value.isEmpty) {
      _handleLoginError('Please request a new OTP code.');
      return;
    }

    isLoading.value = true;
    debugPrint('[LOGIN] verifyPhoneOtp() started');
    try {
      final userCredential = await _authService.verifyPhoneOTP(
        phoneVerificationId.value,
        smsCode,
      );
      debugPrint('[LOGIN] verifyPhoneOtp() Firebase verified, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'phone');
      debugPrint('[LOGIN] verifyPhoneOtp() finished');
    } on FirebaseAuthException catch (e) {
      debugPrint('[LOGIN] verifyPhoneOtp() FirebaseAuthException: ${e.code} ${e.message}');
      _handleLoginError(_authService.mapFirebaseError(e));
    } catch (e) {
      debugPrint('[LOGIN] verifyPhoneOtp() threw: $e');
      _handleLoginError('Could not verify this code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendPhoneOtp() => sendPhoneOtp(otpPhoneNumber.value);

  // Guest Login Method — no auth required, browse as guest
  Future<void> guestLogin() async {
    Get.offAllNamed('/main-app');
  }

  // Exchange Firebase social/phone credentials for a VIPs JWT token
  Future<void> _loginWithBackend(User? firebaseUser, String provider) async {
    try {
      debugPrint('[LOGIN] _loginWithBackend: getting Firebase ID token...');
      final idToken = await firebaseUser?.getIdToken();
      debugPrint('[LOGIN] _loginWithBackend: POST /auth/social (provider=$provider)...');
      final response = await ApiService().post('/auth/social', {
        'idToken' : idToken,
        'provider': provider,
      });
      debugPrint('[LOGIN] _loginWithBackend: response received, success=${response.success}');
      final token = response.data is Map ? response.data['token'] as String? : null;
      if (response.success && token != null && token.isNotEmpty) {
        await ApiService().setToken(token);
        final userData = response.data is Map ? response.data['user'] : null;
        _handleSuccessfulLogin(userData is Map ? Map<String, dynamic>.from(userData) : null);
      } else {
        await _authService.signOut();
        _handleLoginError(response.message.isNotEmpty
            ? response.message
            : 'Could not complete sign-in. Please try again.');
      }
    } catch (e) {
      debugPrint('[LOGIN] _loginWithBackend threw: $e');
      await _authService.signOut();
      _handleLoginError('Could not complete sign-in. Please try again.');
    }
  }

  // Handle Successful Login
  void _handleSuccessfulLogin(Map<String, dynamic>? userData) {
    // Accounts created before the PIN feature existed (or via social
    // sign-in, which can silently create a brand new account) may not
    // have one yet — route them to set one up instead of landing them in
    // the app with a PIN gate they can never pass.
    if (userData != null && userData['hasPin'] != true) {
      Get.offAllNamed('/createpin');
      return;
    }
    Get.offAllNamed('/main-app');
  }

  // Handle Login Errors
  void _handleLoginError(dynamic error) {
    final String errorMessage = error is String
        ? error
        : (error?.toString() ?? 'An unknown error occurred');

    // Backend cold-starts can take up to a minute (see ApiService.baseUrl),
    // so a login attempt can fail after a long silent wait — the default
    // ~3s snackbar was easy to miss, leaving the button-reset as the only
    // visible feedback (looks exactly like "nothing happened"). Longer
    // duration + top position make the failure impossible to miss.
    safeSnackbar(
      'Login Error',
      errorMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  // Forgot Password Method
  void forgotPassword() {
    // Navigate to forgot password screen
    Get.toNamed('/forgot-password');
  }

  // Navigate to Sign Up
  void navigateToSignUp() {
    Get.toNamed('/signup');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    otpPhoneController.dispose();
    super.onClose();
  }
}
