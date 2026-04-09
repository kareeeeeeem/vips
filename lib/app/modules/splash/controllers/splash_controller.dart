import 'dart:async';

import 'package:get/get.dart';
import 'package:vip/app/modules/onboarding/views/onboarding_view.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    // Naviguer vers l'écran suivant après 3 secondes
    Timer(const Duration(seconds: 1), () {
      navigateToNextScreen();
    });
  }

  void navigateToNextScreen() {
    Get.off(() => OnboardingView());
  }
}

// Binding pour l'injection de dépendance
class SplashBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
