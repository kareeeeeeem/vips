import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    if (!canLogin) return;

    try {
      // Implement your phone login logic here
      // For example, using FirebaseAuth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: '${phoneController.text}@example.com', // Adapt as needed
            password: passwordController.text,
          );

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Email Login Method
  void emailLogin() async {
    if (!canEmailLogin) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Google Login Method
  Future<void> googleLogin() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser =
          GoogleSignIn.instance as GoogleSignInAccount?;

      if (googleUser == null) return;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e);
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

  // Guest Login Method
  Future<void> guestLogin() async {
    try {
      // Sign in anonymously with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();

      _handleSuccessfulLogin(userCredential.user);
    } catch (e) {
      _handleLoginError(e);
    }
  }

  // Handle Successful Login
  void _handleSuccessfulLogin(User? user) {
    if (user != null) {
      // Navigate to the main screen or dashboard
      Get.offAllNamed('/home'); // Adjust route as needed

      // Optional: Save login state if "Remember Me" is checked
      if (rememberMe) {
        // Implement persistent login logic
        // For example, using secure storage
      }
    }
  }

  // Handle Login Errors
  void _handleLoginError(dynamic error) {
    String errorMessage = 'An unknown error occurred';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email/phone.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = error.message ?? 'Authentication error';
      }
    }

    // Show error notification
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
