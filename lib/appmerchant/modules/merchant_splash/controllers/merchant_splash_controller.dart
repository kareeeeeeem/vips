import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/core/util/app_constants.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class MerchantSplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginState();
  }

  void _checkLoginState() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.token);
    
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(MerchantRoutes.HOME);
    } else {
      Get.offAllNamed(MerchantRoutes.ONBOARDING);
    }
  }
}
