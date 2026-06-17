import 'package:get/get.dart';
import '../controllers/merchant_ads_controller.dart';

class MerchantAdsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantAdsController>(() => MerchantAdsController());
  }
}
