import 'package:get/get.dart';
import '../controllers/merchant_stock_controller.dart';

class MerchantStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantStockController>(() => MerchantStockController());
  }
}
