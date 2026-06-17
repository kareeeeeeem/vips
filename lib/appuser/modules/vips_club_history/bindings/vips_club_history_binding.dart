import 'package:get/get.dart';

import '../controllers/vips_club_history_controller.dart';

class VipsClubHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VipsClubHistoryController>(
      () => VipsClubHistoryController(),
    );
  }
}
