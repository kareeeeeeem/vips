import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routes/admin_pages.dart';
import 'core/routes/admin_routes.dart';
import 'core/theme/admin_theme.dart';
import 'core/widgets/admin_top_bar.dart';
import 'modules/auth/controllers/admin_auth_controller.dart';
import 'package:vip/appuser/core/translations/app_translations.dart';
import 'package:vip/core/services/analytics_service.dart';
import 'package:vip/core/services/api_service.dart';

/// Entry point for the VIPs admin console.
///
/// Sits beside `main.dart` (consumer) and `main_merchant.dart` (merchant) —
/// three entrypoints over one codebase. Run with:
///   flutter run -t lib/admin/main_admin.dart            (web / desktop)
///   flutter run --flavor admin -t lib/admin/main_admin.dart   (Android)
///
/// No Firebase here on purpose: the console signs in with email + password
/// against `/api/admin/login` only. Google/Facebook/Apple sign-in exists for
/// customers and merchants, and initialising Firebase for an app that never
/// calls it would just be one more thing that can fail at launch.
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Point the console at a different backend without editing code:
    //   flutter run -t lib/admin/main_admin.dart \
    //     --dart-define=API_BASE_URL=http://localhost:3000/api
    // Must be set before ApiService's singleton is first constructed, since
    // Dio captures the base URL at construction. Defaults to production.
    const overrideBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideBaseUrl.isNotEmpty) {
      ApiService.baseUrl = overrideBaseUrl;
      debugPrint('[ADMIN] API base URL overridden: $overrideBaseUrl');
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put(sharedPreferences);

    // Load any persisted token so a returning admin lands on the dashboard
    // rather than the login screen.
    await ApiService().init();
    // Anonymous screen counting, same service the other apps use, tagged so
    // the console can tell the three apart.
    await AnalyticsService().init(app: 'admin');

    // A 401 anywhere in the console must return to the admin login, not the
    // consumer app's '/login' (which does not exist in this route table).
    ApiService.unauthorizedRoute = AdminRoutes.LOGIN;

    // Permanent: the drawer, the top bar and Settings all read the signed-in
    // admin, so these must outlive any single route. The top-bar controller
    // holds the notification count shown on every screen.
    Get.put(AdminAuthController(), permanent: true);
    Get.put(AdminTopBarController(), permanent: true);

    runApp(const AdminApp());
  }, (error, stack) {
    debugPrint('[runZonedGuarded] Unhandled error: $error\n$stack');
  });
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The console runs on a phone (the `admin` Android flavor) and on a
    // desktop browser. flutter_screenutil scales everything by
    // width / designSize.width, so a single 375pt phone design blows up ~4x
    // on a 1500px window — every control ends up comically large. Pick the
    // design size from the actual window instead: phone-sized below 600px,
    // desktop-sized above it, so the scale factor stays near 1 either way.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        return ScreenUtilInit(
          designSize: isWide ? const Size(1280, 800) : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'VIPs Admin',
              initialRoute: AdminPages.INITIAL,
              getPages: AdminPages.routes,
              navigatorObservers: [AnalyticsRouteObserver()],
              translations: AppTranslations(),
              locale: Get.deviceLocale,
              fallbackLocale: const Locale('en', 'US'),
              theme: AdminTheme.light,
              // The console is a single-purpose operator tool, so it stays on
              // one light theme rather than following the device — a
              // half-finished dark palette would be worse than none.
              themeMode: ThemeMode.light,
            );
          },
        );
      },
    );
  }
}
