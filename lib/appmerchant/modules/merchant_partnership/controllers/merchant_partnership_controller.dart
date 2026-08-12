import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantPartnershipController extends GetxController {
  final _api = ApiService();

  final pageController = PageController();
  final currentPage = 0.obs;
  final isLoading = false.obs;

  // Partnership / registration status
  final partnershipStatus = ''.obs; // 'pending', 'approved', 'rejected', etc.
  final registrationData = <String, dynamic>{}.obs;

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

  @override
  void onInit() {
    super.onInit();
    // Only load status when authenticated — onboarding is shown to new (unauthenticated) users too
    if (_api.isLoggedIn) {
      loadPartnershipStatus();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadPartnershipStatus() async {
    try {
      final response = await _api.get('/merchant/partnership/status');
      if (response.success && response.data != null) {
        final data = Map<String, dynamic>.from(response.data as Map);
        registrationData.value = data;
        partnershipStatus.value = data['status'] ?? '';
      }
    } catch (e) {
      debugPrint('loadPartnershipStatus error: $e');
    }
  }

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

  Future<void> confirmSetup() async {
    if (!isAgreed.value) {
      safeSnackbar(
        "Agreement Required",
        "Please agree to the Terms & Conditions",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Fetch merchant profile to get required fields
      final profileRes = await _api.get('/merchant/profile');
      final profile = (profileRes.success && profileRes.data != null)
          ? Map<String, dynamic>.from(profileRes.data as Map)
          : <String, dynamic>{};

      final response = await _api.post('/merchant/partnership/register', {
        'storeName': profile['storeName'] ?? profile['fullName'] ?? 'My Store',
        'ownerName': profile['fullName'] ?? 'Owner',
        'phone': profile['phone'] ?? '',
        'email': profile['email'] ?? '',
        'businessType': 'retail',
        'minRewardPercent': minRewardPercent.value,
        'minPurchaseAmount': minPurchaseAmount.value,
        'redeemPointsValue': redeemPointsValue.value,
        'redeemDinarValue': redeemDinarValue.value,
      });

      if (response.success) {
        Get.toNamed(MerchantRoutes.SUCCESS);
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Registration failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
