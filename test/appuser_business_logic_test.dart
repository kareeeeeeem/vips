// Unit tests for the business logic in the appuser GetX controllers and
// ApiService that carry the most weight in the app: cart totals, order
// filtering, checkout fee rules, and the auth-token lifecycle.
//
// Pattern (matches full_app_qa_test.dart / merchant_qa_test.dart): controllers
// are constructed directly (never Get.put/onInit) so their network-calling
// onInit() bodies never run — we drive the reactive fields and pure
// getters/methods directly instead.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/Cart/controllers/cart_controller.dart';
import 'package:vip/appuser/modules/checkout/controllers/checkout_controller.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';
import 'package:vip/appuser/modules/profile/controllers/profile_controller.dart';
import 'package:vip/core/services/api_service.dart';

CartItem _item({
  String id = 'p1',
  double price = 10.0,
  int quantity = 1,
  CartItemType type = CartItemType.product,
  Map<String, dynamic>? options,
  bool isFavorite = false,
}) {
  return CartItem(
    id: id,
    name: 'Item $id',
    description: 'desc',
    price: price,
    quantity: quantity,
    type: type,
    options: options,
    isFavorite: isFavorite,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════
  // CartController
  // ═══════════════════════════════════════════════════════════
  group('CartController', () {
    late CartController cart;

    setUp(() {
      cart = CartController();
    });

    test('CartItem.totalPrice multiplies price by quantity', () {
      final item = _item(price: 12.5, quantity: 3);
      expect(item.totalPrice, equals(37.5));
    });

    test('CartItem toJson/fromJson round-trips correctly', () {
      final item = _item(id: 'x1', price: 9.99, quantity: 2);
      final json = item.toJson();
      final restored = CartItem.fromJson(json);
      expect(restored.id, equals('x1'));
      expect(restored.price, equals(9.99));
      expect(restored.quantity, equals(2));
    });

    test('CartItem.fromJson defaults quantity to 1 when absent', () {
      final restored = CartItem.fromJson({
        'id': 'x2',
        'name': 'N',
        'description': 'D',
        'price': 5,
      });
      expect(restored.quantity, equals(1));
      expect(restored.isFavorite, isFalse);
    });

    test('CartItem.copyWith overrides only the given fields', () {
      final item = _item(id: 'x3', price: 4.0, quantity: 1);
      final copy = item.copyWith(quantity: 5);
      expect(copy.id, equals('x3'));
      expect(copy.price, equals(4.0));
      expect(copy.quantity, equals(5));
    });

    test('subtotal sums totalPrice across all items', () {
      cart.cartItems.addAll([
        _item(id: 'a', price: 10, quantity: 2),
        _item(id: 'b', price: 5, quantity: 1),
      ]);
      expect(cart.subtotal, equals(25.0));
    });

    test('itemCount sums quantities, not item count', () {
      cart.cartItems.addAll([
        _item(id: 'a', quantity: 2),
        _item(id: 'b', quantity: 3),
      ]);
      expect(cart.itemCount, equals(5));
    });

    test('deliveryFee is charged for delivery (type 0) only', () {
      cart.selectedOrderType.value = 0;
      expect(cart.deliveryFee, equals(6.0));

      cart.selectedOrderType.value = 1; // takeaway
      expect(cart.deliveryFee, equals(0.0));

      cart.selectedOrderType.value = 2; // in-store
      expect(cart.deliveryFee, equals(0.0));
    });

    test('vatTax is 7% of subtotal', () {
      cart.cartItems.add(_item(price: 100, quantity: 1));
      expect(cart.vatTax, closeTo(7.0, 0.001));
    });

    test('tipAmount prefers selectedTipAmount over customTipAmount', () {
      cart.selectedTipAmount.value = 5.0;
      cart.customTipAmount.value = 2.0;
      expect(cart.tipAmount, equals(5.0));

      cart.selectedTipAmount.value = 0.0;
      expect(cart.tipAmount, equals(2.0));
    });

    test('setTipAmount clears any custom tip', () {
      cart.customTipAmount.value = 9.0;
      cart.setTipAmount(3.0);
      expect(cart.selectedTipAmount.value, equals(3.0));
      expect(cart.customTipAmount.value, equals(0.0));
    });

    test('setCustomTip clears the preset tip', () {
      cart.selectedTipAmount.value = 4.0;
      cart.setCustomTip(1.5);
      expect(cart.customTipAmount.value, equals(1.5));
      expect(cart.selectedTipAmount.value, equals(0.0));
    });

    test('total combines subtotal, delivery, discount, tax and tip', () {
      cart.selectedOrderType.value = 0; // delivery => fee 6.0
      cart.cartItems.add(_item(price: 100, quantity: 1)); // subtotal 100
      cart.setTipAmount(2.0);
      // total = 100 (subtotal) + 6 (delivery) - 0 (discount) + 0 (service) + 7 (vat 7%) + 2 (tip)
      expect(cart.total, closeTo(115.0, 0.001));
    });

    test('setOrderType resets the selected time only for delivery', () {
      cart.selectedTime.value = '10:00';
      cart.setOrderType(1); // takeaway — time untouched
      expect(cart.selectedTime.value, equals('10:00'));

      cart.setOrderType(0); // delivery — time reset
      expect(cart.selectedTime.value, equals(''));
    });

    test('selectedPaymentMethodLabel maps known methods to display names', () {
      cart.selectedPaymentMethod.value = 'paypal';
      expect(cart.selectedPaymentMethodLabel, equals('Paypal'));
      cart.selectedPaymentMethod.value = 'cash_on_delivery';
      expect(cart.selectedPaymentMethodLabel, equals('Cash on Delivery'));
    });

    test('addItem merges quantity for identical id + options', () {
      cart.addItem(_item(id: 'a', quantity: 1, options: {'size': 'L'}));
      cart.addItem(_item(id: 'a', quantity: 2, options: {'size': 'L'}));
      expect(cart.cartItems.length, equals(1));
      expect(cart.cartItems.first.quantity, equals(3));
    });

    test('addItem keeps separate lines for different options', () {
      cart.addItem(_item(id: 'a', quantity: 1, options: {'size': 'L'}));
      cart.addItem(_item(id: 'a', quantity: 1, options: {'size': 'S'}));
      expect(cart.cartItems.length, equals(2));
    });

    test('getItemCountByType / getTotalByType filter by item type', () {
      cart.cartItems.addAll([
        _item(id: 'a', price: 10, quantity: 2, type: CartItemType.food),
        _item(id: 'b', price: 5, quantity: 1, type: CartItemType.product),
      ]);
      expect(cart.getItemCountByType(CartItemType.food), equals(2));
      expect(cart.getTotalByType(CartItemType.food), equals(20.0));
      expect(cart.getTotalByType(CartItemType.product), equals(5.0));
    });

    test('containsItem / getItemQuantity reflect cart state', () {
      cart.cartItems.add(_item(id: 'z', quantity: 4));
      expect(cart.containsItem('z'), isTrue);
      expect(cart.containsItem('missing'), isFalse);
      expect(cart.getItemQuantity('z'), equals(4));
      expect(cart.getItemQuantity('missing'), equals(0));
    });

    test('updateItemQuantity updates quantity, removes at zero', () {
      cart.cartItems.add(_item(id: 'z', quantity: 1));
      cart.updateItemQuantity('z', 5);
      expect(cart.getItemQuantity('z'), equals(5));

      cart.updateItemQuantity('z', 0);
      expect(cart.containsItem('z'), isFalse);
    });

    test('favoriteItems returns only favorited items', () {
      cart.cartItems.addAll([
        _item(id: 'a', isFavorite: true),
        _item(id: 'b', isFavorite: false),
      ]);
      expect(cart.favoriteItems.map((i) => i.id), equals(['a']));
    });

    test('toggleFavorite flips isFavorite for the matching item', () {
      cart.cartItems.add(_item(id: 'a', isFavorite: false));
      cart.toggleFavorite(cart.cartItems.first);
      expect(cart.cartItems.first.isFavorite, isTrue);
    });

    test('increaseQuantity / decreaseQuantity respect the quantity floor', () {
      cart.cartItems.add(_item(id: 'a', quantity: 1));
      cart.increaseQuantity(cart.cartItems.first);
      expect(cart.cartItems.first.quantity, equals(2));

      cart.decreaseQuantity(cart.cartItems.first);
      expect(cart.cartItems.first.quantity, equals(1));

      // Should not go below 1.
      cart.decreaseQuantity(cart.cartItems.first);
      expect(cart.cartItems.first.quantity, equals(1));
    });

    test('toggleSelectionMode clears selection when turning off', () {
      cart.isSelectionMode.value = true;
      cart.selectedItems.add('a');
      cart.toggleSelectionMode();
      expect(cart.isSelectionMode.value, isFalse);
      expect(cart.selectedItems, isEmpty);
    });

    test('toggleItemSelection adds and removes ids', () {
      cart.toggleItemSelection('a');
      expect(cart.selectedItems, contains('a'));
      cart.toggleItemSelection('a');
      expect(cart.selectedItems, isNot(contains('a')));
    });

    test('selectAllItems toggles between all-selected and none', () {
      cart.cartItems.addAll([_item(id: 'a'), _item(id: 'b')]);
      cart.selectAllItems();
      expect(cart.selectedItems.length, equals(2));
      cart.selectAllItems();
      expect(cart.selectedItems, isEmpty);
    });

    test('removeCoupon resets coupon code and discount', () {
      cart.couponCode.value = 'SAVE10';
      cart.appliedCouponDiscount.value = 10.0;
      cart.removeCoupon();
      expect(cart.couponCode.value, isEmpty);
      expect(cart.appliedCouponDiscount.value, equals(0.0));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // HomeController — filter/search/sort helpers
  // ═══════════════════════════════════════════════════════════
  group('HomeController business logic', () {
    late HomeController home;

    setUp(() {
      home = HomeController();
    });

    test('getHotDealsByCategory filters by category', () {
      home.hotDeals = [
        {'category': 'food', 'title': 'A'},
        {'category': 'tech', 'title': 'B'},
      ];
      expect(home.getHotDealsByCategory('food').single['title'], equals('A'));
    });

    test('getTopRatedDeals sorts by rating desc and caps at 3', () {
      home.hotDeals = [
        {'title': 'low', 'rating': 2.0},
        {'title': 'high', 'rating': 4.5},
        {'title': 'mid', 'rating': 3.0},
        {'title': 'extra', 'rating': 1.0},
      ];
      final top = home.getTopRatedDeals();
      expect(top.length, equals(3));
      expect(top.first['title'], equals('high'));
    });

    test('getBestDiscountDeals sorts by discount desc', () {
      home.hotDeals = [
        {'title': 'a', 'discount': 10},
        {'title': 'b', 'discount': 50},
      ];
      expect(home.getBestDiscountDeals().first['title'], equals('b'));
    });

    test('searchOutings matches title, subtitle, category or location', () {
      home.outings = [
        {
          'title': 'Beach Day',
          'subtitle': 'sun',
          'category': 'outdoor',
          'location': 'City',
        },
        {
          'title': 'Museum',
          'subtitle': 'art',
          'category': 'indoor',
          'location': 'Town',
        },
      ];
      expect(home.searchOutings('beach').length, equals(1));
      expect(home.searchOutings('indoor').length, equals(1));
      expect(home.searchOutings('').length, equals(2));
    });

    test('getOutingsByType / getOutingsByLocation filter correctly', () {
      home.outings = [
        {'type': 'mall', 'location': 'Downtown'},
        {'type': 'outdoor', 'location': 'Uptown'},
      ];
      expect(home.getOutingsByType('mall').length, equals(1));
      expect(home.getOutingsByLocation('Uptown').length, equals(1));
    });

    test('getPopularMalls returns only malls, capped at 4', () {
      home.outings = List.generate(
        6,
        (i) => {'type': 'mall', 'title': 'Mall $i'},
      );
      expect(home.getPopularMalls().length, equals(4));
    });

    test('toggleOutingFavorite flips the isFavorite flag', () {
      final outing = {'isFavorite': false};
      home.toggleOutingFavorite(outing);
      expect(outing['isFavorite'], isTrue);
    });

    test('getMerchantsByCategory / searchMerchants filter merchants', () {
      home.trendingMerchants = [
        {'name': 'Pizza Place', 'category': 'food', 'isTrending': true},
        {'name': 'Tech Store', 'category': 'tech', 'isTrending': false},
      ];
      expect(home.getMerchantsByCategory('food').single['name'],
          equals('Pizza Place'));
      expect(home.searchMerchants('tech').single['name'],
          equals('Tech Store'));
      expect(home.getTrendingMerchantsOnly().length, equals(1));
    });

    test('getBestDiscountMerchants sorts descending by discountPercentage',
        () {
      home.trendingMerchants = [
        {'name': 'Low', 'discountPercentage': 5},
        {'name': 'High', 'discountPercentage': 40},
      ];
      expect(
        home.getBestDiscountMerchants().first['name'],
        equals('High'),
      );
    });

    test('getFavoriteMerchants returns only favorited merchants', () {
      home.trendingMerchants = [
        {'name': 'Fav', 'isFavorite': true},
        {'name': 'NotFav', 'isFavorite': false},
      ];
      expect(home.getFavoriteMerchants().single['name'], equals('Fav'));
    });

    test('getNewMerchants returns the last 4 merchants reversed', () {
      home.trendingMerchants = List.generate(6, (i) => {'name': 'M$i'});
      final newest = home.getNewMerchants();
      expect(newest.length, equals(4));
      expect(newest.first['name'], equals('M5'));
    });

    test('toggleMerchantFavorite flips the flag on the given map', () {
      final merchant = {'isFavorite': true};
      home.toggleMerchantFavorite(merchant);
      expect(merchant['isFavorite'], isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ProfileController — order filtering & role/service lookups
  // ═══════════════════════════════════════════════════════════
  group('ProfileController business logic', () {
    late ProfileController profile;

    setUp(() {
      profile = ProfileController();
    });

    test('filteredOrders defaults to Active — excludes delivered/cancelled',
        () {
      profile.ordersList.addAll([
        {'status': 'Delivered', 'type': 'Delivery'},
        {'status': 'Cancelled', 'type': 'Delivery'},
        {'status': 'Pending', 'type': 'Delivery'},
      ]);
      expect(profile.filteredOrders.length, equals(1));
    });

    test('changeOrderFilter("Done") returns only delivered orders', () {
      profile.ordersList.addAll([
        {'status': 'Delivered', 'type': 'Delivery'},
        {'status': 'Pending', 'type': 'Delivery'},
      ]);
      profile.changeOrderFilter('Done');
      expect(profile.filteredOrders.single['status'], equals('Delivered'));
    });

    test('changeTypeFilter narrows results by delivery type', () {
      profile.ordersList.addAll([
        {'status': 'Pending', 'type': 'Delivery'},
        {'status': 'Pending', 'type': 'Pickup'},
      ]);
      profile.changeOrderFilter('Active');
      profile.changeTypeFilter('Pickup');
      expect(profile.filteredOrders.single['type'], equals('Pickup'));
    });

    test('activeOrdersCount / doneOrdersCount / refundedOrdersCount tally correctly',
        () {
      profile.ordersList.addAll([
        {'status': 'Pending'},
        {'status': 'Delivered'},
        {'status': 'Delivered'},
        {'status': 'Refunded'},
      ]);
      // activeOrdersCount only excludes Delivered/Cancelled, so a Refunded
      // order still counts as "active" per the controller's own definition.
      expect(profile.activeOrdersCount, equals(2));
      expect(profile.doneOrdersCount, equals(2));
      expect(profile.refundedOrdersCount, equals(1));
    });

    test('primaryColor is always the Customer color (no other role is reachable)', () {
      expect(profile.primaryColor, equals(Colors.orange));
    });

    test('servicesList returns the real Customer menu', () {
      expect(
        profile.servicesList.any((s) => s['title'] == 'VIPs Club'),
        isTrue,
      );
    });

    test('formatDate renders as month/day', () {
      expect(profile.formatDate(DateTime(2026, 3, 7)), equals('3/7'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // CheckoutController — order type / tip rules
  // ═══════════════════════════════════════════════════════════
  group('CheckoutController business logic', () {
    late CheckoutController checkout;

    setUp(() {
      checkout = CheckoutController();
    });

    // selectOrderType() builds a snackbar using ScreenUtil's `.w`/`.r`
    // extensions, which require ScreenUtilInit to have run in a widget tree.
    testWidgets('selectOrderType(delivery) sets a 6.0 delivery fee', (
      tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(home: SizedBox()),
        ),
      );

      checkout.selectOrderType(OrderType.takeaway);
      expect(checkout.deliveryFee.value, equals(0.0));

      checkout.selectOrderType(OrderType.delivery);
      expect(checkout.deliveryFee.value, equals(6.0));
      expect(checkout.selectedOrderType.value, equals(OrderType.delivery));
    });

    testWidgets('selectOrderType(inStore) waives the delivery fee', (
      tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(home: SizedBox()),
        ),
      );

      checkout.selectOrderType(OrderType.inStore);
      expect(checkout.deliveryFee.value, equals(0.0));
    });

    test('selectTip sets the preset tip and clears any custom tip', () {
      checkout.customTip.value = 5.0;
      checkout.selectTip(2.0);
      expect(checkout.selectedTip.value, equals(2.0));
      expect(checkout.customTip.value, equals(0.0));
    });

    test('grandTotal adds subtotal, delivery fee, tip and subtracts discount',
        () {
      checkout.subtotal.value = 20.0;
      checkout.deliveryFee.value = 6.0;
      checkout.discount.value = 1.0;
      checkout.selectedTip.value = 3.0;
      checkout.customTip.value = 0.0;
      expect(checkout.grandTotal, equals(28.0));
    });

    test('grandTotal falls back to customTip when no preset tip is selected',
        () {
      checkout.subtotal.value = 10.0;
      checkout.deliveryFee.value = 0.0;
      checkout.discount.value = 0.0;
      checkout.selectedTip.value = 0.0;
      checkout.customTip.value = 4.0;
      expect(checkout.grandTotal, equals(14.0));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ApiService — token lifecycle (no network involved)
  // ═══════════════════════════════════════════════════════════
  group('ApiService token lifecycle', () {
    test('isLoggedIn is false until a token is set', () async {
      await ApiService().clearToken();
      expect(ApiService().isLoggedIn, isFalse);
    });

    test('setToken persists the token and flips isLoggedIn to true',
        () async {
      await ApiService().setToken('abc123');
      expect(ApiService().isLoggedIn, isTrue);
    });

    test('clearToken removes the token and flips isLoggedIn back to false',
        () async {
      await ApiService().setToken('abc123');
      await ApiService().clearToken();
      expect(ApiService().isLoggedIn, isFalse);
    });

    test('init() restores a previously saved token from SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'saved-token'});
      await ApiService().init();
      expect(ApiService().isLoggedIn, isTrue);
      await ApiService().clearToken();
    });
  });
}
