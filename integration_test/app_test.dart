// Drives the real appuser app through its widget tree (tap by text/icon,
// not screen pixel coordinates) so it works on any simulator/emulator
// without OS-level automation permissions. Collects every FlutterError
// thrown during the walk instead of stopping at the first one, so a
// single crash doesn't hide the rest of the screens' problems.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:vip/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final collectedErrors = <String>[];

  setUpAll(() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      collectedErrors.add(
        '[${DateTime.now().toIso8601String()}] ${details.exceptionAsString()}\n'
        '${details.context}',
      );
      originalOnError?.call(details);
    };
  });

  Future<void> settle(WidgetTester tester, {int seconds = 3}) async {
    await tester.pump(Duration(seconds: seconds));
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    } catch (_) {
      // Some screens have infinite animations (auto-scroll carousels,
      // countdown timers) that never "settle" - that's fine, just move on.
    }
  }

  void mark(String label) {
    // eslint-disable-next-line
    // ignore: avoid_print
    print('\n=== STEP: $label (errors so far: ${collectedErrors.length}) ===');
  }

  void dumpText(String label) {
    final texts = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .where((d) => d != null && d.trim().isNotEmpty)
        .toList();
    // ignore: avoid_print
    print('=== VISIBLE TEXT on $label: $texts ===');
  }

  testWidgets('walk through appuser main screens', (tester) async {
    app.main();
    await settle(tester, seconds: 4);
    mark('app booted');

    // Fresh installs land on Onboarding, not Home - skip through it.
    final skipButton = find.text('Skip');
    if (skipButton.evaluate().isNotEmpty) {
      await tester.tap(skipButton.first, warnIfMissed: false);
      await settle(tester);
      mark('skipped onboarding');
    }

    // Onboarding's last page needs the terms checkbox ticked before
    // "Get Started" will navigate away.
    final acceptCheckbox = find.text('I accept the Terms and Conditions');
    if (acceptCheckbox.evaluate().isNotEmpty) {
      await tester.tap(acceptCheckbox.first, warnIfMissed: false);
      await settle(tester);
      final getStarted = find.text('Get Started');
      if (getStarted.evaluate().isNotEmpty) {
        await tester.tap(getStarted.first, warnIfMissed: false);
        await settle(tester);
        mark('accepted terms, got started');
      }
    }

    // Bypass real login with the guest path so we can reach Home without
    // real credentials.
    final guestButton = find.text('Continue as Guest');
    if (guestButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(guestButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(guestButton.first);
      await settle(tester, seconds: 6);
      mark('logged in as guest');
    }

    // Debug: dump every visible Text widget so we know what screen we're
    // actually on if the expected bottom-nav labels aren't found below.
    final allTexts = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .where((d) => d != null && d.trim().isNotEmpty)
        .toList();
    // ignore: avoid_print
    print('=== VISIBLE TEXT AFTER GUEST LOGIN: $allTexts ===');

    // Search bar
    final searchHint = find.text('What are you looking for?');
    if (searchHint.evaluate().isNotEmpty) {
      await tester.tap(searchHint.first, warnIfMissed: false);
      await settle(tester);
      mark('tapped search bar');
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField).first, 'shoes');
        await settle(tester);
        mark('typed search query "shoes"');
      }
      Get.back();
      await settle(tester);
    } else {
      mark('search bar NOT FOUND');
    }

    final addToCartIcon = find.byIcon(Icons.add_shopping_cart);
    mark('found ${addToCartIcon.evaluate().length} offer cards on Home');
    if (addToCartIcon.evaluate().isNotEmpty) {
      await tester.tap(addToCartIcon.first, warnIfMissed: false);
      await settle(tester);
      mark('added first offer card to cart');
    }

    // Bottom nav tabs (Home / Offers / Digital / Account)
    for (final label in ['Offers', 'Digital', 'Account', 'Home']) {
      final finder = find.text(label);
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first, warnIfMissed: false);
        await settle(tester);
        mark('tapped bottom-nav "$label"');
      } else {
        mark('bottom-nav "$label" NOT FOUND on screen');
      }
    }

    // Digital tab = Bills screen: tap the first bill-type card if present.
    await tester.tap(find.text('Digital'), warnIfMissed: false);
    await settle(tester);
    final billTexts = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .where((d) => d != null && d.trim().isNotEmpty)
        .toList();
    mark('on Digital/Bills tab, visible text: $billTexts');

    // Account tab: try a couple of the service shortcuts.
    await tester.tap(find.text('Account'), warnIfMissed: false);
    await settle(tester);
    for (final label in ['VIPs Club', 'Pay Bill', 'Gifted']) {
      final f = find.text(label);
      if (f.evaluate().isNotEmpty) {
        await tester.tap(f.first, warnIfMissed: false);
        await settle(tester);
        mark('tapped Account shortcut "$label"');
        dumpText('Account shortcut "$label"');
        Get.back();
        await settle(tester);
      } else {
        mark('Account shortcut "$label" NOT FOUND');
      }
    }

    // Settings gear icon on the Profile header.
    final settingsIcon = find.byIcon(Icons.settings_outlined);
    if (settingsIcon.evaluate().isNotEmpty) {
      await tester.tap(settingsIcon.first, warnIfMissed: false);
      await settle(tester);
      mark('opened Settings');
      dumpText('Settings');
      Get.back();
      await settle(tester);
    } else {
      mark('settings icon NOT FOUND');
    }

    // Wallet Points (PIN-gated: default PIN is 0000).
    final walletLabel = find.text('Wallet Points');
    if (walletLabel.evaluate().isNotEmpty) {
      await tester.tap(walletLabel.first, warnIfMissed: false);
      await settle(tester);
      mark('opened PIN screen for Wallet');
      final zeroDigit = find.text('0');
      if (zeroDigit.evaluate().isNotEmpty) {
        for (var i = 0; i < 4; i++) {
          await tester.tap(zeroDigit.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 200));
        }
        await settle(tester);
        mark('entered PIN 0000');
        dumpText('Wallet screen');
        Get.back();
        await settle(tester);
      } else {
        mark('PIN keypad digit "0" NOT FOUND');
      }
    } else {
      mark('"Wallet Points" NOT FOUND');
    }

    await tester.tap(find.text('Home'), warnIfMissed: false);
    await settle(tester);

    // Cart
    final cartIcon = find.byIcon(Icons.shopping_cart_outlined);
    if (cartIcon.evaluate().isNotEmpty) {
      await tester.tap(cartIcon.first, warnIfMissed: false);
      await settle(tester);
      mark('opened Cart');
      dumpText('Cart');

      // Try to increase quantity via a "+" icon if the cart has an item.
      final addIcon = find.byIcon(Icons.add);
      if (addIcon.evaluate().isNotEmpty) {
        await tester.tap(addIcon.first, warnIfMissed: false);
        await settle(tester);
        mark('tapped quantity + in Cart');
        dumpText('Cart after quantity +');
      }

      // Try the Checkout button.
      final checkoutBtn = find.text('Checkout');
      if (checkoutBtn.evaluate().isNotEmpty) {
        await tester.tap(checkoutBtn.first, warnIfMissed: false);
        await settle(tester);
        mark('tapped Checkout');
        dumpText('after tapping Checkout');
        Get.back();
        await settle(tester);
      }

      Get.back();
      await settle(tester);
    } else {
      mark('cart icon NOT FOUND');
    }

    // Notifications
    final bellIcon = find.byIcon(Icons.notifications_none_rounded);
    if (bellIcon.evaluate().isNotEmpty) {
      await tester.tap(bellIcon.first, warnIfMissed: false);
      await settle(tester);
      mark('opened Notifications');
      Get.back();
      await settle(tester);
    } else {
      mark('notifications icon NOT FOUND');
    }

    // Hamburger menu / drawer
    final menuIcon = find.byIcon(Icons.menu_rounded);
    if (menuIcon.evaluate().isNotEmpty) {
      await tester.tap(menuIcon.first, warnIfMissed: false);
      await settle(tester);
      mark('opened drawer/menu');
      // Close it back if it's a drawer overlay.
      if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.close).first, warnIfMissed: false);
      } else {
        Get.back();
      }
      await settle(tester);
    } else {
      mark('menu icon NOT FOUND');
    }

    mark('WALK COMPLETE');

    if (collectedErrors.isNotEmpty) {
      // ignore: avoid_print
      print('\n\n########## COLLECTED FLUTTER ERRORS (${collectedErrors.length}) ##########');
      for (var i = 0; i < collectedErrors.length; i++) {
        // ignore: avoid_print
        print('\n--- error #$i ---\n${collectedErrors[i]}');
      }
      // ignore: avoid_print
      print('##########################################################\n');
    }
  });
}
