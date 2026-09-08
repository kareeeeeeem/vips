import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/appuser/modules/home/views/widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/splash/views/splash_view.dart';
import 'package:vip/main.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/profile/controllers/profile_controller.dart';
import 'package:vip/appuser/modules/profile/views/profile_view.dart';

class _LayoutProfileController extends ProfileController {
  @override
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('profile order filters fit a narrow phone and remain tappable', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);
    final profile = Get.put<ProfileController>(_LayoutProfileController());
    profile.isLoading.value = false;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const GetMaterialApp(home: ProfileView()),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Active'), 200,
        scrollable: find.byType(Scrollable).first);
    for (final label in ['Active', 'Done', 'Refunded']) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
      expect(profile.selectedOrderFilter.value, label);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('consumer navigation renders and dispatches all five actions', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final selected = <int>[];
    var walletOpened = false;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(home: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: 0, onTap: selected.add,
          onScanTap: () => walletOpened = true,
        ),
      )),
    ));
    for (final label in ['Home', 'Offers', 'Digital', 'Account']) {
      expect(find.text(label), findsOneWidget);
      await tester.tap(find.text(label));
    }
    await tester.tap(find.byIcon(Icons.account_balance_wallet_rounded));
    expect(selected, [0, 1, 2, 3]);
    expect(walletOpened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('App boots, shows the splash screen, then navigates away', (
    WidgetTester tester,
  ) async {
    // Use a real phone-sized surface — the design's fixed-size layouts
    // overflow on the default 800x600 test surface.
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.light));
    await tester.pump();

    expect(find.byType(SplashView), findsOneWidget);

    // Let the splash timer (2s) fire and the route change settle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SplashView), findsNothing);
  });
}
