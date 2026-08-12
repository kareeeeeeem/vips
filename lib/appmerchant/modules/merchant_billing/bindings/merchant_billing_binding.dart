import 'package:get/get.dart';
import '../controllers/merchant_billing_controller.dart';
import '../controllers/merchant_create_bill_controller.dart';

class MerchantBillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantBillingController>(() => MerchantBillingController());
    Get.lazyPut<MerchantCreateBillController>(
        () => MerchantCreateBillController());
  }
}
