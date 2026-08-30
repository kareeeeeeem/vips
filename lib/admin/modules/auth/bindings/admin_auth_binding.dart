import 'package:get/get.dart';

import '../controllers/admin_splash_controller.dart';

/// [AdminAuthController] is registered permanently in `main_admin.dart` (the
/// drawer and top bar read it on every screen), so only the splash's own
/// short-lived controller is bound here.
class AdminSplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager `put`, not `lazyPut`: AdminSplashView is a pure visual — it never
    // reads `controller`, so nothing would ever call Get.find() to trigger a
    // lazy construction, its onInit would never run, and the splash would sit
    // there forever instead of routing on to Login or the Dashboard.
    Get.put<AdminSplashController>(AdminSplashController());
  }
}
