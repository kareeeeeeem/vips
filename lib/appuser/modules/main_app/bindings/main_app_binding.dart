import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/main_app_controller.dart';

class MainAppBinding extends Bindings {
  @override
  void dependencies() {
    // Signing in from a pushed login screen replaces an existing main route.
    // GetX may dispose its controllers after the replacement is constructed;
    // retain factories so the new route can resolve fresh instances.
    Get.lazyPut<MainAppController>(() => MainAppController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
