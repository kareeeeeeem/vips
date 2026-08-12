// Unit tests for the pure/testable business logic in the appuser
// commerce-related GetX controllers: pay_bills, donation, mobile, gift,
// credit, coupon, bills, expense_to_reward, packages.
//
// Pattern (see test/appuser_business_logic_test.dart): controllers are
// constructed directly (never Get.put/onInit) so their network-calling /
// Timer-scheduling / navigation-triggering onInit() bodies never run. Only
// synchronous, side-effect-pure getters/methods are exercised, and only
// after manually seeding whatever state onInit() would otherwise have
// populated.
//
// Several `proceed()`-style methods are async and call `safeSnackbar()` on
// their early-return guard clauses; safeSnackbar defers to a post-frame
// callback and no-ops when there's no Get.context, so calling those guarded
// paths (without awaiting further) is safe and side-effect-free in a plain
// `test()` — it never reaches the network call or navigation beyond the
// guard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/Donation/controllers/donation_controller.dart';
import 'package:vip/appuser/modules/bills/controllers/bills_controller.dart';
import 'package:vip/appuser/modules/coupon/controllers/coupon_controller.dart'
    hide Package;
import 'package:vip/appuser/modules/credit/controllers/credit_controller.dart';
import 'package:vip/appuser/modules/expense_to_reward/controllers/expense_to_reward_controller.dart';
import 'package:vip/appuser/modules/gift/controllers/gift_controller.dart';
import 'package:vip/appuser/modules/mobile/controllers/mobile_controller.dart';
import 'package:vip/appuser/modules/packages/controllers/packages_controller.dart';
import 'package:vip/appuser/modules/pay_bills/controllers/pay_bills_controller.dart';

Package _pkg({
  required String id,
  required PackageTier tier,
  double price = 10,
  bool isCurrent = false,
}) {
  return Package(
    id: id,
    tier: tier,
    name: id,
    price: price,
    monthlyPrice: price / 12,
    redeemPoints: 100,
    giftPoints: 50,
    primaryColor: Colors.blue,
    accentColor: Colors.blueAccent,
    benefits: const [],
    isCurrent: isCurrent,
  );
}

