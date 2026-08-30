import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';

/// The till: session state, the product grid and the server-side cart.
///
/// Every total on screen is the server's, never computed here. The cart lives
/// on the session document, so this controller holds no pricing logic of its
/// own — that is what keeps the displayed total and the charged total the
/// same number.
class PosController extends GetxController {
  final AdminApiService _api = AdminApiService();

  // ── Session ──
  final RxBool isLoading = false.obs;
  final RxBool isBusy = false.obs;
  final Rxn<Map<String, dynamic>> session = Rxn<Map<String, dynamic>>();
  final RxString merchantName = ''.obs;

  // ── Catalogue ──
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> merchants = <Map<String, dynamic>>[].obs;
  final TextEditingController productSearchController = TextEditingController();
  final RxString productQuery = ''.obs;

  // ── Cart ──
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> totals = <String, dynamic>{}.obs;
  final RxString customerName = ''.obs;
  final RxNum discount = RxNum(0);
  final RxString discountType = 'fixed'.obs;

  Timer? _debounce;

  bool get hasSession => session.value != null;
  String get merchantId => adminString(session.value?['merchantId']);
  int get itemCount =>
      cartItems.fold(0, (sum, item) => sum + adminInt(item['quantity']));
  num get total => totals['total'] is num ? totals['total'] as num : 0;

  /// The catalogue filtered by the search box. Filtered client-side because
  /// the whole list is already loaded for the grid.
  List<Map<String, dynamic>> get visibleProducts {
    final query = productQuery.value.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products
        .where((p) =>
            adminString(p['name']).toLowerCase().contains(query) ||
            adminString(p['code']).toLowerCase().contains(query) ||
            adminString(p['category']).toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final response = await _api.posSession();
      final data = response.data;
      final open = data is Map ? data['session'] : null;

      if (open is Map) {
        session.value = Map<String, dynamic>.from(open);
        merchantName.value = adminString((data as Map)['merchantName']);
        _adoptCart(data['cart']);
        await loadProducts();
      } else {
        session.value = null;
        cartItems.clear();
        totals.clear();
        await loadMerchants();
      }
    } catch (e) {
      debugPrint('[POS] load failed: $e');
      adminToast('Till unavailable',
          'Could not reach the server. Please try again.', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Only merchants that can actually be sold from are offered — a
  /// deactivated store is refused server-side when opening a till.
  Future<void> loadMerchants() async {
    try {
      final response = await _api.merchants(limit: 100, status: 'active');
      if (response.success && response.data is Map) {
        merchants.value = adminItems(response.data);
      }
    } catch (e) {
      debugPrint('[POS] loadMerchants failed: $e');
    }
  }

  Future<void> loadProducts() async {
    if (merchantId.isEmpty) return;
    try {
      final response = await _api.merchantProducts(merchantId);
      final data = response.data;
      products.value = data is List
          ? data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : adminItems(data);
    } catch (e) {
      debugPrint('[POS] loadProducts failed: $e');
    }
  }

  void _adoptCart(dynamic cart) {
    if (cart is! Map) return;
    cartItems.value = adminItems(cart);
    final t = cart['totals'];
    totals.value = t is Map ? Map<String, dynamic>.from(t) : {};
    customerName.value = adminString(cart['customerName']);
    discount.value = cart['discount'] is num ? cart['discount'] as num : 0;
    discountType.value = adminString(cart['discountType'], 'fixed');
  }

  void onProductSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      productQuery.value = value;
    });
  }

