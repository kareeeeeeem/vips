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
        debugPrint('[SPLASH] → navigating to MAIN_APP');
        Get.offAllNamed(Routes.MAIN_APP);
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
