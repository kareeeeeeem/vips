import 'dart:async';

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

  // Who this credit transaction is for — captured on the inquiry screen.
  // Filled either by picking a real customer from search (selectedCustomerId
  // set) or by typing name/phone manually for a first-time customer with no
  // transaction history yet (selectedCustomerId stays null; backend accepts
  // that fallback).
  final customerNameCtrl = TextEditingController();
  final customerPhoneCtrl = TextEditingController();
  final selectedCustomerId = Rx<String?>(null);

  // Customer search (GET /merchant/customers?search=)
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;
  Timer? _searchDebounce;

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

  // Debounced live search against real customers who have transacted with
  // this merchant before (GET /merchant/customers?search=). Empty query
  // clears results instead of listing everyone.
  void searchCustomers(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      isSearching.value = true;
      try {
        final response = await _api.get('/merchant/customers', queryParams: {'search': query.trim()});
        if (response.success && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          searchResults.value = List<Map<String, dynamic>>.from(data['customers'] ?? []);
        }
      } catch (e) {
        debugPrint('searchCustomers error: $e');
      } finally {
        isSearching.value = false;
      }
    });
  }

  void selectCustomer(Map<String, dynamic> customer) {
    // Set the text fields first: TextField's onChanged fires on any
    // controller.text assignment (not just user input) and calls
    // clearSelectedCustomer() — so selectedCustomerId must be set last,
    // or it would be wiped out immediately by that side effect.
    customerNameCtrl.text = (customer['fullName'] ?? '').toString();
    customerPhoneCtrl.text = (customer['phone'] ?? '').toString();
    searchResults.clear();
    selectedCustomerId.value = (customer['_id'] ?? customer['id'])?.toString();
  }

  // Editing the name/phone by hand after picking a search result means
  // we're no longer sure it matches the selected customer — fall back to
  // the manual-entry path rather than sending a stale customerId.
  void clearSelectedCustomer() {
    selectedCustomerId.value = null;
  }

  Future<void> confirmCredit() async {
    final parsedAmount = double.tryParse(amount.value) ?? 0.0;
    if (parsedAmount <= 0) {
      safeSnackbar('Error', 'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final customerName = customerNameCtrl.text.trim();
    final customerPhone = customerPhoneCtrl.text.trim();
    if (customerName.isEmpty || customerPhone.isEmpty) {
      safeSnackbar('Incomplete', 'Please enter the customer\'s name and phone',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _api.post('/merchant/credits', {
        'amount': parsedAmount,
        if (selectedCustomerId.value != null) 'customerId': selectedCustomerId.value,
        'customerName': customerName,
        'customerPhone': customerPhone,
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
        customerNameCtrl.clear();
        customerPhoneCtrl.clear();
        selectedCustomerId.value = null;
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

  @override
  void onClose() {
    _searchDebounce?.cancel();
    customerNameCtrl.dispose();
    customerPhoneCtrl.dispose();
    super.onClose();
  }
}
