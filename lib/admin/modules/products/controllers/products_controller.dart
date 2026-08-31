import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../services/admin_api_service.dart';
import '../../auth/controllers/admin_auth_controller.dart';

/// The product catalogue across every merchant.
///
/// The console could already see stock levels and what sold, but not the
/// products themselves — so until this screen existed a wrong price had to be
/// corrected from the merchant's own app.
class AdminProductsController extends AdminListController {
  final RxString merchantFilter = ''.obs;
  final RxString categoryFilter = ''.obs;
  final RxString statusFilter = ''.obs;

  /// Categories present in the current result set, sent by the backend so the
  /// chips can never offer one that matches nothing.
  final RxList<String> categories = <String>[].obs;

  /// Merchants to pick from when adding a product. Loaded lazily, because
  /// only the add sheet needs them.
  final RxList<Map<String, dynamic>> merchants = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMerchants = false.obs;

  static const List<String> statuses = ['active', 'inactive', 'no_cost'];

  static String statusLabel(String status) => switch (status) {
        'active' => 'Active',
        'inactive' => 'Hidden',
        // The products holding the profit report's cost coverage down, which
        // is the whole reason this filter exists.
        'no_cost' => 'No cost set',
        _ => 'All',
      };

  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>() ? Get.find<AdminAuthController>() : null;

  bool get canCreate => _auth?.can('products.create') ?? false;
  bool get canUpdate => _auth?.can('products.update') ?? false;
  bool get canDelete => _auth?.can('products.delete') ?? false;

  @override
  Future<ApiResponse> fetch() => api.products(
        page: page.value,
        limit: 20,
        search: search.value.isEmpty ? null : search.value,
        merchantId: merchantFilter.value.isEmpty ? null : merchantFilter.value,
        category: categoryFilter.value.isEmpty ? null : categoryFilter.value,
        status: statusFilter.value.isEmpty ? null : statusFilter.value,
      );

  @override
  void parse(Map<String, dynamic> data) {
    final raw = data['categories'];
    if (raw is List) {
      categories.value = raw.map((c) => c.toString()).where((c) => c.isNotEmpty).toList();
    }
  }

  void setCategory(String value) {
    if (categoryFilter.value == value) return;
    categoryFilter.value = value;
    load(resetPage: true);
  }

  void setStatus(String value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    load(resetPage: true);
  }

  void setMerchant(String value) {
    if (merchantFilter.value == value) return;
    merchantFilter.value = value;
    load(resetPage: true);
  }

  /// Merchants for the add sheet's picker. A product cannot exist without an
  /// owner, so the sheet cannot be filled in without this list.
  Future<void> loadMerchants() async {
    if (merchants.isNotEmpty || isLoadingMerchants.value) return;
    isLoadingMerchants.value = true;
    try {
      final response = await api.merchants(limit: 100, status: 'active');
      if (response.success && response.data is Map) {
        merchants.value = adminItems(Map<String, dynamic>.from(response.data as Map));
      }
    } finally {
      isLoadingMerchants.value = false;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> body) => mutate(
        () => api.createProduct(body),
        successTitle: 'Product added',
        failureTitle: 'Could not add the product',
      );

  Future<bool> updateProduct(String id, Map<String, dynamic> changes) => mutate(
        () => api.updateProduct(id, changes),
        successTitle: 'Product updated',
        failureTitle: 'Could not update the product',
      );

  Future<bool> deleteProduct(String id) => mutate(
        () => api.deleteProduct(id),
        successTitle: 'Product deleted',
        failureTitle: 'Could not delete the product',
      );

  Future<bool> setActive(String id, bool active) => mutate(
        () => api.updateProduct(id, {'isActive': active}),
        successTitle: active ? 'Product is live' : 'Product hidden',
        failureTitle: 'Could not change visibility',
      );

  /// Why a product cannot be deleted, or null when it can.
  ///
  /// The server refuses to delete anything that appears on an order, because
  /// past orders read their line names and cost through this record. Saying so
  /// before the tap beats a 409 afterwards.
  String? deleteBlockedReason(Map<String, dynamic> product) {
    if (!canDelete) return 'Deleting needs the products.delete permission';
    return null;
  }

  /// The price a customer actually pays, matching what the till freezes onto
  /// a line — so this screen and a receipt agree.
  double sellingPrice(Map<String, dynamic> product) {
    final discount = adminDouble(product['discountPrice']);
    if (discount > 0) return discount;
    return adminDouble(product['price']);
  }

  bool hasCost(Map<String, dynamic> product) => adminDouble(product['costPrice']) > 0;

  /// Products in view with no cost price recorded. These are exactly what
  /// holds the profit report's cost coverage down, so the screen can say so.
  int get missingCostCount => items.where((p) => !hasCost(p)).length;
}
