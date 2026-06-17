import 'package:get/get.dart';
import '../controllers/merchant_asset_controller.dart';

class MerchantAssetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantAssetController>(() => MerchantAssetController());
  }
}
