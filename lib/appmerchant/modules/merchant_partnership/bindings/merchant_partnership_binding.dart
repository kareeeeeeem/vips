import 'package:get/get.dart';
import '../controllers/merchant_partnership_controller.dart';

class MerchantPartnershipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantPartnershipController>(
      () => MerchantPartnershipController(),
    );
  }
}
