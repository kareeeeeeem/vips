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

      final billNumber = response.success && response.data != null
          ? (response.data as Map<String, dynamic>)['billNumber'] ?? 'BILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : 'BILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      Get.toNamed(
        MerchantRoutes.BILL_SCAN_ME,
        arguments: {
          'amount': parsedAmount,
          'orderId': billNumber,
        },
      );
    } catch (_) {
      Get.toNamed(
        MerchantRoutes.BILL_SCAN_ME,
        arguments: {
          'amount': parsedAmount,
          'orderId': 'BILL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        },
      );
    } finally {
      _isCreating.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
