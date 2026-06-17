import 'package:get/get.dart';
import '../controllers/merchant_dues_controller.dart';

class MerchantDuesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantDuesController>(() => MerchantDuesController());
  }
}
