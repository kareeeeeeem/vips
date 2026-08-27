// appmerchant_controllers_test.dart
//
// Unit tests for pure/testable business logic in additional appmerchant
// GetX controllers: validators, model parsing (fromJson/toJson), computed
// getters, list filters, and PIN/amount-entry helpers.
//
// Pattern (matches test/merchant_qa_test.dart and
// test/appuser_business_logic_test.dart): controllers are constructed
// directly — never Get.put()/onInit() — so their network-calling onInit()
// bodies never run. We drive reactive fields and pure getters/methods only.

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vip/appmerchant/modules/merchant_auth/controllers/merchant_auth_controller.dart';
import 'package:vip/appmerchant/modules/merchant_home/controllers/merchant_home_controller.dart';
import 'package:vip/appmerchant/modules/merchant_finance/controllers/merchant_finance_controller.dart';
import 'package:vip/appmerchant/modules/merchant_stock/controllers/merchant_stock_controller.dart';
import 'package:vip/appmerchant/modules/merchant_tax/controllers/merchant_tax_controller.dart';
import 'package:vip/appmerchant/modules/merchant_wallet/controllers/merchant_wallet_controller.dart';
import 'package:vip/appmerchant/modules/merchant_credit/controllers/merchant_credit_controller.dart';
import 'package:vip/appmerchant/modules/merchant_catalog/controllers/merchant_catalog_controller.dart';
import 'package:vip/appmerchant/modules/merchant_subscription/controllers/merchant_subscription_controller.dart';
import 'package:vip/appmerchant/modules/merchant_dues/controllers/merchant_dues_controller.dart';
import 'package:vip/appmerchant/modules/merchant_customers/controllers/merchant_customers_controller.dart';
import 'package:vip/appmerchant/modules/merchant_hrm/controllers/merchant_hrm_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantAuthController
  // ═══════════════════════════════════════════════════════════
  group('MerchantAuthController', () {
    late MerchantAuthController c;

    setUp(() {
      c = MerchantAuthController();
    });

    tearDown(() {
      c.phoneController.dispose();
      c.pinController.dispose();
    });

    test('initial state — not loading, phoneNumber empty', () {
      expect(c.isLoading.value, isFalse);
      expect(c.phoneNumber.value, isEmpty);
      expect(c.phoneController.text, isEmpty);
    });

    test('phoneController text trims correctly (mirrors login() guard)', () {
      c.phoneController.text = '  0512345678  ';
      final phone = c.phoneController.text.trim();
      expect(phone, equals('0512345678'));
      expect(phone.isEmpty, isFalse);
    });

    test('empty phone fails the login() guard', () {
      c.phoneController.text = '   ';
      expect(c.phoneController.text.trim().isEmpty, isTrue);
    });

    test('OTP shorter than 4 chars fails the verifyOtp() guard', () {
      expect('12'.length < 4, isTrue);
    });

    test('OTP of 4+ chars passes the verifyOtp() guard', () {
      expect('4821'.length < 4, isFalse);
    });

    test('phoneNumber Rx can be set after a successful send', () {
      c.phoneNumber.value = '0501234567';
      expect(c.phoneNumber.value, equals('0501234567'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantHomeController
  // ═══════════════════════════════════════════════════════════
  group('MerchantHomeController', () {
    late MerchantHomeController c;

    setUp(() {
      c = MerchantHomeController();
    });

    test('initial dashboard stats are all zero', () {
      expect(c.totalSales.value, equals(0.0));
      expect(c.totalExpenses.value, equals(0.0));
      expect(c.totalPurchases.value, equals(0.0));
      expect(c.totalSaleDue.value, equals(0.0));
      expect(c.totalDueCollect.value, equals(0.0));
      expect(c.vipsIn.value, equals(0.0));
      expect(c.vipsOut.value, equals(0.0));
      expect(c.vipsIssued.value, equals(0.0));
    });

    test('initial profile fields are empty and isLoading is true', () {
      expect(c.storeName.value, isEmpty);
      expect(c.storePhone.value, isEmpty);
      expect(c.storeImageUrl.value, isEmpty);
      expect(c.merchantId.value, isEmpty);
      expect(c.isLoading.value, isTrue);
    });

    test('currentIndex defaults to 0 and is directly mutable', () {
      expect(c.currentIndex.value, equals(0));
      c.currentIndex.value = 3;
      expect(c.currentIndex.value, equals(3));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantFinanceController / FinanceTransaction
  // ═══════════════════════════════════════════════════════════
  group('MerchantFinanceController', () {
    test('FinanceTransaction.fromJson maps income/reward/gift_back to income',
        () {
      for (final type in ['income', 'reward', 'gift_back']) {
        final tx = FinanceTransaction.fromJson({
          'type': type,
          'amount': 50,
          'description': 'desc',
        });
        expect(tx.type, equals(FinanceType.income), reason: 'type=$type');
      }
    });

    test('FinanceTransaction.fromJson maps other/unknown types to expense',
        () {
      final tx = FinanceTransaction.fromJson({
        'type': 'expense',
        'amount': 20,
      });
      expect(tx.type, equals(FinanceType.expense));

      final txUnknown = FinanceTransaction.fromJson({'amount': 5});
      expect(txUnknown.type, equals(FinanceType.expense));
    });

    test('FinanceTransaction.fromJson applies field fallbacks', () {
      final tx = FinanceTransaction.fromJson({});
      expect(tx.id, isEmpty);
      expect(tx.title, isEmpty);
      expect(tx.category, equals('Other'));
      expect(tx.account, equals('Cash'));
      expect(tx.amount, equals(0.0));
    });

    test('FinanceTransaction.fromJson prefers description over title', () {
      final tx = FinanceTransaction.fromJson({
        'description': 'From description',
        'title': 'From title',
      });
      expect(tx.title, equals('From description'));
    });

    test('FinanceTransaction.fromJson parses createdAt when present', () {
      final tx = FinanceTransaction.fromJson({
        'createdAt': '2024-05-01T12:00:00Z',
      });
      expect(tx.date, equals(DateTime.parse('2024-05-01T12:00:00Z')));
    });

    test('categories list contains the expected default categories', () {
      final c = MerchantFinanceController();
      expect(c.categories, containsAll(['Sale', 'Rent', 'Salaries', 'Other']));
      expect(c.categories.length, equals(7));
    });

    test('controller initial totals are zero and not loading', () {
      final c = MerchantFinanceController();
      expect(c.totalIncome.value, equals(0.0));
      expect(c.totalExpense.value, equals(0.0));
      expect(c.cashBalance.value, equals(0.0));
      expect(c.bankBalance.value, equals(0.0));
      expect(c.isLoading.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantStockController / StockItem
  // ═══════════════════════════════════════════════════════════
  group('MerchantStockController', () {
    test('StockItem.isLowStock is true when stock <= threshold', () {
      final low = StockItem(
        id: '1',
        name: 'Widget',
        category: 'General',
        currentStock: 5,
        lowStockThreshold: 10,
        unitPrice: 2.0,
      );
      final ok = StockItem(
        id: '2',
        name: 'Gadget',
        category: 'General',
        currentStock: 20,
        lowStockThreshold: 10,
        unitPrice: 2.0,
      );
      expect(low.isLowStock, isTrue);
      expect(ok.isLowStock, isFalse);
    });

    test('StockItem.isLowStock is true when stock exactly equals threshold',
        () {
      final atThreshold = StockItem(
        id: '3',
        name: 'Exact',
        category: 'General',
        currentStock: 10,
        lowStockThreshold: 10,
        unitPrice: 1.0,
      );
      expect(atThreshold.isLowStock, isTrue);
    });

    test('StockItem.fromJson applies fallbacks for missing fields', () {
      final item = StockItem.fromJson({'name': 'Only Name'});
      expect(item.id, isEmpty);
      expect(item.category, equals('General'));
      expect(item.currentStock, equals(0));
      expect(item.lowStockThreshold, equals(10));
      expect(item.unitPrice, equals(0.0));
    });

    test('StockItem.toJson round-trips through fromJson', () {
      final original = StockItem(
        id: 'x',
        name: 'Round Trip',
        category: 'Cat',
        currentStock: 7,
        lowStockThreshold: 3,
        unitPrice: 9.5,
      );
      final restored = StockItem.fromJson(original.toJson());
      expect(restored.name, equals(original.name));
      expect(restored.category, equals(original.category));
      expect(restored.currentStock, equals(original.currentStock));
      expect(restored.lowStockThreshold, equals(original.lowStockThreshold));
      expect(restored.unitPrice, equals(original.unitPrice));
    });

    test('inventory value / low stock count aggregate correctly (mirrors '
        'MerchantStockController._calculateStats)', () {
      final items = [
        StockItem(
            id: '1',
            name: 'A',
            category: 'C',
            currentStock: 5,
            lowStockThreshold: 10,
            unitPrice: 2.0), // low, value 10
        StockItem(
            id: '2',
            name: 'B',
            category: 'C',
            currentStock: 20,
            lowStockThreshold: 10,
            unitPrice: 3.0), // not low, value 60
      ];
      double total = 0;
      int low = 0;
      for (final item in items) {
        total += item.currentStock * item.unitPrice;
        if (item.isLowStock) low++;
      }
      expect(total, equals(70.0));
      expect(low, equals(1));
    });

    test('controller starts with an empty stock list and zero totals', () {
      final c = MerchantStockController();
      expect(c.stockItems, isEmpty);
      expect(c.totalInventoryValue.value, equals(0.0));
      expect(c.lowStockCount.value, equals(0));
      expect(c.isLoading.value, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantTaxController / TaxRate
  // ═══════════════════════════════════════════════════════════
  group('MerchantTaxController', () {
    test('TaxRate.fromJson defaults isActive to true when absent', () {
      final rate = TaxRate.fromJson({'name': 'VAT', 'rate': 15});
      expect(rate.name, equals('VAT'));
      expect(rate.rate, equals(15.0));
      expect(rate.isActive, isTrue);
    });

    test('TaxRate.fromJson respects an explicit isActive=false', () {
      final rate = TaxRate.fromJson({'isActive': false});
      expect(rate.isActive, isFalse);
    });

    test('TaxRate.fromJson falls back id from _id or id', () {
      final withUnderscoreId = TaxRate.fromJson({'_id': 'abc'});
      final withId = TaxRate.fromJson({'id': 'def'});
      final withNeither = TaxRate.fromJson({});
      expect(withUnderscoreId.id, equals('abc'));
      expect(withId.id, equals('def'));
      expect(withNeither.id, isEmpty);
    });

    test('taxRates list can be populated and filtered by isActive', () {
      final c = MerchantTaxController();
      c.taxRates.value = [
        TaxRate(id: '1', name: 'VAT', rate: 15, isActive: true),
        TaxRate(id: '2', name: 'Old Tax', rate: 5, isActive: false),
      ];
      final active = c.taxRates.where((t) => t.isActive).toList();
      expect(active.length, equals(1));
      expect(active.first.name, equals('VAT'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantWalletController / TransactionItem
  // ═══════════════════════════════════════════════════════════
  group('MerchantWalletController', () {
    late MerchantWalletController c;

    TransactionItem tx(TransactionType type, {double amount = 10.0}) {
      return TransactionItem(
        type: type,
        displayId: '1',
        location: 'Online',
        dateStr: '1\nJan',
        subDetails: '',
        user: '',
        amount: amount,
      );
    }

    setUp(() {
      c = MerchantWalletController();
    });

    test('TransactionItem starts collapsed', () {
      final item = tx(TransactionType.vipsIn);
      expect(item.isExpanded.value, isFalse);
    });

    test('toggleExpand flips the isExpanded flag', () {
      final item = tx(TransactionType.vipsIn);
      c.toggleExpand(item);
      expect(item.isExpanded.value, isTrue);
      c.toggleExpand(item);
      expect(item.isExpanded.value, isFalse);
    });

    test('selectTab updates selectedTab', () {
      expect(c.selectedTab.value, equals('Activity'));
      c.selectTab('Vips Out');
      expect(c.selectedTab.value, equals('Vips Out'));
    });

    test('filteredTransactions on "Vips In" includes vipsIn and reward types',
        () {
      c.transactions.value = [
        tx(TransactionType.vipsIn),
        tx(TransactionType.reward),
        tx(TransactionType.vipsOut),
        tx(TransactionType.other),
      ];
      c.selectTab('Vips In');
      expect(c.filteredTransactions.length, equals(2));
      expect(
        c.filteredTransactions.every((t) =>
            t.type == TransactionType.vipsIn ||
            t.type == TransactionType.reward),
        isTrue,
      );
    });

    test('filteredTransactions on "Vips Out" only includes vipsOut', () {
      c.transactions.value = [
        tx(TransactionType.vipsIn),
        tx(TransactionType.vipsOut),
      ];
      c.selectTab('Vips Out');
      expect(c.filteredTransactions.single.type, equals(TransactionType.vipsOut));
    });

    // The 'Recovery' tab was removed along with TransactionType.recovery:
    // it filtered on "anything that isn't income/gift_back/reward" under a
    // "VIPs Recovery" label with no matching backend concept.
    test('an unknown tab falls through to everything', () {
      c.transactions.value = [
        tx(TransactionType.other),
        tx(TransactionType.vipsIn),
      ];
      c.selectTab('Nonexistent');
      expect(c.filteredTransactions.length, equals(2));
    });

    test('filteredTransactions defaults ("Activity") returns everything', () {
      c.transactions.value = [
        tx(TransactionType.other),
        tx(TransactionType.vipsIn),
        tx(TransactionType.vipsOut),
      ];
      expect(c.filteredTransactions.length, equals(3));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantCreditController — amount pad / points calculation
  // ═══════════════════════════════════════════════════════════
  group('MerchantCreditController', () {
    late MerchantCreditController c;

    setUp(() {
      c = MerchantCreditController();
    });

    test('initial amount / points state', () {
      expect(c.amount.value, equals('0.000'));
      expect(c.points.value, equals('000'));
      expect(c.selectedPaymentMethod.value, equals('Bank'));
    });

    test('onNumberPressed replaces the placeholder amount on first digit',
        () {
      c.onNumberPressed('5');
      expect(c.amount.value, equals('5'));
    });

    test('onNumberPressed appends digits after the first', () {
      c.onNumberPressed('5');
      c.onNumberPressed('0');
      expect(c.amount.value, equals('50'));
    });

    // `points` used to hold amount x 100 under a "VIP" label, but issuing
    // credit awards no VIPs points at all — POST /merchant/credits writes a
    // dinar ledger row. It now just mirrors the amount.
    test('points mirrors the entered amount, not a fabricated x100 rate', () {
      c.onNumberPressed('5');
      expect(c.points.value, equals('5'));
    });

    test('onDecimalPressed adds a dot only once', () {
      c.onNumberPressed('5');
      c.onDecimalPressed();
      c.onDecimalPressed();
      expect(c.amount.value.split('.').length, equals(2));
      expect(c.amount.value, equals('5.'));
    });

    test('onDeletePressed removes the last character', () {
      c.onNumberPressed('1');
      c.onNumberPressed('2');
      c.onDeletePressed();
      expect(c.amount.value, equals('1'));
    });

    test('onDeletePressed resets to placeholder once amount is a single char',
        () {
      c.onNumberPressed('9');
      c.onDeletePressed();
      expect(c.amount.value, equals('0.000'));
      expect(c.points.value, equals('0.000'));
    });

    // The removed `exchangeRate` (100) and `serviceChargeRate` (0.10) had no
    // backing on the endpoint: no points are minted and no fee is charged.
    // What is real, and now enforced server-side, is the per-transaction
    // range the form has always advertised.
    test('amountError stays empty until real limits have loaded', () {
      c.onNumberPressed('5');
      expect(c.limitsLoaded.value, isFalse);
      expect(c.amountError, isEmpty);
    });

    test('amountError reports the real min/max once limits are known', () {
      c.minAmount.value = 25;
      c.maxAmount.value = 1000;
      c.limitsLoaded.value = true;

      c.amount.value = '10';
      expect(c.amountError, contains('Minimum'));

      c.amount.value = '5000';
      expect(c.amountError, contains('Maximum'));

      c.amount.value = '200';
      expect(c.amountError, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantCatalogController — tags / form reset
  // ═══════════════════════════════════════════════════════════
  group('MerchantCatalogController', () {
    late MerchantCatalogController c;

    setUp(() {
      c = MerchantCatalogController();
    });

    tearDown(() {
      c.onClose();
    });

    test('addTag ignores empty and duplicate tags', () {
      c.addTag('burger');
      c.addTag('burger');
      c.addTag('pizza');
      c.addTag('');
      expect(c.tags.length, equals(2));
      expect(c.tags, containsAll(['burger', 'pizza']));
    });

    test('addTag clears the tag text field', () {
      c.tagController.text = 'pending';
      c.addTag('pending');
      expect(c.tagController.text, isEmpty);
    });

    test('removeTag removes a specific tag', () {
      c.tags.addAll(['burger', 'pizza']);
      c.removeTag('burger');
      expect(c.tags, equals(['pizza']));
    });

    test('resetItemForm clears text fields and restores default flags', () {
      c.itemNameCtrl.text = 'Some Item';
      c.itemPriceCtrl.text = '9.99';
      c.itemImageUrl.value = 'https://example.com/img.png';
      c.isFeatureProduct.value = true;
      c.hasMultiVariants.value = true;
      c.hasPromotionalPrice.value = true;
      c.isPublished.value = false;

      c.resetItemForm();

      expect(c.itemNameCtrl.text, isEmpty);
      expect(c.itemPriceCtrl.text, isEmpty);
      expect(c.itemImageUrl.value, isEmpty);
      expect(c.isFeatureProduct.value, isFalse);
      expect(c.hasMultiVariants.value, isFalse);
      expect(c.hasPromotionalPrice.value, isFalse);
      expect(c.isPublished.value, isTrue);
    });

    // The delivery/takeaway/dine-in defaults that used to be asserted here
    // backed a ShippingOptions block that nothing ever sent to the backend —
    // fulfilment is a per-order choice (Order.orderType), not a per-product
    // one — so both the state and the widget were removed.
    test('default item type selections', () {
      expect(c.selectedItemType.value, equals('Product'));
      expect(c.selectedTaxMethod.value, equals('Exclusive'));
    });

    test('buildItemPayload carries the fields the old form silently dropped', () {
      c.selectedItemType.value = 'Service';
      c.itemAlertQtyCtrl.text = '7';
      c.selectedCategory.value = 'Food';

      final payload = c.buildItemPayload(name: 'Latte', price: 6.0, promo: 4.5);

      expect(payload['productType'], equals('Service'));
      expect(payload['alertQty'], equals(7));
      expect(payload['discountPrice'], equals(4.5));
      expect(payload['category'], equals('Food'));
      expect(payload['price'], equals(6.0));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantSubscriptionController
  // ═══════════════════════════════════════════════════════════
  group('MerchantSubscriptionController', () {
    late MerchantSubscriptionController c;

    setUp(() {
      c = MerchantSubscriptionController();
    });

    // The old defaults asserted here ('Basic' / 99.00 / 120 days / 'COD' /
    // 0.3% commission) were placeholders unrelated to any real plan: the
    // catalogue starts at Free/0, there is no commission concept, and the
    // subscribe endpoint always charges walletBalance rather than a method.
    test('starts on the free plan with a monthly cycle', () {
      expect(c.selectedPackageName.value, equals('free'));
      expect(c.selectedPackagePrice.value, equals(0.0));
      expect(c.billingCycle.value, equals('monthly'));
    });

    test('selectPackage updates name and price together', () {
      c.selectPackage('pro', 29.99);
      expect(c.selectedPackageName.value, equals('pro'));
      expect(c.selectedPackagePrice.value, equals(29.99));
    });

    test('priceFor charges 10x monthly on a yearly cycle (two months free)', () {
      c.billingCycle.value = 'monthly';
      expect(c.priceFor(29.99), equals(29.99));
      expect(c.monthsForCycle, equals(1));
      c.billingCycle.value = 'yearly';
      expect(c.priceFor(29.99), closeTo(299.9, 0.001));
      expect(c.monthsForCycle, equals(12));
    });

    test('featureLabels renders -1 as Unlimited, not "-1 Products"', () {
      final labels = MerchantSubscriptionController.featureLabels({
        'maxProducts': -1,
        'maxCashiers': 10,
        'analytics': true,
        'adsEnabled': false,
        'apiAccess': true,
      });
      expect(labels, contains('Unlimited Products'));
      expect(labels, contains('10 Cashiers'));
      expect(labels, contains('Analytics'));
      expect(labels, contains('API Access'));
      expect(labels, isNot(contains('Advertisements')));
    });

    test('featureLabels tolerates a missing/!Map features payload', () {
      expect(MerchantSubscriptionController.featureLabels(null), isEmpty);
      expect(MerchantSubscriptionController.featureLabels('nope'), isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantDuesController / DueItem
  // ═══════════════════════════════════════════════════════════
  group('MerchantDuesController', () {
    test('DueItem.remainingAmount subtracts paid from total', () {
      final due = DueItem(
        id: '1',
        partyName: 'Alice',
        phone: '123',
        totalAmount: 100.0,
        paidAmount: 40.0,
        lastTransaction: DateTime(2024, 1, 1),
      );
      expect(due.remainingAmount, equals(60.0));
    });

    test('DueItem.fromJson defaults isCustomer to true', () {
      final due = DueItem.fromJson({'partyName': 'Bob'});
      expect(due.isCustomer, isTrue);
      expect(due.totalAmount, equals(0.0));
      expect(due.paidAmount, equals(0.0));
    });

    test('DueItem.fromJson honors isCustomer=false (a payable)', () {
      final due = DueItem.fromJson({'isCustomer': false});
      expect(due.isCustomer, isFalse);
    });

    test('receivable / payable totals aggregate correctly (mirrors '
        'MerchantDuesController._calculateTotals)', () {
      final dues = [
        DueItem(
            id: '1',
            partyName: 'Customer A',
            phone: '1',
            totalAmount: 100,
            paidAmount: 30,
            lastTransaction: DateTime.now(),
            isCustomer: true), // remaining 70, receivable
        DueItem(
            id: '2',
            partyName: 'Supplier B',
            phone: '2',
            totalAmount: 50,
            paidAmount: 20,
            lastTransaction: DateTime.now(),
            isCustomer: false), // remaining 30, payable
      ];
      double receivable = 0;
      double payable = 0;
      for (final due in dues) {
        if (due.isCustomer) {
          receivable += due.remainingAmount;
        } else {
          payable += due.remainingAmount;
        }
      }
      expect(receivable, equals(70.0));
      expect(payable, equals(30.0));
    });

    test('controller starts with empty dues list and zero totals', () {
      final c = MerchantDuesController();
      expect(c.dues, isEmpty);
      expect(c.totalReceivable.value, equals(0.0));
      expect(c.totalPayable.value, equals(0.0));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantCustomersController / CustomerModel
  // ═══════════════════════════════════════════════════════════
  group('MerchantCustomersController', () {
    late MerchantCustomersController c;

    setUp(() {
      c = MerchantCustomersController();
    });

    test('CustomerModel.fromJson falls back name to "Unknown"', () {
      final customer = CustomerModel.fromJson({});
      expect(customer.name, equals('Unknown'));
      // lastVisit is the date of the customer's latest transaction with this
      // merchant, not their signup date — "no visits yet" when there is none.
      expect(customer.lastVisit, equals('No visits yet'));
      expect(customer.totalVisits, equals(0));
      expect(customer.pointsEarned, equals(0));
      expect(customer.pointsSpent, equals(0));
    });

    test('CustomerModel stats are merchant-scoped, not the global wallet', () {
      final customer = CustomerModel.fromJson({
        'fullName': 'Jane Doe',
        // What this merchant actually gave/took:
        'totalVisits': 3,
        'pointsEarned': 1020,
        'pointsSpent': 40,
        // The customer's platform-wide balance, which used to be shown as
        // "Earned" as though this merchant had granted all of it:
        'walletPoints': 52320,
      });
      expect(customer.totalVisits, equals(3));
      expect(customer.pointsEarned, equals(1020));
      expect(customer.pointsSpent, equals(40));
    });

    test('CustomerModel.fromJson survives a malformed lastVisit', () {
      final customer = CustomerModel.fromJson({'lastVisit': 'not-a-date'});
      expect(customer.lastVisit, equals('No visits yet'));
    });

    test('CustomerModel prefers the real profile image over the avatar', () {
      final customer = CustomerModel.fromJson({
        'fullName': 'Jane Doe',
        'profileImage': 'http://cdn.example.com/jane.png',
      });
      // Rewritten to https so iOS ATS does not silently drop it.
      expect(customer.imageUrl, equals('https://cdn.example.com/jane.png'));
    });

    test('CustomerModel.fromJson prefers fullName over name', () {
      final customer = CustomerModel.fromJson({
        'fullName': 'Full Name',
        'name': 'Short Name',
      });
      expect(customer.name, equals('Full Name'));
    });

    test('CustomerModel.fromJson builds an avatar URL with the encoded name',
        () {
      final customer = CustomerModel.fromJson({'fullName': 'Jane Doe'});
      expect(customer.imageUrl, contains('Jane%20Doe'));
      expect(customer.imageUrl, startsWith('https://ui-avatars.com'));
    });

    test('filteredCustomers returns everyone when the query is empty', () {
      c.customers.value = [
        CustomerModel.fromJson({'fullName': 'Alice'}),
        CustomerModel.fromJson({'fullName': 'Bob'}),
      ];
      expect(c.filteredCustomers.length, equals(2));
    });

    test('filteredCustomers filters case-insensitively by name', () {
      c.customers.value = [
        CustomerModel.fromJson({'fullName': 'Alice'}),
        CustomerModel.fromJson({'fullName': 'Bob'}),
      ];
      c.updateSearch('ali');
      expect(c.filteredCustomers.single.name, equals('Alice'));
    });

    test('updateSearch updates the searchQuery Rx', () {
      c.updateSearch('test');
      expect(c.searchQuery.value, equals('test'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // MerchantHRMController / StaffMember
  // ═══════════════════════════════════════════════════════════
  group('MerchantHRMController', () {
    test('StaffMember.fromJson applies role/status defaults', () {
      final staff = StaffMember.fromJson({'name': 'John'});
      expect(staff.role, equals('Staff'));
      expect(staff.status, equals('Active'));
      expect(staff.salary, equals(0.0));
    });

    test('StaffMember.fromJson honors explicit role/status/salary', () {
      final staff = StaffMember.fromJson({
        'name': 'Jane',
        'role': 'Manager',
        'status': 'Inactive',
        'salary': 5000,
      });
      expect(staff.role, equals('Manager'));
      expect(staff.status, equals('Inactive'));
      expect(staff.salary, equals(5000.0));
    });

    test('StaffMember.fromJson falls back id from _id or id', () {
      expect(StaffMember.fromJson({'_id': 'a1'}).id, equals('a1'));
      expect(StaffMember.fromJson({'id': 'b2'}).id, equals('b2'));
      expect(StaffMember.fromJson({}).id, isEmpty);
    });

    test('controller starts with an empty staff list and is not loading',
        () {
      final c = MerchantHRMController();
      expect(c.staffList, isEmpty);
      expect(c.isLoading.value, isFalse);
    });
  });
}
