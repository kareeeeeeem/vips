import 'package:get/get.dart';
import '../controllers/ads_controller.dart';

class AdminAdsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AdminAdsController());
}
