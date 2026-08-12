import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends GetxController {
  // Text Controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive Variables
  final RxBool _rememberMe = false.obs;
  final RxBool _isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  // Getters
  bool get rememberMe => _rememberMe.value;
  bool get isPasswordVisible => _isPasswordVisible.value;

  // Validation for Phone Login
  bool get canLogin =>
      phoneController.text.isNotEmpty && passwordController.text.isNotEmpty;

  // Validation for Email Login
  bool get canEmailLogin =>
      emailController.text.isNotEmpty == true &&
      passwordController.text.isNotEmpty;

  // Toggle Methods
  void toggleRememberMe() {
    _rememberMe.toggle();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.toggle();
  }

  // Phone Login Method
  void login() async {
    if (isLoading.value) return;
    if (!canLogin) {
      safeSnackbar(
        'Validation Error',
        'Please enter a valid phone and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService().post('/auth/login', {
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
      });

      if (response.success && response.data != null) {
        final token = response.data['token'];
        await ApiService().setToken(token);
        _handleSuccessfulLogin(null);
      } else {
        _handleLoginError(response.message);
      }
    } catch (e) {
      _handleLoginError(e.toString());
    } finally {
      isLoading.value = false;
    }
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
    try {
      final response = await ApiService().post('/auth/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (response.success && response.data != null) {
        final token = response.data['token'];
        await ApiService().setToken(token);
        _handleSuccessfulLogin(null);
      } else {
        _handleLoginError(response.message);
      }
    } catch (e) {
      _handleLoginError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Google Login Method
  Future<void> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      await _loginWithBackend(userCredential.user, 'google');
    } catch (e) {
      _handleLoginError(e.toString());
    }
  }

  // Facebook Login Method
  Future<void> facebookLogin() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        return;
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      await _loginWithBackend(userCredential.user, 'facebook');
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Apple Login Method
  Future<void> appleLogin() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      await _loginWithBackend(userCredential.user, 'apple');
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Guest Login Method — no auth required, browse as guest
  Future<void> guestLogin() async {
    Get.offAllNamed('/main-app');
  }

  // Exchange Firebase social credentials for a VIPs JWT token
  Future<void> _loginWithBackend(User? firebaseUser, String provider) async {
    try {
      final response = await ApiService().post('/auth/social', {
        'email'      : firebaseUser?.email,
        'name'       : firebaseUser?.displayName,
        'providerUid': firebaseUser?.uid,
        'provider'   : provider,
      });
      if (response.success && response.data != null) {
        await ApiService().setToken(response.data['token']);
      }
    } catch (_) {}
    _handleSuccessfulLogin(firebaseUser);
  }

  // Handle Successful Login
  void _handleSuccessfulLogin(User? user) {
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
}
