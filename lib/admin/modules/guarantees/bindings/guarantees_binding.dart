import 'package:get/get.dart';

import '../controllers/guarantees_controller.dart';

class GuaranteesBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => GuaranteesController());
}
