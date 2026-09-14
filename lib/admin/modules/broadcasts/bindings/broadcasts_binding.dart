import 'package:get/get.dart';
import '../controllers/broadcasts_controller.dart';

class AdminBroadcastsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBroadcastsController>(() => AdminBroadcastsController());
  }
}
