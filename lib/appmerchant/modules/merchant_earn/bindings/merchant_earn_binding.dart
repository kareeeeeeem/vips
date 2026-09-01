import 'package:get/get.dart';

import '../controllers/merchant_earn_controller.dart';

class MerchantEarnBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MerchantEarnController());
}
