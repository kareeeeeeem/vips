import 'package:get/get.dart';
import '../controllers/merchant_catalog_controller.dart';

class MerchantCatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantCatalogController>(() => MerchantCatalogController());
  }
}
