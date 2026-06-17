import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';

class MerchantSubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantSubscriptionController>(() => MerchantSubscriptionController());
  }
}
