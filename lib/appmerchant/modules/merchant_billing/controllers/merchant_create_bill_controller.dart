import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantCreateBillController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final RxString amount = '0.00'.obs;
  
  void appendNumber(String num) {
    if (amount.value == '0.00') {
      amount.value = num;
    } else if (amount.value.contains('.') && amount.value.split('.').last.length >= 2) {
      return; // Max 2 decimal places
    } else {
      amount.value += num;
    }
    amountController.text = amount.value;
  }

  void appendDecimal() {
    if (!amount.value.contains('.')) {
      if (amount.value.isEmpty || amount.value == '0.00') {
        amount.value = '0.';
      } else {
        amount.value += '.';
      }
      amountController.text = amount.value;
    }
  }

  void backspace() {
    if (amount.value.length > 1 && amount.value != '0.00') {
      amount.value = amount.value.substring(0, amount.value.length - 1);
      if (amount.value.isEmpty) amount.value = '0.00';
    } else {
      amount.value = '0.00';
    }
    amountController.text = amount.value;
  }

  void clearAmount() {
    amount.value = '0.00';
    amountController.text = amount.value;
  }

  final _isCreating = false.obs;
  bool get isCreating => _isCreating.value;

  Future<void> generateOrderQr() async {
    double? parsedAmount = double.tryParse(amount.value);
    if (parsedAmount == null || parsedAmount <= 0) {
      safeSnackbar(
        'Invalid Amount',
        'Please enter a valid bill amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFEF4444),
      );
      return;
    }

    _isCreating.value = true;
    try {
      final response = await ApiService().post('/merchant/billing', {
        'items': [{'name': 'Quick Charge', 'price': parsedAmount, 'quantity': 1, 'total': parsedAmount}],
        'subtotal': parsedAmount,
        'grandTotal': parsedAmount,
        'paymentMethod': 'cash',
        'paymentStatus': 'pending',
        'paidAmount': 0,
      });

      // A failed create used to fall through to a locally-invented
      // `BILL-<timestamp>` and open the QR screen anyway — so the merchant
      // showed the customer a code for a bill that does not exist on the
      // server. Stop here instead and say what went wrong.
      if (!response.success || response.data is! Map) {
        safeSnackbar(
          'Could not create the bill',
          response.message.isNotEmpty
              ? response.message
              : 'Please check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFEF2F2),
          colorText: const Color(0xFFEF4444),
        );
        return;
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      final billNumber = (data['billNumber'] ?? '').toString();
      if (billNumber.isEmpty) {
        safeSnackbar(
          'Could not create the bill',
          'The server did not return a bill reference. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFEF2F2),
          colorText: const Color(0xFFEF4444),
        );
        return;
      }

      Get.toNamed(
        MerchantRoutes.BILL_SCAN_ME,
        arguments: {
          'amount': parsedAmount,
          'orderId': billNumber,
          // The bill's real id, so the QR screen can settle it once the
          // customer has paid (PUT /merchant/billing/:id/pay).
          'billId': (data['_id'] ?? '').toString(),
        },
      );
    } catch (e) {
      debugPrint('generateOrderQr failed: $e');
      safeSnackbar(
        'Could not create the bill',
        'Please check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFEF4444),
      );
    } finally {
      _isCreating.value = false;
    }
  }

  /// Marks a pending bill paid once the customer has settled it.
  /// PUT /merchant/billing/:id/pay — bills created for the QR flow stay
  /// `pending` until this runs, so their total is not booked as revenue
  /// before the money actually arrives.
  Future<bool> markBillPaid(String billId, {double? paidAmount}) async {
    if (billId.isEmpty) return false;
    try {
      final response = await ApiService().put('/merchant/billing/$billId/pay', {
        if (paidAmount != null) 'paidAmount': paidAmount,
      });
      if (response.success) {
        safeSnackbar('Payment recorded', 'The bill is now marked paid',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: const Color(0xFFFFFFFF));
        return true;
      }
      safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      debugPrint('markBillPaid failed: $e');
      safeSnackbar('Error', 'Could not record that payment. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
