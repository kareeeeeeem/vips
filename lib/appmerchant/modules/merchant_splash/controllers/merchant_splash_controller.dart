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
      final token = prefs.getString(AppConstants.token) ?? prefs.getString('auth_token');

      if (ApiService().isLoggedIn || (token != null && token.isNotEmpty)) {
        Get.offAllNamed(MerchantRoutes.HOME);
      } else {
        Get.offAllNamed(MerchantRoutes.ONBOARDING);
      }
    } catch (e) {
      Get.log('Error in MerchantSplashController: $e');
      Get.offAllNamed(MerchantRoutes.ONBOARDING);
    }
  }
}
