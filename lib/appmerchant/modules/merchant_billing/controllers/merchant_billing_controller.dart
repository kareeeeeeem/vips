import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantBillingController extends GetxController {
  final _api = ApiService();

  // PIN state
  final pinLength = 4.obs;
  final currentPin = ''.obs;
  final hasError = false.obs;
  final isVerifyingPin = false.obs;

  /// Whether this account has a server-side PIN at all (from
  /// GET /merchant/profile's `hasPin`). Used to tell "wrong PIN" apart from
  /// "you never set one", instead of silently failing.
  final hasPin = false.obs;

  // Bills list state
  final isLoading = false.obs;
  final bills = <Map<String, dynamic>>[].obs;
  final todayRevenue = 0.0.obs;
  final monthRevenue = 0.0.obs;
  final totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
    loadStats();
    _loadMerchantPin();
  }

  Future<void> _loadMerchantPin() async {
    try {
      final response = await _api.get('/merchant/profile');
      if (response.success && response.data is Map) {
        hasPin.value = response.data['hasPin'] == true;
      }
    } catch (e) {
      debugPrint('_loadMerchantPin error: $e');
    }
  }

  /// Verifies the entered PIN against the account's real PIN via
  /// POST /auth/pin/verify.
  ///
  /// This gate used to compare the typed digits against a SharedPreferences
  /// key `merchant_pin` that nothing in the app ever wrote — so it always
  /// fell back to the literal '0000' and anyone holding the device could
  /// approve a bill by typing four zeros.
  Future<bool> verifyPin(String pin) async {
    isVerifyingPin.value = true;
    try {
      final response = await _api.post('/auth/pin/verify', {'pin': pin});
      hasError.value = !response.success;
      return response.success;
    } catch (e) {
      debugPrint('verifyPin error: $e');
      hasError.value = true;
      return false;
    } finally {
      isVerifyingPin.value = false;
    }
  }

  // ─── PIN helpers ────────────────────────────────────────

  void addPinDigit(String digit) {
    if (currentPin.value.length < pinLength.value) {
      currentPin.value += digit;
      hasError.value = false;
    }
  }

  void removePinDigit() {
    if (currentPin.value.isNotEmpty) {
      currentPin.value = currentPin.value.substring(0, currentPin.value.length - 1);
    }
  }

  // ─── API calls ──────────────────────────────────────────

  Future<void> loadBills({String? status}) async {
    isLoading.value = true;
    try {
      final params = <String, String>{};
      if (status != null) params['status'] = status;
      final response = await _api.get('/merchant/billing', queryParams: params);
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        bills.value = List<Map<String, dynamic>>.from(data['bills'] ?? []);
        totalRevenue.value = (data['totalRevenue'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('loadBills error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final response = await _api.get('/merchant/billing/stats');
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        todayRevenue.value = (data['today']?['revenue'] ?? 0).toDouble();
        monthRevenue.value = (data['month']?['revenue'] ?? 0).toDouble();
        totalRevenue.value = (data['total']?['revenue'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('loadStats error: $e');
    }
  }

  Future<bool> createBill({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double grandTotal,
    double taxAmount = 0,
    double taxRate = 0,
    double discountAmount = 0,
    double serviceCharge = 0,
    String paymentMethod = 'cash',
    double? paidAmount,
    String? customerName,
    String? customerPhone,
    String? customerId,
    String? notes,
    String? cashierId,
  }) async {
    try {
      final response = await _api.post('/merchant/billing', {
        'items': items,
        'subtotal': subtotal,
        'grandTotal': grandTotal,
        'taxAmount': taxAmount,
        'taxRate': taxRate,
        'discountAmount': discountAmount,
        'serviceCharge': serviceCharge,
        'paymentMethod': paymentMethod,
        'paidAmount': paidAmount ?? grandTotal,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerId': customerId,
        'notes': notes,
        'cashierId': cashierId,
      });
      if (response.success) {
        await loadBills();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('createBill error: $e');
      return false;
    }
  }

  Future<void> voidBill(String id, {String? reason}) async {
    try {
      final response = await _api.put('/merchant/billing/$id/void', {'reason': reason ?? ''});
      if (response.success) {
        await loadBills();
        safeSnackbar('Done', 'Bill voided', snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to void bill',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Network error — could not void bill', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> refundBill(String id) async {
    try {
      final response = await _api.put('/merchant/billing/$id/refund', {});
      if (response.success) {
        await loadBills();
        safeSnackbar('Done', 'Bill refunded', snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to refund bill',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Network error — could not refund bill', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
