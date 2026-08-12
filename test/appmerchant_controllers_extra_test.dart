// Additional unit tests for appmerchant GetX controllers not covered by
// merchant_qa_test.dart or appmerchant_controllers_test.dart: ads, assets,
// cashiers, gift-back, notifications, partnership, profile manager, barcode.
//
// Pattern (matches test/appuser_business_logic_test.dart): controllers are
// constructed directly (never Get.put/onInit) so their network-calling
// onInit() bodies never run — we drive the reactive fields and pure
// getters/methods directly instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/modules/merchant_ads/controllers/merchant_ads_controller.dart';
import 'package:vip/appmerchant/modules/merchant_assets/controllers/merchant_asset_controller.dart';
import 'package:vip/appmerchant/modules/merchant_barcode/controllers/merchant_barcode_controller.dart';
import 'package:vip/appmerchant/modules/merchant_cashiers/controllers/merchant_cashiers_controller.dart';
import 'package:vip/appmerchant/modules/merchant_gift_back/controllers/merchant_gift_back_controller.dart';
import 'package:vip/appmerchant/modules/merchant_notifications/controllers/merchant_notifications_controller.dart';
import 'package:vip/appmerchant/modules/merchant_partnership/controllers/merchant_partnership_controller.dart';
import 'package:vip/appmerchant/modules/merchant_profile_manager/controllers/merchant_profile_controller.dart';
import 'package:vip/appmerchant/modules/merchant_profile_manager/models/business_profile_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MerchantAdsController', () {
    late MerchantAdsController c;

    setUp(() {
      c = MerchantAdsController();
    });

    test('toggleLanguage flips isArabicSelected', () {
      c.toggleLanguage(true);
      expect(c.isArabicSelected.value, isTrue);
      c.toggleLanguage(false);
      expect(c.isArabicSelected.value, isFalse);
    });

    test('resetForm clears all form fields back to defaults', () {
      c.titleController.text = 'Sale';
      c.descriptionController.text = 'desc';
      c.budgetController.text = '100';
      c.startDate.value = DateTime.now();
      c.endDate.value = DateTime.now();
      c.uploadedImageUrl.value = 'http://x';
      c.isArabicSelected.value = true;
      c.showReview.value = true;
      c.showRating.value = true;
      c.selectedCategory.value = 'Flash Sale';

      c.resetForm();

      expect(c.titleController.text, isEmpty);
      expect(c.descriptionController.text, isEmpty);
      expect(c.budgetController.text, isEmpty);
      expect(c.startDate.value, isNull);
      expect(c.endDate.value, isNull);
      expect(c.uploadedImageUrl.value, isEmpty);
      expect(c.isArabicSelected.value, isFalse);
      expect(c.showReview.value, isFalse);
      expect(c.showRating.value, isFalse);
      expect(c.selectedCategory.value, equals('Auto Promotion'));
    });

    test('submitAdForm is a no-op when the title is empty', () async {
      c.titleController.text = '';
      await c.submitAdForm();
      expect(c.isCreating.value, isFalse);
    });

    test('submitAdForm is a no-op when start/end dates are missing', () async {
      c.titleController.text = 'My Ad';
      await c.submitAdForm();
      expect(c.isCreating.value, isFalse);
    });

    test('submitAdForm is a no-op when end date is before start date',
        () async {
      c.titleController.text = 'My Ad';
      c.startDate.value = DateTime(2026, 3, 10);
      c.endDate.value = DateTime(2026, 3, 1);
      await c.submitAdForm();
      expect(c.isCreating.value, isFalse);
    });
  });

  group('MerchantAssetController / BusinessAsset', () {
    test('fromJson maps every field', () {
      final asset = BusinessAsset.fromJson({
        '_id': 'a1',
        'name': 'Oven',
        'type': 'Equipment',
        'value': 500,
        'purchaseDate': '2026-01-15T00:00:00.000Z',
      });
      expect(asset.id, equals('a1'));
      expect(asset.name, equals('Oven'));
      expect(asset.type, equals('Equipment'));
      expect(asset.value, equals(500.0));
      expect(asset.purchaseDate, equals(DateTime.parse('2026-01-15T00:00:00.000Z')));
    });

    test('fromJson defaults type to "Other" and value to 0 when absent', () {
      final asset = BusinessAsset.fromJson({'id': 'a2', 'name': 'Misc'});
      expect(asset.type, equals('Other'));
      expect(asset.value, equals(0.0));
      // purchaseDate falls back to DateTime.now() — just assert it's sane/recent.
      expect(
        DateTime.now().difference(asset.purchaseDate).inMinutes,
        lessThan(1),
      );
    });
  });

  group('MerchantCashiersController', () {
    late MerchantCashiersController c;

    setUp(() {
      c = MerchantCashiersController();
    });

    test('roleColor maps each role to a distinct color', () {
      expect(c.roleColor('Manager'), equals(const Color(0xFF6366F1)));
      expect(c.roleColor('Supervisor'), equals(const Color(0xFFF59E0B)));
      expect(c.roleColor('Staff'), equals(const Color(0xFF6B7280)));
      expect(c.roleColor('Cashier'), equals(const Color(0xFF10B981)));
      expect(c.roleColor('Unknown'), equals(const Color(0xFF10B981)));
    });

    test('addCashier is a no-op when name and phone are blank', () async {
      c.nameController.text = '';
      c.phoneController.text = '';
      await c.addCashier();
      expect(c.cashiers, isEmpty);
      expect(c.isLoading.value, isFalse);
    });

    test('roles exposes the fixed role list', () {
      expect(c.roles, equals(['Cashier', 'Manager', 'Supervisor', 'Staff']));
    });
  });

  group('MerchantGiftBackController', () {
    late MerchantGiftBackController c;

    setUp(() {
      c = MerchantGiftBackController();
    });

    test('updatePin accumulates digits without exceeding 4', () {
      c.updatePin('1');
      c.updatePin('2');
      c.updatePin('3');
      expect(c.pinCode.value, equals('123'));
    });

    test('clearPin removes the last digit', () {
      c.updatePin('7');
      c.updatePin('8');
      c.clearPin();
      expect(c.pinCode.value, equals('7'));
    });

    test('clearPin on an empty pin is a safe no-op', () {
      expect(c.pinCode.value, isEmpty);
      expect(() => c.clearPin(), returnsNormally);
      expect(c.pinCode.value, isEmpty);
    });
  });

  group('MerchantNotificationsController / NotificationItem', () {
    late MerchantNotificationsController c;

    setUp(() {
      c = MerchantNotificationsController();
    });

    test('NotificationItem.fromJson maps fields and defaults isRead to false',
        () {
      final n = NotificationItem.fromJson({
        '_id': 'n1',
        'title': 'Hi',
        'message': 'Body text',
        'type': 'order',
      });
      expect(n.id, equals('n1'));
      expect(n.title, equals('Hi'));
      expect(n.body, equals('Body text'));
      expect(n.type, equals('order'));
      expect(n.isRead, isFalse);
    });

    test('markAsRead flips isRead and recomputes unreadCount', () async {
      c.notifications.addAll([
        NotificationItem(
          id: '1',
          title: 'A',
          body: 'a',
          time: DateTime.now(),
          type: 'system',
        ),
        NotificationItem(
          id: '2',
          title: 'B',
          body: 'b',
          time: DateTime.now(),
          type: 'system',
        ),
      ]);
      await c.markAsRead('1');
      expect(c.notifications.firstWhere((n) => n.id == '1').isRead, isTrue);
      expect(c.unreadCount.value, equals(1));
    });

    test('markAllAsRead marks every notification read', () async {
      c.notifications.addAll([
        NotificationItem(
          id: '1',
          title: 'A',
          body: 'a',
          time: DateTime.now(),
          type: 'system',
        ),
        NotificationItem(
          id: '2',
          title: 'B',
          body: 'b',
          time: DateTime.now(),
          type: 'system',
        ),
      ]);
      await c.markAllAsRead();
      expect(c.notifications.every((n) => n.isRead), isTrue);
      expect(c.unreadCount.value, equals(0));
    });

    test('deleteNotification removes the item and recomputes unreadCount',
        () async {
      c.notifications.addAll([
        NotificationItem(
          id: '1',
          title: 'A',
          body: 'a',
          time: DateTime.now(),
          type: 'system',
        ),
      ]);
      await c.deleteNotification('1');
      expect(c.notifications, isEmpty);
      expect(c.unreadCount.value, equals(0));
    });
  });

  group('MerchantPartnershipController', () {
    late MerchantPartnershipController c;

    setUp(() {
      c = MerchantPartnershipController();
    });

    tearDown(() {
      c.onClose();
    });

    test('onPageChanged updates currentPage', () {
      c.onPageChanged(2);
      expect(c.currentPage.value, equals(2));
    });

    test('toggleAgreement updates isAgreed', () {
      c.toggleAgreement(true);
      expect(c.isAgreed.value, isTrue);
      c.toggleAgreement(null);
      expect(c.isAgreed.value, isFalse);
    });

    test('confirmSetup is a no-op when the agreement isn\'t checked',
        () async {
      c.isAgreed.value = false;
      await c.confirmSetup();
      expect(c.isLoading.value, isFalse);
    });

    test('onboardingData exposes exactly 3 onboarding slides', () {
      expect(c.onboardingData.length, equals(3));
    });
  });

  group('MerchantProfileController', () {
    late MerchantProfileController c;

    setUp(() {
      c = MerchantProfileController();
    });

    test('verifyPin returns false for a non-matching PIN', () async {
      final profile = BusinessProfile(
        id: 'p1',
        name: 'Store',
        type: 'Business',
        logoUrl: '',
        pin: '0000',
        isActive: true,
      );
      final result = await c.verifyPin(profile, '9999');
      expect(result, isFalse);
      expect(c.isVerifying.value, isFalse);
    });

    test('changePin persists the new PIN to SharedPreferences', () async {
      await c.changePin('4321');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('merchant_pin'), equals('4321'));
    });
  });

  group('MerchantBarcodeController', () {
    late MerchantBarcodeController c;

    setUp(() {
      c = MerchantBarcodeController();
    });

    test('generate is a no-op when the product name is empty', () {
      c.nameCtrl.text = '';
      c.generate();
      expect(c.generatedCode.value, isEmpty);
    });

    test('generate builds "name|code" when a code is provided', () {
      c.nameCtrl.text = 'Burger';
      c.codeCtrl.text = 'SKU-1';
      c.generate();
      expect(c.generatedCode.value, equals('Burger|SKU-1'));
    });

    test('generate auto-generates a PROD- code when none is provided', () {
      c.nameCtrl.text = 'Fries';
      c.codeCtrl.text = '';
      c.generate();
      expect(c.generatedCode.value, startsWith('Fries|PROD-'));
    });

    test('saveBarcode is a no-op when no code has been generated', () async {
      c.generatedCode.value = '';
      await c.saveBarcode();
      expect(c.isSaving.value, isFalse);
    });

    test('selectedType defaults to qrcode', () {
      expect(c.selectedType.value, equals('qrcode'));
    });
  });
}
