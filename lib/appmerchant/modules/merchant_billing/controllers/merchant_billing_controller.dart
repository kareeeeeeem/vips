import 'package:get/get.dart';

class MerchantBillingController extends GetxController {
  final pinLength = 4.obs;
  final currentPin = ''.obs;
  final hasError = false.obs;

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
}
