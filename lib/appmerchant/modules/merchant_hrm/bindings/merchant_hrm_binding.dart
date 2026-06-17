import 'package:get/get.dart';
import '../controllers/merchant_hrm_controller.dart';

class MerchantHRMBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantHRMController>(() => MerchantHRMController());
  }
}
