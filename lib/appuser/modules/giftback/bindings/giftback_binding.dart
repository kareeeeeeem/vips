import 'package:get/get.dart';

import '../controllers/giftback_controller.dart';

class GiftbackBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => GiftbackController());
}
