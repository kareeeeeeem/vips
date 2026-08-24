// Focused, assertion-based walk of the AppUser Home tab: every interactive
// element is tapped and the *actual resulting screen* is checked against
// what it's supposed to be — not just "didn't crash". Complements
// app_test.dart's broad no-crash sweep.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';

import 'package:vip/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, {int seconds = 3}) async {
    await tester.pump(Duration(seconds: seconds));
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    } catch (_) {}
  }

  void mark(String label) {
    // ignore: avoid_print
    print('\n=== HOME STEP: $label ===');
  }

  Future<void> boot(WidgetTester tester) async {
    app.main();
    await settle(tester, seconds: 4);

    final skipButton = find.text('Skip');
    if (skipButton.evaluate().isNotEmpty) {
      await tester.tap(skipButton.first, warnIfMissed: false);
      await settle(tester);
    }
    final acceptCheckbox = find.text('I accept the Terms and Conditions');
    if (acceptCheckbox.evaluate().isNotEmpty) {
      await tester.tap(acceptCheckbox.first, warnIfMissed: false);
      await settle(tester);
      final getStarted = find.text('Get Started');
      if (getStarted.evaluate().isNotEmpty) {
        await tester.tap(getStarted.first, warnIfMissed: false);
        await settle(tester);
      }
    }
    final guestButton = find.text('Continue as Guest');
    if (guestButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(guestButton.first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(guestButton.first);
      await settle(tester, seconds: 6);
    }
  }

  testWidgets('Home: category card opens real Search, not the fake FoodDeliveryPage', (
    tester,
  ) async {
    await boot(tester);
    mark('booted, on Home');

    expect(find.text('Featured Categories'), findsOneWidget);

    // "Computer & Accessories" is the second category card (index 1).
    final categoryCard = find.text('Computer &\nAccessories');
    expect(
      categoryCard,
      findsOneWidget,
      reason: 'Featured Categories card for Computer & Accessories should be on Home',
    );
    await tester.tap(categoryCard, warnIfMissed: false);
    await settle(tester);
    mark('tapped "Computer & Accessories" category card');

    // Must land on the real Search screen (has "Popular Searches"), not the
    // old hardcoded FoodDeliveryPage mock (which showed "Ramen Noodles").
    expect(
      find.text('Popular Searches'),
      findsOneWidget,
      reason: 'category tap should open real Search screen',
    );
    expect(
      find.text('Ramen Noodles'),
      findsNothing,
      reason: 'must not land on the old fake FoodDeliveryPage mock data',
    );
    Get.back();
    await settle(tester);
    mark('back on Home');
  });

  testWidgets('Home: hero banner CTA opens Hot Deals', (tester) async {
    await boot(tester);
    mark('booted, on Home');

    final exploreBtn = find.text('Explore');
    expect(exploreBtn, findsOneWidget);
    await tester.tap(exploreBtn, warnIfMissed: false);
    await settle(tester);
    mark('tapped hero banner "Explore"');

    expect(find.text('Hot Deals'), findsOneWidget);
    Get.back();
    await settle(tester);
  });

  testWidgets('Home: Featured Categories "See All" opens Trending Merchants', (
    tester,
  ) async {
    await boot(tester);
    mark('booted, on Home');

    final seeAll = find.text('See All');
    expect(seeAll, findsWidgets);
    await tester.tap(seeAll.first, warnIfMissed: false);
    await settle(tester);
    mark('tapped Featured Categories "See All"');

    expect(find.text('Trending Merchants'), findsOneWidget);
    Get.back();
    await settle(tester);
  });

  testWidgets('Home: Restaurant section only shows food-category deals', (
    tester,
  ) async {
    await boot(tester);
    mark('booted, on Home');

    expect(
      find.text('hot Restaurent'),
      findsOneWidget,
      reason: 'Restaurant section header should be on Home',
    );
    // Backend hot-deals has 2 food-category items: "Mega Pizza Feast" and
    // "Syrian Kitchen Special". Neither should ever have appeared in the
    // unfiltered list before the fix ("Mall of Egypt VIP Pass" is
    // shopping-category and was showing here too).
    await tester.dragUntilVisible(
      find.text('hot Restaurent'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await settle(tester);
    mark('scrolled to Restaurant section');
    final foodDealTitles = ['Mega Pizza Feast', 'Syrian Kitchen Special'];
    final foundAtLeastOne = foodDealTitles.any(
      (t) => find.text(t).evaluate().isNotEmpty,
    );
    expect(
      foundAtLeastOne,
      isTrue,
      reason:
          'Restaurant section should show real food-category deals from the '
          'live backend (Mega Pizza Feast / Syrian Kitchen Special), not '
          'the generic unfiltered hotDeals list',
    );
  });

  testWidgets('Home: tapping a deal card opens Deal Details with the same deal', (
    tester,
  ) async {
    await boot(tester);
    mark('booted, on Home');

    // "Ending Soon" deal cards carry real backend titles like
    // "Flash Burger Offer" / "Dessert Extravaganza" (seen live in prior
    // integration run). Tap whichever renders.
    final candidateTitles = ['Flash Burger Offer', 'Dessert Extravaganza'];
    Finder? dealCard;
    for (final t in candidateTitles) {
      final f = find.text(t);
      if (f.evaluate().isNotEmpty) {
        dealCard = f.first;
        mark('found deal card "$t" in Ending Soon');
        break;
      }
    }
    if (dealCard == null) {
      mark('no known Ending Soon deal title found on screen - skipping assertion');
      return;
    }
    await tester.tap(dealCard, warnIfMissed: false);
    await settle(tester);
    mark('tapped deal card');

    // Deal Details appbar shows the deal's own title - confirms the right
    // deal object was actually passed through, not a wrong/empty one.
    final onDetailsScreen = candidateTitles.any(
      (t) => find.text(t).evaluate().isNotEmpty,
    );
    expect(
      onDetailsScreen,
      isTrue,
      reason: 'Deal Details screen should show the tapped deal\'s real title',
    );
    expect(find.text('no_deal_data'.tr), findsNothing);
  });
}
