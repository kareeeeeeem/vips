import 'dart:async';

import 'package:get/get.dart';
import 'package:vip/appuser/modules/onboarding/views/onboarding_view.dart';
import 'package:vip/core/services/api_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 1), () {
      navigateToNextScreen();
    });
  }

  Future<void> navigateToNextScreen() async {
    // Initialize ApiService (loads saved token from SharedPreferences)
    await ApiService().init();

    if (ApiService().isLoggedIn) {
      // Token found → go directly to main app, no login needed
      Get.offAllNamed('/main-app');
    } else {
      // No token → go to onboarding
      Get.off(() => OnboardingView());
    }
  }
}

// Binding pour l'injection de dépendance
class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
