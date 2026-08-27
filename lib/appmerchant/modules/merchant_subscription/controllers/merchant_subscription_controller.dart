import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantSubscriptionController extends GetxController {
  final _api = ApiService();

  final isLoading = false.obs;
  final currentPlan = <String, dynamic>{}.obs;
  final availablePlans = <Map<String, dynamic>>[].obs;
  final paymentHistory = <Map<String, dynamic>>[].obs;

  // `currentCommission` (hardcoded 0.3) and `walletPoints` (never assigned,
  // so it always rendered "VP 0") lived here. Neither has any backing in the
  // subscription API — there is no commission concept at all, and a
  // subscription is paid from `User.walletBalance`, which is what this reads.
  final selectedPackageName = 'free'.obs;
  final selectedPackagePrice = 0.0.obs;

  /// 'monthly' or 'yearly'. The backend charges 10x the monthly price for a
  /// year (two months free) and sets endDate accordingly; the app never
  /// offered the choice, so every subscribe silently defaulted to monthly.
  final billingCycle = 'monthly'.obs;

  /// Real spendable balance the subscription is charged against.
  final walletBalance = 0.0.obs;

  final isSubscribing = false.obs;
  final isCancelling = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentPlan();
    loadPlans();
    loadHistory();
    loadWalletBalance();
  }

  Future<void> loadWalletBalance() async {
    try {
      final response = await _api.get('/merchant/wallet');
      if (response.success && response.data is Map) {
        final v = (response.data as Map)['balance'];
        walletBalance.value = v is num ? v.toDouble() : 0;
      }
    } catch (e) {
      debugPrint('loadWalletBalance error: $e');
    }
  }

  /// Effective price for the selected cycle — mirrors the backend's
  /// `isYearly ? price * 10 : price`.
  double priceFor(double monthlyPrice) =>
      billingCycle.value == 'yearly' ? monthlyPrice * 10 : monthlyPrice;

  int get monthsForCycle => billingCycle.value == 'yearly' ? 12 : 1;

  Future<void> loadCurrentPlan() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/merchant/subscription/current');
      if (response.success && response.data != null) {
        final data = Map<String, dynamic>.from(response.data as Map);
        currentPlan.value = data;
        // Backend field is `planCode` (e.g. "free"/"basic"), not `plan`.
        selectedPackageName.value = data['planCode'] ?? 'free';
        if (data['billingCycle'] is String) {
          billingCycle.value = data['billingCycle'];
        }
      }
    } catch (e) {
      debugPrint('loadCurrentPlan error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPlans() async {
    try {
      final response = await _api.get('/merchant/subscription/plans');
      if (response.success && response.data != null) {
        final raw = response.data;
        if (raw is List) {
          availablePlans.value = List<Map<String, dynamic>>.from(raw);
        } else if (raw is Map) {
          availablePlans.value = (raw as Map<String, dynamic>).entries
              .map((e) => {'id': e.key, ...Map<String, dynamic>.from(e.value as Map)})
              .toList();
        }
      }
    } catch (e) {
      debugPrint('loadPlans error: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      final response = await _api.get('/merchant/subscription/history');
      if (response.success && response.data is List) {
        // Backend returns the history array directly, not wrapped in a map.
        paymentHistory.value = (response.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      debugPrint('loadHistory error: $e');
    }
  }

  /// Returns true when the subscription actually went through, so the caller
  /// can navigate only on success.
  Future<bool> subscribe(String planId) async {
    if (isSubscribing.value) return false;
    isSubscribing.value = true;
    try {
      final response = await _api.post('/merchant/subscription/subscribe', {
        // Backend expects `planCode`, not `plan` (confirmed live — sending
        // `plan` always fails with "Invalid plan code" regardless of value).
        'planCode': planId,
        'billingCycle': billingCycle.value,
        // The backend always charges User.walletBalance; there is no gateway
        // in this flow, so this only labels the payment-history row.
        'paymentMethod': 'wallet',
      });
      if (response.success) {
        safeSnackbar('Success', response.message.isNotEmpty
            ? response.message
            : 'Subscribed to $planId plan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF));
        await Future.wait([loadCurrentPlan(), loadHistory(), loadWalletBalance()]);
        return true;
      }
      safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Subscription failed',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      debugPrint('subscribe error: $e');
      safeSnackbar('Error', 'Could not change your plan. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubscribing.value = false;
    }
  }

  /// Turns off auto-renewal; the plan stays active until endDate.
  /// POST /merchant/subscription/cancel already existed on the backend but
  /// nothing in the app ever called it — there was no way to stop renewing.
  Future<void> cancelAutoRenew() async {
    if (isCancelling.value) return;
    isCancelling.value = true;
    try {
      final response = await _api.post('/merchant/subscription/cancel', {});
      if (response.success) {
        safeSnackbar('Auto-renewal off', response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF));
        await loadCurrentPlan();
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('cancelAutoRenew error: $e');
      safeSnackbar('Error', 'Could not cancel auto-renewal. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCancelling.value = false;
    }
  }

  void selectPackage(String name, double price) {
    selectedPackageName.value = name;
    selectedPackagePrice.value = price;
  }

  /// Feature labels for a plan's `features` map, shared by the packages list
  /// and the current-plan screen. `-1` means unlimited on the backend.
  static List<String> featureLabels(dynamic features) {
    if (features is! Map) return const [];
    String count(dynamic v, String noun) {
      final n = v is num ? v.toInt() : null;
      if (n == null) return '';
      return n < 0 ? 'Unlimited $noun' : '$n $noun';
    }

    return [
      count(features['maxProducts'], 'Products'),
      count(features['maxCashiers'], 'Cashiers'),
      if (features['analytics'] == true) 'Analytics',
      if (features['adsEnabled'] == true) 'Advertisements',
      if (features['prioritySupport'] == true) 'Priority Support',
      if (features['apiAccess'] == true) 'API Access',
    ].where((e) => e.isNotEmpty).toList();
  }
}
