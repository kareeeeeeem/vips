import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/routes/app_pages.dart';
import 'package:vip/core/services/api_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    debugPrint('[SPLASH] onInit called');
    startTimer();
  }

  void startTimer() {
    debugPrint('[SPLASH] Timer started - waiting 2s');
    Timer(const Duration(seconds: 2), () {
      debugPrint('[SPLASH] Timer fired - calling navigateToNextScreen');
      navigateToNextScreen();
    });
  }

  Future<void> navigateToNextScreen() async {
    debugPrint('[SPLASH] navigateToNextScreen started');
    try {
      // ApiService.init() was already called in main() — just check the token
      final isLoggedIn = ApiService().isLoggedIn;
      debugPrint('[SPLASH] isLoggedIn = $isLoggedIn');

      if (isLoggedIn) {
        // A token alone doesn't mean PIN setup was ever finished — signup/
        // social-login/reset-password all issue a token before the Create
        // PIN step, so an interrupted flow (app closed right after signup)
        // would otherwise land here with a token but pin == null server
        // side. Every PIN-gated screen (Wallet, bill payment, mobile
        // recharge) calls /auth/pin/verify, which always rejects a null
        // PIN — so without this check that account hits an unrecoverable
        // dead end (repeated "Incorrect PIN" down to a lockout) with no
        // indication the real problem is that no PIN was ever set.
        try {
          final me = await ApiService().get('/auth/me');
          final user = me.success && me.data is Map ? me.data['user'] : null;
          final hasPin = user is Map && user['hasPin'] == true;
          debugPrint('[SPLASH] isLoggedIn, hasPin=$hasPin → navigating to ${hasPin ? 'MAIN_APP' : 'CREATEPIN'}');
          Get.offAllNamed(hasPin ? Routes.MAIN_APP : Routes.CREATEPIN);
        } catch (e) {
          // Network hiccup, not necessarily a real auth problem (a truly
          // invalid/expired token is already caught app-wide by
          // ApiService's 401 interceptor on the next real request) — don't
          // strand a real user in onboarding over a flaky connection.
          debugPrint('[SPLASH] /auth/me check failed ($e), falling back to MAIN_APP');
          Get.offAllNamed(Routes.MAIN_APP);
        }
      } else {
        debugPrint('[SPLASH] → navigating to ONBOARDING');
        Get.offAllNamed(Routes.ONBOARDING);
      }
    } catch (e, stack) {
      debugPrint('[SPLASH] ERROR: $e');
      debugPrint('[SPLASH] Stack: $stack');
      Get.offAllNamed(Routes.ONBOARDING);
    }
  }
}
