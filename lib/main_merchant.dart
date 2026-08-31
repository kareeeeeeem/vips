import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appuser/core/translations/app_translations.dart';
import 'appmerchant/routes/merchant_pages.dart';
import 'appmerchant/routes/merchant_routes.dart';
import 'core/services/analytics_service.dart';
import 'core/services/api_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // No explicit `options:` here — the merchant flavor ships its own native
    // google-services.json / GoogleService-Info.plist (com.vips.merchant),
    // which FlutterFire reads automatically. Passing DefaultFirebaseOptions
    // (generated for the consumer app, com.vips.app) would override that.
    await Firebase.initializeApp();
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put(sharedPreferences);

    // Load saved auth token so all API calls include the Authorization header
    await ApiService().init();
    // Anonymous screen counting, same service the other apps use, tagged so
    // the console can tell the three apart.
    await AnalyticsService().init(app: 'merchant');
    // Route unauthenticated users to the merchant login screen
    ApiService.unauthorizedRoute = MerchantRoutes.LOGIN;

    runApp(const MerchantApp());
  }, (error, stack) {
    debugPrint('[runZonedGuarded] Unhandled error: $error\n$stack');
  });
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
          navigatorObservers: [AnalyticsRouteObserver()],
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
