import 'package:get/get.dart';
import '../controllers/merchant_billing_controller.dart';

class MerchantBillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantBillingController>(() => MerchantBillingController());
  }
}
