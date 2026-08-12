import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../../appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantCreditController extends GetxController {
  final _api = ApiService();

  final amount = '0.000'.obs;
  final points = '000'.obs;
  final selectedPaymentMethod = 'Bank'.obs;
  final isLoading = false.obs;

  // Credits list
  final credits = <Map<String, dynamic>>[].obs;
  final totalActiveAmount = 0.0.obs;
  final dormantAmount = 0.0.obs;
  final approvedAmount = 0.0.obs;

  final exchangeRate = 100.0;
  final serviceChargeRate = 0.10;

  @override
  void onInit() {
    super.onInit();
    loadCredits();
  }

  Future<void> loadCredits({String? status}) async {
    try {
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      final response = await _api.get('/merchant/credits', queryParams: params);
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list = List<Map<String, dynamic>>.from(data['credits'] ?? []);
        credits.value = list;
        totalActiveAmount.value = (data['totalActiveAmount'] ?? 0).toDouble();

        // Compute dormant (overdue) vs approved (active) amounts from the list
        dormantAmount.value = list
            .where((c) => c['status'] == 'overdue')
            .fold(0.0, (sum, c) => sum + ((c['remainingAmount'] ?? 0) as num).toDouble());
        approvedAmount.value = list
            .where((c) => c['status'] == 'active')
            .fold(0.0, (sum, c) => sum + ((c['remainingAmount'] ?? 0) as num).toDouble());
      }
    } catch (e) {
      debugPrint('loadCredits error: $e');
    }
  }

  void onNumberPressed(String val) {
    if (amount.value == '0.000') {
      amount.value = val;
    } else {
      amount.value += val;
    }
    _calculatePoints();
  }

  void onDeletePressed() {
    if (amount.value.length > 1) {
      amount.value = amount.value.substring(0, amount.value.length - 1);
    } else {
      amount.value = '0.000';
    }
    _calculatePoints();
  }

  void onDecimalPressed() {
    if (!amount.value.contains('.')) {
      amount.value += '.';
    }
  }

  void _calculatePoints() {
    double val = double.tryParse(amount.value) ?? 0.0;
    points.value = (val * exchangeRate).toInt().toString();
  }

  void onProceedToInquiry() {
    Get.toNamed(MerchantRoutes.MERCHANT_CREDIT_INQUIRY);
  }

  Future<void> confirmCredit({String? customerId, String? customerName, String? customerPhone}) async {
    final parsedAmount = double.tryParse(amount.value) ?? 0.0;
    if (parsedAmount <= 0) {
      safeSnackbar('Error', 'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _api.post('/merchant/credits', {
        'amount': parsedAmount,
        if (customerId != null) 'customerId': customerId,
        if (customerName != null) 'customerName': customerName,
        if (customerPhone != null) 'customerPhone': customerPhone,
      });

      if (response.success) {
        Get.back();
        Get.back();
        safeSnackbar('Success', 'Credit transaction confirmed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF));
        amount.value = '0.000';
        points.value = '000';
        await loadCredits();
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to issue credit',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Network error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> settleCredit(String creditId, double paymentAmount, {String? method, String? note}) async {
    try {
      final response = await _api.put('/merchant/credits/$creditId/settle', {
        'paymentAmount': paymentAmount,
        'method': method ?? 'cash',
        if (note != null) 'note': note,
      });
      if (response.success) {
        await loadCredits();
        safeSnackbar('Success', 'Payment recorded', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('settleCredit error: $e');
    }
  }

  Future<void> cancelCredit(String creditId) async {
    try {
      final response = await _api.put('/merchant/credits/$creditId/cancel', {});
      if (response.success) {
        await loadCredits();
      }
    } catch (e) {
      debugPrint('cancelCredit error: $e');
    }
  }
}
