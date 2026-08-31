import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add this import
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appuser/core/translations/app_translations.dart';
import 'appuser/routes/app_pages.dart';
import 'core/services/analytics_service.dart';
import 'core/services/api_service.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Point the app at a different backend without editing code:
    //   flutter run -t lib/main.dart \
    //     --dart-define=API_BASE_URL=http://localhost:3000/api
    // Must be set before ApiService's singleton is first constructed, since
    // Dio captures the base URL at construction. Defaults to production.
    const overrideBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideBaseUrl.isNotEmpty) {
      ApiService.baseUrl = overrideBaseUrl;
      debugPrint('[APP] API base URL overridden: $overrideBaseUrl');
    }

    await ApiService().init();
    // Anonymous screen counting. Nothing here can stop the app booting: the
    // service swallows its own failures and reports nothing if it cannot
    // read the preference.
    await AnalyticsService().init(app: 'consumer');
    // Read the persisted dark-mode preference (written by SettingsController)
    // before the first frame, so the app boots straight into the right theme
    // instead of always starting light until the user revisits Settings.
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('settings_dark_mode') ?? false;
    runApp(MyApp(initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }, (error, stack) {
    debugPrint('[runZonedGuarded] Unhandled error: $error\n$stack');
  });
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Application",
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          // One observer rather than a call in every screen's onInit — a
          // tracker each screen must remember to call misses exactly the
          // screens somebody forgot.
          navigatorObservers: [AnalyticsRouteObserver()],
          translations: AppTranslations(),
          locale: Get.deviceLocale,
          fallbackLocale: Locale('en', 'US'),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: initialThemeMode,
        );
      },
    );
  }
}
