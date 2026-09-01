import 'package:get/get.dart';

import '../controllers/merchant_guarantee_controller.dart';

class MerchantGuaranteeBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MerchantGuaranteeController());
}
