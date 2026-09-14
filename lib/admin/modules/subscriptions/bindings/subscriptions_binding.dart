import 'package:get/get.dart';
import '../controllers/subscriptions_controller.dart';

class AdminSubscriptionsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AdminSubscriptionsController());
}
