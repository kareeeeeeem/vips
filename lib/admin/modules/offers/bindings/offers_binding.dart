import 'package:get/get.dart';

import '../controllers/offers_controller.dart';

class AdminOffersBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AdminOffersController());
}
