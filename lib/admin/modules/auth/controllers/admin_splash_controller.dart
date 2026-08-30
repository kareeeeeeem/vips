import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import 'admin_auth_controller.dart';

/// Adapted from the consumer app's `SplashController`.
///
/// Same shape — brief animation, then one decision — but the check is
/// different: the consumer app asks "is there a token, and has a PIN been
/// set?", while the console asks "does this token still belong to a live
/// admin?". A customer token sitting in shared storage must not be treated
/// as a console session.
class AdminSplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer(const Duration(milliseconds: 1400), _decide);
  }

  Future<void> _decide() async {
    try {
      final auth = Get.find<AdminAuthController>();
      final restored = await auth.restoreSession();
      Get.offAllNamed(restored ? AdminRoutes.DASHBOARD : AdminRoutes.LOGIN);
    } catch (e) {
      debugPrint('[ADMIN SPLASH] session check failed: $e');
      Get.offAllNamed(AdminRoutes.LOGIN);
    }
  }

  @override
  void onClose() {
    // Without this, a hot restart mid-timer fires a navigation into a
    // disposed route.
    _timer?.cancel();
    super.onClose();
  }
}
