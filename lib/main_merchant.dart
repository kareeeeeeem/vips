import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appuser/core/translations/app_translations.dart';
import 'appmerchant/routes/merchant_pages.dart';
import 'appmerchant/routes/merchant_routes.dart';
import 'core/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences);

  // Load saved auth token so all API calls include the Authorization header
  await ApiService().init();
  // Route unauthenticated users to the merchant login screen
  ApiService.unauthorizedRoute = MerchantRoutes.LOGIN;

  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "VIPs Merchant",
          initialRoute: MerchantAppPages.INITIAL,
          getPages: MerchantAppPages.routes,
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          theme: ThemeData(
            primarySwatch: Colors.green,
            useMaterial3: true,
            fontFamily: 'SF Pro Display',
          ),
        );
      },
    );
  }
}
