import 'package:get/get.dart';

import '../controllers/merchant_report_controller.dart';

class MerchantReportBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MerchantReportController());
}
