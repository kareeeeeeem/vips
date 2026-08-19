import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/services/auth_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantAuthController extends GetxController {
  final AuthService _authService = AuthService();

  final phoneController = TextEditingController();
  final pinController = TextEditingController(); // reserved for future use

  final isLoading = false.obs;
  final phoneNumber = ''.obs;

  // ── Send OTP ─────────────────────────────────────────────────
  Future<void> login() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      safeSnackbar('Error', 'Please enter your phone number');
      return;
    }

    isLoading.value = true;
    debugPrint('[MERCHANT_LOGIN] login() started for $phone');
    try {
      final response = await ApiService().post(
        '/auth/merchant-login',
        {'phone': phone},
      );
      debugPrint('[MERCHANT_LOGIN] login() response received, success=${response.success}');

      if (response.success) {
        phoneNumber.value = phone;
        Get.toNamed(MerchantRoutes.VERIFICATION);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] login() threw: $e');
      safeSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify OTP & obtain token ─────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    if (otp.length < 4) {
      safeSnackbar('Error', 'Please enter a valid OTP');
      return;
    }

    isLoading.value = true;
    debugPrint('[MERCHANT_LOGIN] verifyOtp() started');
    try {
      final response = await ApiService().post(
        '/auth/merchant-verify-otp',
        {'phone': phoneNumber.value, 'otp': otp},
      );
      debugPrint('[MERCHANT_LOGIN] verifyOtp() response received, success=${response.success}');

      if (response.success) {
        final token = response.data?['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await ApiService().setToken(token);
          // Also persist under the 'token' key used by ApiClient / SplashController
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        Get.offAllNamed(MerchantRoutes.HOME);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] verifyOtp() threw: $e');
      safeSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiService().clearToken();
    Get.offAllNamed(MerchantRoutes.LOGIN);
  }

  // ── Social sign-in (Google / Facebook / Apple) ──────────────────
  // Existing merchant accounts only — a social account is matched to an
  // already-registered merchant by email; it does not create new merchant
  // accounts (those must go through business registration).
  Future<void> googleLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[MERCHANT_LOGIN] googleLogin() started');
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        debugPrint('[MERCHANT_LOGIN] googleLogin() canceled by user');
        return;
      }
      debugPrint('[MERCHANT_LOGIN] Google auth done, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'google');
      debugPrint('[MERCHANT_LOGIN] googleLogin() finished');
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] googleLogin() threw: $e');
      safeSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> facebookLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[MERCHANT_LOGIN] facebookLogin() started');
    try {
      final userCredential = await _authService.signInWithFacebook();
      if (userCredential == null) {
        debugPrint('[MERCHANT_LOGIN] facebookLogin() canceled by user');
        return;
      }
      debugPrint('[MERCHANT_LOGIN] Facebook auth done, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'facebook');
      debugPrint('[MERCHANT_LOGIN] facebookLogin() finished');
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] facebookLogin() threw: $e');
      safeSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> appleLogin() async {
    if (isLoading.value) return;
    isLoading.value = true;
    debugPrint('[MERCHANT_LOGIN] appleLogin() started');
    try {
      final userCredential = await _authService.signInWithApple();
      debugPrint('[MERCHANT_LOGIN] Apple auth done, exchanging with backend...');
      await _loginWithBackend(userCredential.user, 'apple');
      debugPrint('[MERCHANT_LOGIN] appleLogin() finished');
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] appleLogin() threw: $e');
      safeSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loginWithBackend(User? firebaseUser, String provider) async {
    try {
      debugPrint('[MERCHANT_LOGIN] _loginWithBackend: getting Firebase ID token...');
      final idToken = await firebaseUser?.getIdToken();
      debugPrint('[MERCHANT_LOGIN] _loginWithBackend: POST /auth/merchant-social...');
      final response = await ApiService().post('/auth/merchant-social', {
        'idToken': idToken,
      });
      debugPrint('[MERCHANT_LOGIN] _loginWithBackend: response received, success=${response.success}');

      if (response.success && response.data != null) {
        final token = response.data?['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await ApiService().setToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        Get.offAllNamed(MerchantRoutes.HOME);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] _loginWithBackend threw: $e');
      safeSnackbar('Error', 'Failed to sign in. Please try again.');
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    pinController.dispose();
    super.onClose();
  }
}
