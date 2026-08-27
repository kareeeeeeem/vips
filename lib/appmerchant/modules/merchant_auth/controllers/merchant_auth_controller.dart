import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/core/util/app_constants.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/services/auth_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantAuthController extends GetxController {
  final AuthService _authService = AuthService();

  final phoneController = TextEditingController();
  final pinController = TextEditingController(); // reserved for future use

  // ── Sign-up fields ────────────────────────────────────────────
  final storeNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storeAddressController = TextEditingController();
  final selectedCategory = ''.obs;
  final obscurePassword = true.obs;

  /// Same list the Business Registration category sheet offers, so a merchant's
  /// category means the same thing wherever it is set.
  static const businessCategories = <String, String>{
    'Restaurants': 'مطاعم ومقاهي',
    'Tourism': 'ترفيه وسياحة',
    'Electronics': 'إلكترونيات',
    'Food': 'غذائية و تنظيف',
    'Services': 'خدمات و حرف',
    'Clothes': 'ملابس وأحذية',
    'Bakery': 'مخابز وحلويات',
    'Makeup': 'جمال و عناية',
    'Education': 'تعلم',
    'Health': 'صحة و رياضة',
    'Other': 'أخرى',
  };

  final isLoading = false.obs;
  final phoneNumber = ''.obs;

  // ── Send OTP ─────────────────────────────────────────────────
  Future<void> login() async {
    if (isLoading.value) return;
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
      safeSnackbar('Error', 'Could not send the code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create a merchant account ─────────────────────────────────
  // Until this existed the merchant app had no way to create an account at
  // all: Splash sent a fresh install to Onboarding, Onboarding led to the
  // authenticated Reward Setup screen, and /auth/merchant-login only issues an
  // OTP to a phone that already belongs to a merchant. A new merchant could
  // never get past the first screen.
  Future<void> register() async {
    if (isLoading.value) return;

    final storeName = storeNameController.text.trim();
    final ownerName = ownerNameController.text.trim();
    final phone     = signupPhoneController.text.trim();
    final email     = emailController.text.trim();
    final password  = passwordController.text;
    final address   = storeAddressController.text.trim();

    if (storeName.isEmpty || ownerName.isEmpty || phone.isEmpty || email.isEmpty) {
      safeSnackbar('Error', 'Store name, owner name, phone and email are all required');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      safeSnackbar('Error', 'Please enter a valid email address');
      return;
    }
    if (phone.length < 6) {
      safeSnackbar('Error', 'Please enter a valid phone number');
      return;
    }
    if (password.length < 6) {
      safeSnackbar('Error', 'Password must be at least 6 characters');
      return;
    }
    if (selectedCategory.value.isEmpty) {
      safeSnackbar('Error', 'Please choose your business category');
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService().post('/auth/register', {
        'fullName': ownerName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'merchant',
        'storeName': storeName,
        'storeCategory': selectedCategory.value,
        if (address.isNotEmpty) 'storeAddress': address,
      });

      if (response.success) {
        final token = response.data?['token'] as String?;
        if (token != null && token.isNotEmpty) {
          await ApiService().setToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.token, token);
        }
        // Straight into the partnership agreement — that is the next step of
        // the onboarding this screen is part of.
        Get.offAllNamed(MerchantRoutes.REWARD_SETUP);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('[MERCHANT_SIGNUP] register() threw: $e');
      safeSnackbar('Error', 'Could not create your account. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Verify OTP & obtain token ─────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    if (isLoading.value) return;
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
          // Also persist under the key used by ApiClient / SplashController
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.token, token);
        }
        Get.offAllNamed(MerchantRoutes.HOME);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('[MERCHANT_LOGIN] verifyOtp() threw: $e');
      safeSnackbar('Error', 'Could not verify the code. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    await ApiService().clearToken();
    // ApiService only clears its own 'auth_token' key. The merchant app also
    // persists the token under AppConstants.token ('token') for the Orders
    // module's ApiClient and the Splash login check — leaving it behind made
    // Splash treat a logged-out merchant as still signed in on the next cold
    // start, landing them on a dashboard that 401s on every request.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.token);
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
      safeSnackbar('Error', 'Could not sign in. Please try again.');
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
      safeSnackbar('Error', 'Could not sign in. Please try again.');
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
      safeSnackbar('Error', 'Could not sign in. Please try again.');
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
          await prefs.setString(AppConstants.token, token);
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
    storeNameController.dispose();
    ownerNameController.dispose();
    signupPhoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    storeAddressController.dispose();
    super.onClose();
  }
}
