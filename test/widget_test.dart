import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/splash/views/splash_view.dart';
import 'package:vip/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
