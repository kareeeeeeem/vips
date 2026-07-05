import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vip/core/services/api_service.dart';
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
    if (!canLogin) {
      Get.defaultDialog(
        title: 'Validation Error',
        middleText: 'Please enter a valid phone and password.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () => Get.back(),
      );
      return;
    }

    try {
      final response = await ApiService().post('/auth/login', {
        'email':
            '${phoneController.text}@example.com', // Adapting phone to email for now or change backend
        'password': passwordController.text,
      });

      if (response.success && response.data != null) {
        final token = response.data['token'];
        await ApiService().setToken(token);
        _handleSuccessfulLogin(
          null,
        ); // Passing null since we don't use Firebase User anymore
      } else {
        _handleLoginError(response.message);
      }
    } catch (e) {
      _handleLoginError(e.toString());
    }
  }

  // Email Login Method
  void emailLogin() async {
    if (!canEmailLogin) {
      Get.defaultDialog(
        title: 'Validation Error',
        middleText: 'Please enter a valid email and password.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () => Get.back(),
      );
      return;
    }

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

      // If backend has a social login endpoint, you should call it here with userCredential.user
      // final idToken = await userCredential.user?.getIdToken();
      // final response = await ApiService().post('/auth/social', {'token': idToken});
      // await ApiService().setToken(response.data['token']);

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e.toString());
    }
  }

  // Facebook Login Method
  Future<void> facebookLogin() async {
    try {
      // Trigger the Facebook Authentication flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        return;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Apple Login Method
  Future<void> appleLogin() async {
    try {
      // Perform Apple Sign In
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      // Create an OAuthCredential from the Apple ID credential
      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Guest Login Method — no auth required, browse as guest
  Future<void> guestLogin() async {
    Get.offAllNamed('/main-app');
  }

  // Handle Successful Login
  void _handleSuccessfulLogin(User? user) {
    // Navigate to main app shell after login so bottom navigation is shown
    Get.offAllNamed('/main-app');
  }

  // Handle Login Errors
  void _handleLoginError(dynamic error) {
    final String errorMessage = error is String
        ? error
        : (error?.toString() ?? 'An unknown error occurred');

    Get.defaultDialog(
      title: 'Login Error',
      middleText: errorMessage,
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () => Get.back(),
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
    // Dispose controllers when the controller is closed
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
