// Device exploration against the disposable database started by
// lib/vips-backend/tests/run-isolated.js --ui. No production credentials.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:vip/main_merchant.dart' as app;
import 'package:vip/core/services/api_service.dart';
import 'package:vip/appmerchant/routes/merchant_pages.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const token = String.fromEnvironment('QA_TOKEN');
  const baseUrl = String.fromEnvironment('API_BASE_URL');
  final records = <Map<String, dynamic>>[];

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  void record(Map<String, dynamic> data) {
    records.add(data);
    // Structured output can be extracted without saving any auth tokens.
    // ignore: avoid_print
    print('UI_ACTION ${jsonEncode(data)}');
  }

  Object? arguments(String route) => null;

  testWidgets('merchant buttons on the iOS simulator', (tester) async {
    record({'kind': 'run', 'harnessVersion': 2});
    expect(Uri.parse(baseUrl).host, anyOf('127.0.0.1', 'localhost'));
    expect(token, isNotEmpty, reason: 'Start the disposable UI backend first');
    SharedPreferences.setMockInitialValues({'auth_token': token, 'token': token});
    app.main();
    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    Get.offAllNamed('/merchant-home');
    await settle(tester);

    final errors = <String>[];
    final interactionFailures = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details.exceptionAsString());
      record({'kind': 'flutter_error', 'route': Get.currentRoute,
        'message': details.exceptionAsString(),
        'context': details.context?.toDescription()});
    };
    addTearDown(() => FlutterError.onError = original);

    Future<void> openRoute(String route) async {
      await ApiService().setToken(token);
      for (final element in find.byType(Scaffold).evaluate()) {
        final state = (element as StatefulElement).state as ScaffoldState;
        if (state.isDrawerOpen) state.closeDrawer();
        if (state.isEndDrawerOpen) state.closeEndDrawer();
      }
      await settle(tester);
      Get.until((r) => r.settings.name == '/merchant-home' || r.isFirst);
      await settle(tester);
      if (Get.currentRoute != '/merchant-home') {
        Get.offAllNamed('/merchant-home');
        await settle(tester);
      }
      if (route != '/merchant-home') {
        Get.toNamed(route, arguments: arguments(route));
        await settle(tester);
      }
    }

    // These require a provider/device capability or flow-specific arguments;
    // recording them prevents an excluded screen being counted as passed.
    const excluded = {
      '/merchant-splash', '/merchant-home', '/merchant-verification',
      '/merchant-order-detail', '/bill-pin', '/bill-scan-me', '/invoice-receipt',
      '/gift-back-pin', '/gift-back-status', '/gift-back-scan-me',
    };
    const requestedRoutes = String.fromEnvironment('QA_ROUTES');
    final routes = requestedRoutes.isNotEmpty
        ? requestedRoutes.split(',')
        : ['/merchant-home', ...MerchantAppPages.routes.map((p) => p.name)
            .where((name) => !excluded.contains(name))];

    for (final route in routes) {
      try {
        await openRoute(route);
        record({'kind': 'screen', 'route': route, 'actualRoute': Get.currentRoute,
          'text': find.byType(Text).evaluate().map((e) => (e.widget as Text).data)
              .whereType<String>().take(60).toList()});

        // Button widgets plus app-specific GestureDetector/InkWell controls.
        // Ignore the implementation recognizers nested inside another button.
        bool interactive(Widget w) =>
          w is ButtonStyleButton && w.onPressed != null ||
          w is IconButton && w.onPressed != null ||
          w is InkWell && w.onTap != null ||
          w is GestureDetector && w.onTap != null ||
          w is Switch && w.onChanged != null ||
          w is Checkbox && w.onChanged != null;
        List<Element> controls() => find.byWidgetPredicate(interactive).evaluate()
          .where((e) {
            // A heart/add button inside a tappable card has its own action.
            // Only discard gesture recognizers implementing another button,
            // not independently interactive children of a card.
            if (e.widget is! GestureDetector && e.widget is! InkWell) return true;
            var nested = false;
            e.visitAncestorElements((a) {
              if (a.widget is ButtonStyleButton || a.widget is IconButton ||
                  a.widget is Switch || a.widget is Checkbox || a.widget is InkWell) {
                nested = true;
                return false;
              }
              return true;
            });
            return !nested;
          }).toList();

        final count = controls().length;
        for (var index = 0; index < count; index++) {
          if (index > 0) await openRoute(route);
          final candidates = controls();
          if (index >= candidates.length) {
            record({'kind': 'unavailable', 'route': route, 'index': index});
            continue;
          }
          final element = candidates[index];
          final finder = find.byElementPredicate((e) => identical(e, element));
          final texts = <String>[];
          void collect(Element e) {
            final widget = e.widget;
            if (widget is Text && widget.data != null) texts.add(widget.data!);
            if (widget is IconButton && widget.tooltip != null) texts.add(widget.tooltip!);
            if (widget is Icon) texts.add('icon:${widget.icon?.codePoint}');
            e.visitChildren(collect);
          }
          collect(element);
          final label = texts.join(' | ');
          // Never confirm external dialogs, delete the shared fixture account,
          // or invoke an OS auth/share surface from the exploratory walker.
          if ((route == '/merchant-login' && label.isEmpty) ||
              RegExp('Delete Account|Google|Facebook|Apple|Biometric|Share', caseSensitive: false).hasMatch(label)) {
            record({'kind': 'requires_external_or_dedicated_flow', 'route': route, 'index': index, 'label': label});
            continue;
          }
          try {
            await tester.ensureVisible(finder);
            await settle(tester);
            if (finder.hitTestable().evaluate().isEmpty) {
              record({'kind': 'not_hittable', 'route': route, 'index': index, 'label': label});
              continue;
            }
            final beforeErrors = errors.length;
            await tester.tap(finder);
            await settle(tester);
            record({'kind': errors.length == beforeErrors ? 'tapped' : 'tap_error',
              'route': route, 'index': index, 'label': label,
              'resultRoute': Get.currentRoute,
              'dialog': Get.isDialogOpen == true, 'sheet': Get.isBottomSheetOpen == true});
          } catch (error) {
            interactionFailures.add('$route [$index]: $error');
            record({'kind': 'tap_error', 'route': route, 'index': index,
              'label': label, 'message': error.toString()});
          }
        }
      } catch (error) {
        interactionFailures.add('$route: $error');
        record({'kind': 'screen_error', 'route': route, 'message': error.toString()});
      }
    }
    await openRoute('/merchant-home');
    record({'kind': 'summary', 'records': records.length, 'flutterErrors': errors.length,
      'note': 'A dispatched tap is exploratory coverage, not proof of its business outcome.'});
    FlutterError.onError = original;
    expect(errors, isEmpty, reason: 'Fix all runtime errors found during exploration');
    expect(interactionFailures, isEmpty, reason: 'Resolve failed route and gesture interactions');
  }, timeout: const Timeout(Duration(minutes: 40)));
}
