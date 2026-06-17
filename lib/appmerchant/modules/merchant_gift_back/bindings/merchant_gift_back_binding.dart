import 'package:get/get.dart';
import '../controllers/merchant_gift_back_controller.dart';

class MerchantGiftBackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantGiftBackController>(
      () => MerchantGiftBackController(),
    );
  }
}
