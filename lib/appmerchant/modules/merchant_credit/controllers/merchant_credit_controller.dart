import 'package:get/get.dart';
import '../../../../appmerchant/routes/merchant_routes.dart';

class MerchantCreditController extends GetxController {
  final amount = '0.000'.obs;
  final points = '000'.obs;
  final selectedPaymentMethod = 'Bank'.obs;
  
  final exchangeRate = 100.0; // 1 D = 100 VIP
  final serviceChargeRate = 0.10; // 10%

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
}
