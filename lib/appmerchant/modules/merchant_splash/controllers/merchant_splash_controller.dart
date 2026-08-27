import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/core/util/app_constants.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';

class MerchantSplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginState();
  }

  void _checkLoginState() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      await ApiService().init();

      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString(AppConstants.token);

      // ApiService.init() only loads its own 'auth_token' key. A merchant who
      // signed in before that key existed (or through the Orders module's
      // ApiClient) may only have the AppConstants.token copy — adopt it so
      // both clients agree on one token instead of one of them silently
      // running unauthenticated.
      if (!ApiService().isLoggedIn && legacyToken != null && legacyToken.isNotEmpty) {
        await ApiService().setToken(legacyToken);
      }

      if (!ApiService().isLoggedIn) {
        Get.offAllNamed(MerchantRoutes.ONBOARDING);
        return;
      }

      // A token being present is not the same as it being valid: an expired or
      // revoked token used to land the merchant on the dashboard, where every
      // request 401s and the screen just looks broken. Verify it against the
      // real profile endpoint before deciding.
      final response = await ApiService().get('/merchant/profile');
      final isMerchant = response.success &&
          response.data is Map &&
          (response.data['role'] == 'merchant');

      if (isMerchant) {
        Get.offAllNamed(MerchantRoutes.HOME);
        return;
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        // Token is dead — drop both copies so the next launch starts clean.
        await ApiService().clearToken();
        await prefs.remove(AppConstants.token);
        Get.offAllNamed(MerchantRoutes.LOGIN);
        return;
      }

      // Network/server trouble rather than a bad token: keep the session and
      // let the dashboard's own retry/error handling take over.
      Get.offAllNamed(MerchantRoutes.HOME);
    } catch (e) {
      Get.log('Error in MerchantSplashController: $e');
      Get.offAllNamed(MerchantRoutes.ONBOARDING);
    }
  }
}