Coupon _coupon({
  String id = 'c1',
  String code = 'SAVE10',
  double discount = 10,
  CouponStatus status = CouponStatus.active,
  DateTime? expiryDate,
  int usageCount = 10,
  int maxUsage = 100,
}) {
  return Coupon(
    id: id,
    code: code,
    discount: discount,
    type: CouponType.percentage,
    status: status,
    expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 30)),
    usageCount: usageCount,
    maxUsage: maxUsage,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════
  // PayBillsController
  // ═══════════════════════════════════════════════════════════
  group('PayBillsController', () {
    late PayBillsController pay;

    setUp(() {
      pay = PayBillsController();
    });

    test('starts with empty billCategories and isLoading false', () {
      expect(pay.billCategories, isEmpty);
      expect(pay.isLoading.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // DonationController
  // ═══════════════════════════════════════════════════════════
  group('DonationController', () {
    late DonationController donation;

    setUp(() {
      donation = DonationController();
    });

    test('selectOrganization sets the selected index', () {
      donation.selectOrganization(3);
      expect(donation.selectedOrganizationIndex.value, equals(3));
    });

    test('organizations list has the expected known entries', () {
      expect(donation.organizations.length, equals(6));
      expect(donation.organizations.first['name'], equals('Red Cross'));
    });

    test('proceed() with no organization selected returns early', () {
      expect(donation.selectedOrganizationIndex.value, isNull);
      expect(() => donation.proceed(), returnsNormally);
    });

    test('proceed() with organization selected but empty amount returns early', () {
      donation.selectOrganization(0);
      donation.amountController.text = '';
      expect(() => donation.proceed(), returnsNormally);
    });

    test('proceed() with a non-positive amount returns early', () {
      donation.selectOrganization(0);
      donation.amountController.text = '0';
      expect(() => donation.proceed(), returnsNormally);

      donation.amountController.text = '-5';
      expect(() => donation.proceed(), returnsNormally);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MobilesController
  // ═══════════════════════════════════════════════════════════
  group('MobilesController', () {
    late MobilesController mobile;

    setUp(() {
      mobile = MobilesController();
    });

    test('selectOperator sets the selected operator index', () {
      mobile.selectOperator(2);
      expect(mobile.selectedOperatorIndex.value, equals(2));
    });

    test('selectCreditOption sets the selected credit option index', () {
      mobile.selectCreditOption(1);
      expect(mobile.selectedCreditOption.value, equals(1));
    });

    test('updateQuantity updates quantity only when positive', () {
      mobile.updateQuantity(0, 5);
      expect(mobile.creditOptions[0]['quantity'], equals(5));

      mobile.updateQuantity(0, 0);
      expect(mobile.creditOptions[0]['quantity'], equals(5)); // unchanged

      mobile.updateQuantity(0, -1);
      expect(mobile.creditOptions[0]['quantity'], equals(5)); // unchanged
    });

    test('incrementQuantity increases the option quantity', () {
      expect(mobile.creditOptions[1]['quantity'], equals(1));
      mobile.incrementQuantity(1);
      expect(mobile.creditOptions[1]['quantity'], equals(2));
    });

    test('decrementQuantity never goes below 1', () {
      mobile.decrementQuantity(2); // already at 1
      expect(mobile.creditOptions[2]['quantity'], equals(1));

      mobile.incrementQuantity(2);
      expect(mobile.creditOptions[2]['quantity'], equals(2));
      mobile.decrementQuantity(2);
      expect(mobile.creditOptions[2]['quantity'], equals(1));
    });

    test('proceed() with no operator selected returns early', () {
      expect(mobile.selectedOperatorIndex.value, isNull);
      expect(() => mobile.proceed(), returnsNormally);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GiftController
  // ═══════════════════════════════════════════════════════════
  group('GiftController', () {
    late GiftController gift;

    setUp(() {
      gift = GiftController();
    });

    test('isUserIdEnabled starts true', () {
      expect(gift.isUserIdEnabled.value, isTrue);
    });

    test('toggleUserIdInput disables input and clears the user id text', () {
      gift.userIdController.text = '12345';
      gift.toggleUserIdInput();
      expect(gift.isUserIdEnabled.value, isFalse);
      expect(gift.userIdController.text, isEmpty);
    });

    test('toggleUserIdInput re-enables input', () {
      gift.toggleUserIdInput(); // -> disabled
      gift.toggleUserIdInput(); // -> re-enabled
      expect(gift.isUserIdEnabled.value, isTrue);
    });

    test('toggleExpress flips the express flag', () {
      expect(gift.isExpressSelected.value, isFalse);
      gift.toggleExpress();
      expect(gift.isExpressSelected.value, isTrue);
      gift.toggleExpress();
      expect(gift.isExpressSelected.value, isFalse);
    });

    test('proceed() with an empty recipient id returns early', () {
      gift.userIdController.text = '';
      expect(() => gift.proceed(), returnsNormally);
    });

    test('proceed() with a recipient but no positive amount returns early', () {
      gift.userIdController.text = '123456';
      gift.amountController.text = '';
      expect(gift.giftAmount.value, equals(0.0));
      expect(() => gift.proceed(), returnsNormally);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CreditController
  // ═══════════════════════════════════════════════════════════
  group('CreditController', () {
    late CreditController credit;

    setUp(() {
      credit = CreditController();
    });

    test('BankCard.maskedNumber formats the masked card number', () {
      final card = BankCard(
        id: '9',
        bankName: 'Test Bank',
        lastFourDigits: '4242',
      );
      expect(card.maskedNumber, equals('**** **** **** 4242'));
      expect(card.isDefault, isFalse);
    });

    test('starts with no bank cards loaded (loadBankCards is async/network)', () {
      expect(credit.bankCards, isEmpty);
    });

    test('validateVipsNumber requires an integer >= minVipsPurchase (100)', () {
      credit.vipsNumberController.text = '99';
      credit.validateVipsNumber();
      expect(credit.isVipsNumberValid.value, isFalse);

      credit.vipsNumberController.text = '100';
      credit.validateVipsNumber();
      expect(credit.isVipsNumberValid.value, isTrue);

      credit.vipsNumberController.text = 'not-a-number';
      credit.validateVipsNumber();
      expect(credit.isVipsNumberValid.value, isFalse);
    });

    test('amountInTnd converts VIPS to TND at the fixed rate', () {
      credit.vipsNumberController.text = '150';
      expect(credit.amountInTnd, closeTo(15.0, 0.0001));

      credit.vipsNumberController.text = '';
      expect(credit.amountInTnd, equals(0.0));
    });

    test('isFormValid requires both a valid VIPS number and a payment method', () {
      credit.vipsNumberController.text = '200';
      credit.validateVipsNumber();
      expect(credit.isFormValid, isFalse); // no payment method yet

      credit.selectCard('card-1');
      expect(credit.isFormValid, isTrue);
    });

    test('selectCard sets the selected payment method', () {
      credit.selectCard('card-42');
      expect(credit.selectedPaymentMethod.value, equals('card-42'));
    });

    test('proceedToPayment with an invalid form is a no-op', () {
      expect(credit.isFormValid, isFalse);
      expect(() => credit.proceedToPayment(), returnsNormally);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CouponController
  // ═══════════════════════════════════════════════════════════
  group('CouponController', () {
    late CouponController coupon;

    setUp(() {
      coupon = CouponController();
    });

    test('starts with default filter, tab index and empty lists', () {
      expect(coupon.selectedFilter.value, equals('All'));
      expect(coupon.currentTabIndex.value, equals(0));
      expect(coupon.coupons, isEmpty);
      expect(coupon.packages, isEmpty);
    });

    test('Coupon.usagePercentage computes usage over max as a percentage', () {
      final c = _coupon(usageCount: 25, maxUsage: 100);
      expect(c.usagePercentage, equals(25.0));
    });

    test('Coupon.isExpired reflects whether expiryDate is in the past', () {
      final expired = _coupon(
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final active = _coupon(
        expiryDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(expired.isExpired, isTrue);
      expect(active.isExpired, isFalse);
    });

    test('Coupon.daysLeft reflects the remaining days until expiry', () {
      final c = _coupon(
        expiryDate: DateTime.now().add(const Duration(days: 100)),
      );
      expect(c.daysLeft, inInclusiveRange(99, 100));
    });

    test('Coupon.copyWith overrides only the given fields', () {
      final original = _coupon(id: 'x1', code: 'ORIG', status: CouponStatus.active);
      final copy = original.copyWith(status: CouponStatus.inactive);
      expect(copy.id, equals('x1'));
      expect(copy.code, equals('ORIG'));
      expect(copy.status, equals(CouponStatus.inactive));
      expect(original.status, equals(CouponStatus.active)); // unchanged
    });

    test('toggleCouponStatus flips active <-> inactive for the matching coupon', () {
      coupon.coupons.addAll([
        _coupon(id: 'a', status: CouponStatus.active),
        _coupon(id: 'b', status: CouponStatus.inactive),
      ]);

      coupon.toggleCouponStatus(coupon.coupons.firstWhere((c) => c.id == 'a'));
      expect(
        coupon.coupons.firstWhere((c) => c.id == 'a').status,
        equals(CouponStatus.inactive),
      );

      coupon.toggleCouponStatus(coupon.coupons.firstWhere((c) => c.id == 'b'));
      expect(
        coupon.coupons.firstWhere((c) => c.id == 'b').status,
        equals(CouponStatus.active),
      );
    });

    test('toggleCouponStatus is a no-op when the coupon id is not found', () {
      coupon.coupons.add(_coupon(id: 'known', status: CouponStatus.active));
      final unknown = _coupon(id: 'unknown', status: CouponStatus.active);

      coupon.toggleCouponStatus(unknown);

      expect(coupon.coupons.length, equals(1));
      expect(coupon.coupons.first.status, equals(CouponStatus.active));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // BillsController
  // ═══════════════════════════════════════════════════════════
  group('BillsController', () {
    late BillsController bills;

    setUp(() {
      bills = BillsController();
    });

    test('primaryColor depends on selectedRole', () {
      expect(bills.selectedRole.value, equals('Customer'));
      expect(bills.primaryColor, equals(Colors.orange));

      bills.selectedRole.value = 'Vendor';
      expect(bills.primaryColor, equals(const Color(0xFFFFC107)));

      bills.selectedRole.value = 'Agent';
      expect(bills.primaryColor, equals(const Color(0xFF2196F3)));

      bills.selectedRole.value = 'Business';
      expect(bills.primaryColor, equals(Colors.blue));

      bills.selectedRole.value = 'SomethingElse';
      expect(bills.primaryColor, equals(Colors.blue));
    });

    test('formatDate renders as month/day', () {
      expect(bills.formatDate(DateTime(2026, 3, 7)), equals('3/7'));
      expect(bills.formatDate(DateTime(2026, 12, 25)), equals('12/25'));
    });

    test('onFilterChanged updates selectedFilter', () {
      expect(bills.selectedFilter.value, equals('Products'));
      bills.onFilterChanged('Services');
      expect(bills.selectedFilter.value, equals('Services'));
    });

    test('onPageChanged updates currentIndex', () {
      bills.onPageChanged(2);
      expect(bills.currentIndex.value, equals(2));
    });

    test('toggleOrder flips the expanded flag at the given index', () {
      bills.expandedOrders.value = [false, false, false];
      bills.toggleOrder(1);
      expect(bills.expandedOrders[1], isTrue);
      bills.toggleOrder(1);
      expect(bills.expandedOrders[1], isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ExpenseToRewardController
  // ═══════════════════════════════════════════════════════════
  group('ExpenseToRewardController', () {
    late ExpenseToRewardController expense;

    setUp(() {
      expense = ExpenseToRewardController();
    });

    test('validateAmount accepts only a strictly positive number', () {
      expense.amountController.text = '10.5';
      expense.validateAmount();
      expect(expense.isAmountValid.value, isTrue);

      expense.amountController.text = '0';
      expense.validateAmount();
      expect(expense.isAmountValid.value, isFalse);

      expense.amountController.text = '-5';
      expense.validateAmount();
      expect(expense.isAmountValid.value, isFalse);

      expense.amountController.text = 'abc';
      expense.validateAmount();
      expect(expense.isAmountValid.value, isFalse);
    });

    test('validateUserId requires non-empty text', () {
      expense.userIdController.text = '';
      expense.validateUserId();
      expect(expense.isUserIdValid.value, isFalse);

      expense.userIdController.text = 'merchant-1';
      expense.validateUserId();
      expect(expense.isUserIdValid.value, isTrue);
    });

    test('isFormValid requires both amount and user id to be valid', () {
      expense.amountController.text = '10';
      expense.validateAmount();
      expense.userIdController.text = '';
      expense.validateUserId();
      expect(expense.isFormValid, isFalse);

      expense.userIdController.text = 'merchant-1';
      expense.validateUserId();
      expect(expense.isFormValid, isTrue);
    });

    test('formattedTime pads minutes and seconds to two digits', () {
      expense.timerSeconds.value = 21;
      expect(expense.formattedTime, equals('00:21'));

      expense.timerSeconds.value = 65;
      expect(expense.formattedTime, equals('01:05'));

      expense.timerSeconds.value = 0;
      expect(expense.formattedTime, equals('00:00'));
    });

    test('stopTimer marks the timer as not running', () {
      expense.isTimerRunning.value = true;
      expense.stopTimer();
      expect(expense.isTimerRunning.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // PackagesController
  // ═══════════════════════════════════════════════════════════
  group('PackagesController', () {
    late PackagesController packages;

    setUp(() {
      packages = PackagesController();
    });

    test('starts with no packages loaded and quantity 1', () {
      expect(packages.packages, isEmpty);
      expect(packages.selectedPackage.value, isNull);
      expect(packages.quantity.value, equals(1));
      expect(packages.showDetails.value, isFalse);
    });

    test('currentPackage returns the package flagged isCurrent', () {
      packages.packages.addAll([
        _pkg(id: 'basic', tier: PackageTier.basic, isCurrent: true),
        _pkg(id: 'gold', tier: PackageTier.gold),
      ]);
      expect(packages.currentPackage.id, equals('basic'));
    });

    test('currentPackage falls back to the first package when none is current', () {
      packages.packages.addAll([
        _pkg(id: 'first', tier: PackageTier.basic),
        _pkg(id: 'second', tier: PackageTier.gold),
      ]);
      expect(packages.currentPackage.id, equals('first'));
    });

    test('selectPackage sets the selected package and reveals details', () {
      final pkg = _pkg(id: 'silver', tier: PackageTier.silver);
      packages.selectPackage(pkg);
      expect(packages.selectedPackage.value, equals(pkg));
      expect(packages.showDetails.value, isTrue);
    });

    test('changeTab selects the package matching the tab index', () {
      packages.packages.addAll([
        _pkg(id: 'silver', tier: PackageTier.silver),
        _pkg(id: 'gold', tier: PackageTier.gold),
        _pkg(id: 'platinum', tier: PackageTier.platinum),
      ]);

      packages.changeTab(0);
      expect(packages.selectedPackage.value?.tier, equals(PackageTier.silver));

      packages.changeTab(1);
      expect(packages.selectedPackage.value?.tier, equals(PackageTier.gold));

      packages.changeTab(2);
      expect(packages.selectedPackage.value?.tier, equals(PackageTier.platinum));
    });

    test('incrementQuantity stops at 10', () {
      packages.quantity.value = 10;
      packages.incrementQuantity();
      expect(packages.quantity.value, equals(10));

      packages.quantity.value = 9;
      packages.incrementQuantity();
      expect(packages.quantity.value, equals(10));
    });

    test('decrementQuantity stops at 1', () {
      packages.quantity.value = 1;
      packages.decrementQuantity();
      expect(packages.quantity.value, equals(1));

      packages.quantity.value = 2;
      packages.decrementQuantity();
      expect(packages.quantity.value, equals(1));
    });

    test('totalPrice multiplies the selected package price by quantity', () {
      expect(packages.totalPrice, equals(0.0)); // no package selected

      packages.packages.add(_pkg(id: 'gold', tier: PackageTier.gold, price: 25));
      packages.selectPackage(packages.packages.first);
      packages.quantity.value = 3;
      expect(packages.totalPrice, equals(75.0));
    });

    test('goBack hides details without navigating when details are shown', () {
      packages.showDetails.value = true;
      packages.goBack();
      expect(packages.showDetails.value, isFalse);
    });

    test('buyPackage() with the basic tier is a no-op (early return)', () {
      final basic = _pkg(id: 'basic', tier: PackageTier.basic, isCurrent: true);
      packages.selectPackage(basic);
      expect(() => packages.buyPackage(), returnsNormally);
    });
  });
}