  /// Runs a cart mutation and adopts whatever cart the server returns.
  ///
  /// The response is the source of truth rather than a local edit: the server
  /// re-checks stock on every change, so optimistically updating here would
  /// let the screen disagree with what can actually be sold.
  Future<bool> _mutate(Future<ApiResponseLike> Function() action,
      {String? successTitle}) async {
    if (isBusy.value) return false;
    isBusy.value = true;
    try {
      final response = await action();
      if (response.success) {
        _adoptCart(response.data);
        if (successTitle != null) {
          adminToast(successTitle, response.message, isError: false);
        }
        return true;
      }
      adminToast('Not possible', response.message, isError: true);
      return false;
    } catch (e) {
      debugPrint('[POS] cart action failed: $e');
      adminToast('Not possible',
          'Could not reach the server. Please try again.', isError: true);
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> startSession(String merchantIdToOpen, num openingFloat) async {
    if (isBusy.value) return false;
    isBusy.value = true;
    try {
      final response = await _api.posStartSession(merchantIdToOpen, openingFloat);
      if (response.success) {
        adminToast('Till open', response.message, isError: false);
        await load();
        return true;
      }
      adminToast('Could not open the till', response.message, isError: true);
      return false;
    } catch (e) {
      debugPrint('[POS] startSession failed: $e');
      adminToast('Could not open the till',
          'Could not reach the server. Please try again.', isError: true);
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  Future<Map<String, dynamic>?> endSession(num closingCount) async {
    if (isBusy.value) return null;
    isBusy.value = true;
    try {
      final response = await _api.posEndSession(closingCount);
      if (response.success && response.data is Map) {
        adminToast('Till closed', response.message, isError: false);
        final result = Map<String, dynamic>.from(response.data as Map);
        await load();
        return result;
      }
      // The server refuses to close over an unfinished sale — that message
      // tells the operator exactly what to do, so it is shown verbatim.
      adminToast('Could not close the till', response.message, isError: true);
      return null;
    } catch (e) {
      debugPrint('[POS] endSession failed: $e');
      adminToast('Could not close the till',
          'Could not reach the server. Please try again.', isError: true);
      return null;
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> addProduct(String productId, {int quantity = 1}) =>
      _mutate(() => _api.posAddToCart(productId, quantity).then(_wrap));

  Future<bool> setQuantity(String itemId, int quantity) =>
      _mutate(() => _api.posUpdateCartLine(itemId, quantity).then(_wrap));

  Future<bool> removeLine(String itemId) =>
      _mutate(() => _api.posRemoveCartLine(itemId).then(_wrap));

  Future<bool> clearCart() =>
      _mutate(() => _api.posClearCart().then(_wrap), successTitle: 'Cart cleared');

  Future<bool> applyDiscount(num amount, String type) =>
      _mutate(() => _api.posApplyDiscount(amount, type).then(_wrap));

  Future<bool> attachCustomer({String? customerId, String? name, String? phone}) =>
      _mutate(
        () => _api
            .posAttachCustomer(customerId: customerId, name: name, phone: phone)
            .then(_wrap),
        successTitle: 'Customer attached',
      );

  /// Settles the sale. Returns the created invoice so the caller can show it.
  Future<Map<String, dynamic>?> checkout({
    required String paymentMethod,
    required num amountPaid,
    String note = '',
  }) async {
    if (isBusy.value) return null;
    isBusy.value = true;
    try {
      final response = await _api.posCreateInvoice(
        paymentMethod: paymentMethod,
        amountPaid: amountPaid,
        note: note,
      );
      if (response.success && response.data is Map) {
        final invoice = (response.data as Map)['invoice'];
        adminToast('Sale complete', response.message, isError: false);
        // Reload rather than clearing locally: the sale also moved stock, so
        // the product grid's quantities are now stale.
        await load();
        return invoice is Map ? Map<String, dynamic>.from(invoice) : null;
      }
      adminToast('Sale not completed', response.message, isError: true);
      return null;
    } catch (e) {
      debugPrint('[POS] checkout failed: $e');
      adminToast('Sale not completed',
          'Could not reach the server. Please try again.', isError: true);
      return null;
    } finally {
      isBusy.value = false;
    }
  }

  int stockOf(Map<String, dynamic> product) => adminInt(product['stock']);

  /// The price the till will actually charge — the discount price when the
  /// merchant has set one, matching what the server freezes onto the line.
  num sellingPrice(Map<String, dynamic> product) {
    final discounted = product['discountPrice'];
    if (discounted is num && discounted > 0) return discounted;
    return adminDouble(product['price']);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    productSearchController.dispose();
    super.onClose();
  }
}

/// Minimal structural view of ApiResponse so [_mutate] can accept any of the
/// service's cart calls without each one needing its own wrapper.
class ApiResponseLike {
  final bool success;
  final String message;
  final dynamic data;

  const ApiResponseLike(this.success, this.message, this.data);
}

ApiResponseLike _wrap(dynamic response) =>
    ApiResponseLike(response.success as bool, response.message as String, response.data);
