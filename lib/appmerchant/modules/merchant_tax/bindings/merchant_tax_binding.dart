import 'package:get/get.dart';
import '../controllers/merchant_tax_controller.dart';

class MerchantTaxBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantTaxController>(() => MerchantTaxController());
  }
}
