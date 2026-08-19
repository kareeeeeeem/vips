// Unit tests for the pure/testable business logic in the appuser "social"
// GetX controllers: history formatting, spin-wheel prize data, QR-scanner
// guard clauses, recent-search bookkeeping, settings toggles, team
// filtering, VIPs club guard clauses/check-in seed data, and notification
// filtering/mapping.
//
// Pattern (matches test/appuser_business_logic_test.dart): controllers are
// constructed directly (never Get.put/onInit) so their network-calling /
// hardware-touching onInit() bodies never run — we drive the reactive
// fields and pure getters/methods directly instead. Guard-clause methods
// that are `async` but return *before* their first `await` (e.g. because
// remainingSpins is 0) are safe to call without awaiting, since the whole
// guarded body executes synchronously up to the early `return`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vip/appuser/modules/vips_club_history/controllers/vips_club_history_controller.dart';
import 'package:vip/appuser/modules/contact/controllers/contact_controller.dart';
import 'package:vip/appuser/modules/spin_wheel/controllers/spin_wheel_controller.dart';
import 'package:vip/appuser/modules/QR_scanner/controllers/q_r_scanner_controller.dart';
import 'package:vip/appuser/modules/search/controllers/search_controller.dart'
    as app_search;
import 'package:vip/appuser/modules/settings/controllers/settings_controller.dart';
import 'package:vip/appuser/modules/vIPsClub/controllers/v_i_ps_club_controller.dart';
import 'package:vip/appuser/modules/notifications/controllers/notifications_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════
  // VipsClubHistoryController
  // ═══════════════════════════════════════════════════════════
  group('VipsClubHistoryController', () {
    late VipsClubHistoryController c;

    setUp(() {
      c = VipsClubHistoryController();
    });

    test('default state: no diamonds, no transactions, not loading', () {
      expect(c.convertibleDiamants.value, equals(0));
      expect(c.isLoading.value, isFalse);
      expect(c.transactions, isEmpty);
    });

    test('formatDate pads day/hour/minute and abbreviates the month', () {
      expect(
        c.formatDate(DateTime(2025, 10, 27, 16, 13)),
        equals('27 Oct 2025 16:13'),
      );
    });

    test('formatDate zero-pads single-digit day/hour/minute', () {
      expect(
        c.formatDate(DateTime(2026, 1, 5, 9, 5)),
        equals('05 Jan 2026 09:05'),
      );
    });

    test('formatDate covers December correctly', () {
      expect(
        c.formatDate(DateTime(2025, 12, 31, 23, 59)),
        equals('31 Dec 2025 23:59'),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ContactController
  // ═══════════════════════════════════════════════════════════
  group('ContactController', () {
    late ContactController c;

    setUp(() {
      c = ContactController();
    });

    test('default state', () {
      expect(c.contacts, isEmpty);
      expect(c.isLoading.value, isFalse);
      expect(c.filterType.value, equals('all'));
      expect(c.newContactName.value, isEmpty);
      expect(c.newContactPhone.value, isEmpty);
    });

    test('contacts list can be populated and cleared', () {
      c.contacts.addAll([
        {'name': 'Alice'},
        {'name': 'Bob'},
      ]);
      expect(c.contacts.length, equals(2));
      c.contacts.clear();
      expect(c.contacts, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // SpinWheelController
  // ═══════════════════════════════════════════════════════════
  group('SpinWheelController', () {
    late SpinWheelController c;

    setUp(() {
      c = SpinWheelController();
    });

    test('prizes contains the 8 expected sections with correct values', () {
      expect(c.prizes.length, equals(8));
      final byName = {for (final p in c.prizes) p.name: p.value};
      expect(byName['Money Bag'], equals(100));
      expect(byName['Trending Up'], equals(200));
      expect(byName['Offer'], equals(50));
      expect(byName['Gold Coin'], equals(500));
      expect(byName['Cash'], equals(150));
      expect(byName['Bank'], equals(300));
      expect(byName['Payment'], equals(75));
      expect(byName['Gift'], equals(1000));
    });

    test('default spin state: 3 remaining, not spinning, canSpin true', () {
      expect(c.remainingSpins.value, equals(3));
      expect(c.isSpinning.value, isFalse);
      expect(c.canSpin.value, isTrue);
      expect(c.rotation.value, equals(0.0));
      expect(c.wonPrize.value, isNull);
    });

    test('spinWheel is a no-op when remainingSpins is 0', () {
      c.remainingSpins.value = 0;
      c.spinWheel();
      expect(c.isSpinning.value, isFalse);
      expect(c.remainingSpins.value, equals(0));
    });

    test('spinWheel is a no-op when already spinning', () {
      c.isSpinning.value = true;
      c.spinWheel();
      expect(c.remainingSpins.value, equals(3));
    });

    test('spinWheel is a no-op when canSpin is false', () {
      c.canSpin.value = false;
      c.spinWheel();
      expect(c.isSpinning.value, isFalse);
      expect(c.remainingSpins.value, equals(3));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // QRScannerController
  // ═══════════════════════════════════════════════════════════
  group('QRScannerController', () {
    late QRScannerController c;

    setUp(() {
      c = QRScannerController();
    });

    test('default scanner state', () {
      expect(c.isFlashOn.value, isFalse);
      expect(c.scannedCode.value, isEmpty);
      expect(c.isScanning.value, isTrue);
    });

    test('handleBarcode ignores an empty barcode capture', () {
      c.handleBarcode(const BarcodeCapture());
      expect(c.scannedCode.value, isEmpty);
      expect(c.isScanning.value, isTrue);
    });

    test('handleBarcode ignores captures while not scanning', () {
      c.isScanning.value = false;
      c.handleBarcode(const BarcodeCapture());
      expect(c.scannedCode.value, isEmpty);
      expect(c.isScanning.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // SearchController — recent-search bookkeeping & filter defaults
  // (server-side search itself is out of scope: it goes through
  // ApiService().get, so only the pure local state is exercised here)
  // ═══════════════════════════════════════════════════════════
  group('SearchController', () {
    late app_search.SearchController c;

    setUp(() {
      c = app_search.SearchController();
    });

    test('recentSearches starts empty; popularSearches has the seed data',
        () {
      expect(c.recentSearches, isEmpty);
      expect(
        c.popularSearches,
        equals(['Fast Food', 'Pizza', 'Burgers', 'Shopping', 'Entertainment']),
      );
    });

    test('addToRecent inserts at the front', () {
      c.addToRecent('Sushi Place');
      expect(c.recentSearches.first, equals('Sushi Place'));
    });

    test('addToRecent de-duplicates an existing entry by moving it to front',
        () {
      c.addToRecent('KFC');
      c.addToRecent('Subway');
      c.addToRecent('KFC');
      expect(c.recentSearches.first, equals('KFC'));
      expect(c.recentSearches.where((e) => e == 'KFC').length, equals(1));
    });

    test('addToRecent caps the list at 10 entries', () {
      for (var i = 0; i < 15; i++) {
        c.addToRecent('Search $i');
      }
      expect(c.recentSearches.length, equals(10));
      expect(c.recentSearches.first, equals('Search 14'));
    });

    test('removeRecentSearch removes by index', () {
      c.addToRecent('A');
      c.addToRecent('B');
      c.removeRecentSearch(0); // removes 'B' (most recent, at the front)
      expect(c.recentSearches, equals(['A']));
    });

    test('clearAllRecent empties the list', () {
      c.addToRecent('A');
      c.addToRecent('B');
      c.clearAllRecent();
      expect(c.recentSearches, isEmpty);
    });

    test('onSearchSubmitted adds a non-empty query to recent searches', () {
      c.onSearchSubmitted('New Query');
      expect(c.recentSearches.first, equals('New Query'));
    });

    test('onSearchSubmitted ignores an empty query', () {
      c.onSearchSubmitted('');
      expect(c.recentSearches, isEmpty);
    });

    test('selectSearch records the selection into recent searches', () {
      c.selectSearch('Museum');
      expect(c.recentSearches.first, equals('Museum'));
    });

    test('categories and sortOptions expose the expected static lists', () {
      expect(
        c.categories,
        equals(['All', 'Food', 'Shopping', 'Entertainment', 'Services', 'Outings']),
      );
      expect(
        c.sortOptions,
        equals([
          'Relevance',
          'Price: Low to High',
          'Price: High to Low',
          'Newest',
          'Rating',
        ]),
      );
    });

    test('resetFilter restores category, sort and price range to defaults',
        () {
      c.selectedCategory.value = 'Food';
      c.selectedSort.value = 'Newest';
      c.priceMin.value = 50.0;
      c.priceMax.value = 500.0;

      c.resetFilter();

      expect(c.selectedCategory.value, equals('All'));
      expect(c.selectedSort.value, equals('Relevance'));
      expect(c.priceMin.value, equals(0.0));
      expect(c.priceMax.value, equals(1000.0));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // SettingsController
  // ═══════════════════════════════════════════════════════════
  group('SettingsController', () {
    late SettingsController c;

    setUp(() {
      c = SettingsController();
    });

    test('default settings values', () {
      expect(c.selectedLanguage.value, equals('English'));
      expect(c.languages.length, equals(4));
      expect(c.isDarkMode.value, isFalse);
      expect(c.isBiometricEnabled.value, isFalse);
      expect(c.isTwoFactorEnabled.value, isFalse);
      expect(c.isPushNotificationsEnabled.value, isTrue);
      expect(c.isEmailNotificationsEnabled.value, isTrue);
      expect(c.isSmsNotificationsEnabled.value, isFalse);
      expect(c.isOrderUpdatesEnabled.value, isTrue);
      expect(c.isPromotionsEnabled.value, isTrue);
      expect(c.isLocationEnabled.value, isTrue);
      expect(c.isDataSharingEnabled.value, isFalse);
    });

    test('languages list has the expected codes', () {
      expect(
        c.languages.map((l) => l['code']).toList(),
        equals(['en', 'fr', 'ar', 'es']),
      );
    });

    test('toggleTheme flips isDarkMode', () {
      c.toggleTheme(true);
      expect(c.isDarkMode.value, isTrue);
      c.toggleTheme(false);
      expect(c.isDarkMode.value, isFalse);
    });

    test('togglePushNotifications flips the flag', () {
      c.togglePushNotifications(false);
      expect(c.isPushNotificationsEnabled.value, isFalse);
    });

    test('toggleEmailNotifications flips the flag', () {
      c.toggleEmailNotifications(false);
      expect(c.isEmailNotificationsEnabled.value, isFalse);
    });

    test('toggleSmsNotifications flips the flag', () {
      c.toggleSmsNotifications(true);
      expect(c.isSmsNotificationsEnabled.value, isTrue);
    });

    test('toggleOrderUpdates flips the flag', () {
      c.toggleOrderUpdates(false);
      expect(c.isOrderUpdatesEnabled.value, isFalse);
    });

    test('togglePromotions flips the flag', () {
      c.togglePromotions(false);
      expect(c.isPromotionsEnabled.value, isFalse);
    });

    test('toggleLocation flips the flag', () {
      c.toggleLocation(false);
      expect(c.isLocationEnabled.value, isFalse);
    });

    test('toggleDataSharing flips the flag', () {
      c.toggleDataSharing(true);
      expect(c.isDataSharingEnabled.value, isTrue);
    });

    // toggleTwoFactor now opens a real password-confirmation dialog and
    // calls PUT /auth/2fa on confirm — like other dialog-driven actions in
    // this codebase, that requires a mounted GetMaterialApp/navigator to
    // test meaningfully, not a bare unit test.
  });

  // ═══════════════════════════════════════════════════════════
  // VIPsClubController
  // ═══════════════════════════════════════════════════════════
  group('VIPsClubController', () {
    late VIPsClubController c;

    setUp(() {
      c = VIPsClubController();
    });

    test('default wallet/rank/mission values start at zero', () {
      expect(c.currentBannerIndex.value, equals(0));
      expect(c.convertibleDiamonds.value, equals(0));
      expect(c.pendingDiamonds.value, equals(0));
      expect(c.suspendedDiamonds.value, equals(0));
      expect(c.todayCoins.value, equals(0));
      expect(c.superBonus.value, equals(0));
      expect(c.referrals.value, equals(0));
      expect(c.currentRank.value, equals(0));
      expect(c.checkInStreak.value, equals(0));
      expect(c.referralCode.value, isEmpty);
      expect(c.transactionHistory, isEmpty);
      expect(c.hasCheckedInToday.value, isFalse);
      expect(c.canClaimReward.value, isTrue);
    });

    test('checkInDays seed data marks day 5 as today, unchecked', () {
      expect(c.checkInDays.length, equals(7));
      final today = c.checkInDays.firstWhere((d) => d['isToday'] == true);
      expect(today['day'], equals('Day 5'));
      expect(today['checked'], isFalse);
      expect(today['reward'], equals(250));
    });

    test('updateBannerIndex sets the current index', () {
      c.updateBannerIndex(2);
      expect(c.currentBannerIndex.value, equals(2));
    });

    test('claimDailyReward is a no-op once already checked in today', () {
      c.hasCheckedInToday.value = true;
      c.claimDailyReward();
      expect(c.convertibleDiamonds.value, equals(0));
      expect(c.checkInStreak.value, equals(0));
    });

    test('claimDailyReward is a no-op when the reward cannot be claimed', () {
      c.canClaimReward.value = false;
      c.claimDailyReward();
      expect(c.convertibleDiamonds.value, equals(0));
    });

    test('convertDiamonds is a no-op below the 100-diamond minimum', () {
      c.convertibleDiamonds.value = 50;
      c.convertDiamonds();
      expect(c.convertibleDiamonds.value, equals(50));
      expect(c.transactionHistory, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // NotificationsController
  // ═══════════════════════════════════════════════════════════
  group('NotificationsController', () {
    late NotificationsController c;

    NotificationItem item({
      String id = '1',
      bool isRead = false,
      NotificationType type = NotificationType.account,
    }) {
      return NotificationItem(
        id: id,
        title: 'Title $id',
        message: 'Message $id',
        time: 'now',
        isRead: isRead,
        type: type,
      );
    }

    setUp(() {
      c = NotificationsController();
    });

    test('default state: no notifications, filter All, not loading', () {
      expect(c.notifications, isEmpty);
      expect(c.selectedFilter.value, equals('All'));
      expect(c.isLoading.value, isFalse);
      expect(c.unreadCount, equals(0));
    });

    test('unreadCount counts only unread notifications', () {
      c.notifications.addAll([
        item(id: '1', isRead: false),
        item(id: '2', isRead: true),
        item(id: '3', isRead: false),
      ]);
      expect(c.unreadCount, equals(2));
    });

    test('filteredNotifications "All" returns everything', () {
      c.notifications.addAll([item(id: '1'), item(id: '2')]);
      expect(c.filteredNotifications.length, equals(2));
    });

    test('filteredNotifications "Unread" filters to unread only', () {
      c.notifications.addAll([
        item(id: '1', isRead: false),
        item(id: '2', isRead: true),
      ]);
      c.setFilter('Unread');
      expect(c.filteredNotifications.length, equals(1));
      expect(c.filteredNotifications.single.id, equals('1'));
    });

    test('filteredNotifications "Promotions" filters by type', () {
      c.notifications.addAll([
        item(id: '1', type: NotificationType.promotion),
        item(id: '2', type: NotificationType.payment),
      ]);
      c.setFilter('Promotions');
      expect(c.filteredNotifications.single.id, equals('1'));
    });

    test('markAsRead / markAsUnread toggle a single notification', () {
      final n = item(id: '1', isRead: false);
      c.notifications.add(n);
      c.markAsRead(n);
      expect(n.isRead, isTrue);
      c.markAsUnread(n);
      expect(n.isRead, isFalse);
    });

    test('deleteNotification removes the given notification', () {
      final n = item(id: '1');
      c.notifications.add(n);
      c.deleteNotification(n);
      expect(c.notifications, isEmpty);
    });

    test('getTypeLabel maps every notification type', () {
      expect(c.getTypeLabel(NotificationType.promotion), equals('Promotion'));
      expect(c.getTypeLabel(NotificationType.account), equals('Account'));
      expect(c.getTypeLabel(NotificationType.payment), equals('Payment'));
      expect(
        c.getTypeLabel(NotificationType.partnership),
        equals('Partnership'),
      );
    });

    test('getTypeIcon maps every notification type', () {
      expect(
        c.getTypeIcon(NotificationType.promotion),
        equals(Icons.local_offer_rounded),
      );
      expect(
        c.getTypeIcon(NotificationType.account),
        equals(Icons.person_rounded),
      );
      expect(
        c.getTypeIcon(NotificationType.payment),
        equals(Icons.payment_rounded),
      );
      expect(
        c.getTypeIcon(NotificationType.partnership),
        equals(Icons.handshake_rounded),
      );
    });

    test('getTypeColor maps every notification type', () {
      expect(
        c.getTypeColor(NotificationType.promotion),
        equals(const Color(0xFFEF4444)),
      );
      expect(
        c.getTypeColor(NotificationType.payment),
        equals(const Color(0xFF10B981)),
      );
      expect(
        c.getTypeColor(NotificationType.partnership),
        equals(const Color(0xFF8B5CF6)),
      );
    });

    test('NotificationItem.fromJson parses a full payload', () {
      final n = NotificationItem.fromJson({
        '_id': 'abc',
        'title': 'Hello',
        'message': 'World',
        'time': '5m ago',
        'image': 'img.png',
        'isRead': true,
        'type': 'Payment',
      });
      expect(n.id, equals('abc'));
      expect(n.title, equals('Hello'));
      expect(n.message, equals('World'));
      expect(n.time, equals('5m ago'));
      expect(n.image, equals('img.png'));
      expect(n.isRead, isTrue);
      expect(n.type, equals(NotificationType.payment));
    });

    test('NotificationItem.fromJson falls back on missing fields', () {
      final n = NotificationItem.fromJson({});
      expect(n.title, equals('Notification'));
      expect(n.message, isEmpty);
      expect(n.time, equals('Just now'));
      expect(n.isRead, isFalse);
      expect(n.type, equals(NotificationType.account));
      expect(n.id, isNotEmpty);
    });

    test('NotificationItem.fromJson maps an unknown type to account', () {
      final n = NotificationItem.fromJson({'type': 'something-else'});
      expect(n.type, equals(NotificationType.account));
    });

    test('NotificationItem.fromJson maps partnership case-insensitively',
        () {
      final n = NotificationItem.fromJson({'type': 'PARTNERSHIP'});
      expect(n.type, equals(NotificationType.partnership));
    });
  });
}
