import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

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

  void generateOrderQr() {
    double? parsedAmount = double.tryParse(amount.value);
    if (parsedAmount == null || parsedAmount <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid bill amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFFEF4444),
      );
      return;
    }

    // Navigate to the QR Display Screen, passing the amount and a mock order ID
    Get.toNamed(
      MerchantRoutes.BILL_SCAN_ME, 
      arguments: {
        'amount': parsedAmount,
        'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      }
    );
  }
}
