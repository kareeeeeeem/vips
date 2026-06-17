import 'package:get/get.dart';
import '../../merchant_auth/controllers/merchant_auth_controller.dart';
import '../controllers/merchant_home_controller.dart';

class MerchantHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantHomeController>(() => MerchantHomeController());
    Get.lazyPut<MerchantAuthController>(() => MerchantAuthController());
  }
}
