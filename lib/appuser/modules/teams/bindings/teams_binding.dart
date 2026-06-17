import 'package:get/get.dart';

import '../controllers/teams_controller.dart';

class TeamsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamsController>(
      () => TeamsController(),
    );
  }
}
