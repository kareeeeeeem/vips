import 'package:get/get.dart';

import '../controllers/v_i_ps_club_controller.dart';

class VIPsClubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VIPsClubController>(
      () => VIPsClubController(),
    );
  }
}
