import 'package:get/get.dart';
import '../controllers/merchant_notifications_controller.dart';

class MerchantNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MerchantNotificationsController>(
        () => MerchantNotificationsController());
  }
}
