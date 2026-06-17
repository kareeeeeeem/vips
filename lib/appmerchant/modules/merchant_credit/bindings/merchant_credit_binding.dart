import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_credit/controllers/merchant_credit_controller.dart';

class MerchantCreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantCreditController>(() => MerchantCreditController());
  }
}
