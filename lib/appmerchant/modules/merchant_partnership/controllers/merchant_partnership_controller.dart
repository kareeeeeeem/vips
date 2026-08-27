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
  final storeAddressController = TextEditingController();

  // The four reward-convention numbers the merchant is agreeing to. These used
  // to be display-only Containers with the defaults painted on as literal text,
  // so every merchant submitted 0.5% / 1 D / 100 pts / 1 D no matter what their
  // deal actually was. They are real inputs now.
  // Constructed here rather than in onInit: onClose disposes them, and GetX
  // can close a controller that was never initialised (a binding that is
  // torn down before the screen builds), which threw a
  // LateInitializationError instead of just closing.
  final minRewardPercentController = TextEditingController();
  final minPurchaseAmountController = TextEditingController();
  final redeemPointsController = TextEditingController();
  final redeemDinarController = TextEditingController();

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

  // Each slide used to carry an "illustration" path under
  // assets/images/merchant/ — a directory that does not exist, and which the
  // view never read anyway: all three slides drew the same grey box with one
  // storefront glyph. Replaced with a per-slide icon the view actually uses.
  final onboardingData = [
    {
      "title": "Increase Repeat Users",
      "subtitle": "Make users come to your store again and again",
      "icon": Icons.repeat_rounded,
    },
    {
      "title": "Increase Ticket size",
      "subtitle": "Customers spend higher at stores with loyalty points",
      "icon": Icons.trending_up_rounded,
    },
    {
      "title": "Encourage customer loyalty",
      "subtitle": "Prevents your customers from going to other business",
      "icon": Icons.favorite_rounded,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    minRewardPercentController.text = _trimNumber(minRewardPercent.value);
    minPurchaseAmountController.text = _trimNumber(minPurchaseAmount.value);
    redeemPointsController.text = redeemPointsValue.value.toString();
    redeemDinarController.text = redeemDinarValue.value.toString();

    minRewardPercentController.addListener(() {
      final v = double.tryParse(minRewardPercentController.text.trim());
      if (v != null) minRewardPercent.value = v;
    });
    minPurchaseAmountController.addListener(() {
      final v = double.tryParse(minPurchaseAmountController.text.trim());
      if (v != null) minPurchaseAmount.value = v;
    });
    redeemPointsController.addListener(() {
      final v = int.tryParse(redeemPointsController.text.trim());
      if (v != null) redeemPointsValue.value = v;
    });
    redeemDinarController.addListener(() {
      final v = int.tryParse(redeemDinarController.text.trim());
      if (v != null) redeemDinarValue.value = v;
    });

    // Only load status when authenticated — onboarding is shown to new (unauthenticated) users too
    if (_api.isLoggedIn) {
      loadPartnershipStatus();
    }
  }

  /// 0.5 -> "0.5", 1.0 -> "1" — keeps the seeded field text readable.
  String _trimNumber(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void onClose() {
    pageController.dispose();
    storeAddressController.dispose();
    minRewardPercentController.dispose();
    minPurchaseAmountController.dispose();
    redeemPointsController.dispose();
    redeemDinarController.dispose();
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
      _startPartnership();
    }
  }

  void skip() => _startPartnership();

  /// Reward Setup submits to authenticated partnership endpoints. Onboarding is
  /// also the very first screen a brand-new (signed-out) merchant sees, so
  /// sending them straight there meant Confirm could only ever 401. Route
  /// unauthenticated merchants through account creation first.
  void _startPartnership() {
    if (_api.isLoggedIn) {
      Get.offNamed(MerchantRoutes.REWARD_SETUP);
    } else {
      Get.toNamed(MerchantRoutes.SIGNUP);
    }
  }

  void goToLogin() => Get.toNamed(MerchantRoutes.LOGIN);

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

    if (storeAddressController.text.trim().isEmpty) {
      safeSnackbar(
        "Address Required",
        "Please enter your business address",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (minRewardPercent.value <= 0 || minPurchaseAmount.value <= 0 ||
        redeemPointsValue.value <= 0 || redeemDinarValue.value <= 0) {
      safeSnackbar(
        "Check your numbers",
        "Reward percentage, minimum purchase and redeem values must all be greater than zero",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_api.isLoggedIn) {
      safeSnackbar(
        "Sign in required",
        "Create your merchant account or sign in to submit this agreement",
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed(MerchantRoutes.SIGNUP);
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
        'address': storeAddressController.text.trim(),
        // The merchant's real category from their profile — this was pinned to
        // 'retail' for every business, and the backend mirrors businessType
        // straight back onto User.storeCategory, so submitting the agreement
        // silently rewrote a restaurant/pharmacy/etc. into "retail".
        'businessType': profile['storeCategory'] ?? 'retail',
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
      debugPrint('confirmSetup error: $e');
      safeSnackbar('Error', 'Could not submit your agreement. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
