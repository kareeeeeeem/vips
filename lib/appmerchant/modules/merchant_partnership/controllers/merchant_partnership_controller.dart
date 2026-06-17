import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class MerchantPartnershipController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  // Reward Setup State
  final minRewardPercent = 0.5.obs;
  final minPurchaseAmount = 1.0.obs;
  final redeemPointsValue = 100.obs;
  final redeemDinarValue = 1.obs;
  final isAgreed = false.obs;
  final showFinalStep = false.obs;

  final onboardingData = [
    {
      "title": "Increase Repeat Users",
      "subtitle": "Make users come to your store again and again",
      "illustration": "assets/images/merchant/onboarding_1.png",
    },
    {
      "title": "Increase Ticket size",
      "subtitle": "Customers spend higher at stores with loyalty points",
      "illustration": "assets/images/merchant/onboarding_2.png",
    },
    {
      "title": "Encourage customer loyalty",
      "subtitle": "Prevents your customers from going to other business",
      "illustration": "assets/images/merchant/onboarding_3.png",
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.offNamed(MerchantRoutes.REWARD_SETUP);
    }
  }

  void skip() {
    Get.offNamed(MerchantRoutes.REWARD_SETUP);
  }

  void toggleAgreement(bool? value) {
    isAgreed.value = value ?? false;
  }

  void confirmSetup() {
    if (isAgreed.value) {
      Get.toNamed(MerchantRoutes.SUCCESS);
    } else {
      Get.snackbar(
        "Agreement Required",
        "Please agree to the Terms & Conditions",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
