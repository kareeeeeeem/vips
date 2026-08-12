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

  final currentCommission = 0.3.obs;
  final selectedPackageName = 'Basic'.obs;
  final selectedPackagePrice = 99.00.obs;
  final selectedPackageDuration = 120.obs;
  final paymentMethod = 'COD'.obs;
  final walletPoints = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentPlan();
    loadPlans();
  }

  Future<void> loadCurrentPlan() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/merchant/subscription/current');
      if (response.success && response.data != null) {
        final data = Map<String, dynamic>.from(response.data as Map);
        currentPlan.value = data;
        selectedPackageName.value = data['plan'] ?? 'Basic';
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
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        paymentHistory.value = List<Map<String, dynamic>>.from(
          data['history'] ?? [],
        );
      }
    } catch (e) {
      debugPrint('loadHistory error: $e');
    }
  }

  Future<void> subscribe(String planId) async {
    try {
      final response = await _api.post('/merchant/subscription/subscribe', {
        'plan': planId,
        'paymentMethod': paymentMethod.value.toLowerCase(),
      });
      if (response.success) {
        safeSnackbar('Success', 'Subscribed to $planId plan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF));
        await loadCurrentPlan();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Subscription failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void selectPackage(String name, double price, int duration) {
    selectedPackageName.value = name;
    selectedPackagePrice.value = price;
    selectedPackageDuration.value = duration;
  }
}
