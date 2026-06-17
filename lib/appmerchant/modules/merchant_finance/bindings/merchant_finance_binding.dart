import 'package:get/get.dart';
import '../controllers/merchant_finance_controller.dart';

class MerchantFinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantFinanceController>(() => MerchantFinanceController());
  }
}
