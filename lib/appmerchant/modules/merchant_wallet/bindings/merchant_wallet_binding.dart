import 'package:get/get.dart';
import '../controllers/merchant_wallet_controller.dart';

class MerchantWalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantWalletController>(() => MerchantWalletController());
  }
}
