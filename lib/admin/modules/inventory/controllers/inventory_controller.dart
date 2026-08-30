import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';

/// Platform-wide inventory.
///
/// Adapted from the merchant app's `MerchantStockController`, which reads
/// `/merchant/stock` for one store. This reads `/admin/inventory` across
/// every merchant, so each row carries the store it belongs to and the
/// totals are platform totals rather than one merchant's.
class AdminInventoryController extends AdminListController {
  final RxBool lowStockOnly = false.obs;
  final RxString merchantFilter = ''.obs;
  final RxString locationFilter = ''.obs;

  /// The warehouses that actually hold stock, derived from live data.
  final RxList<Map<String, dynamic>> locations = <Map<String, dynamic>>[].obs;

  final RxDouble totalValue = 0.0.obs;
  final RxInt totalUnits = 0.obs;

  /// Low-stock alerts span two collections (Stock lines and Products with
  /// their own alertQty), so they are fetched separately from the list.
  final RxList<Map<String, dynamic>> stockAlerts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> productAlerts = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAlerts = false.obs;

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['lowStock'] == true) lowStockOnly.value = true;
      if (args['merchantId'] is String) merchantFilter.value = args['merchantId'] as String;
    }
    super.onInit();
    loadAlerts();
    loadLocations();
  }

  Future<void> loadLocations() async {
    try {
      final response = await api.inventoryLocations();
      if (response.success && response.data is Map) {
        locations.value = adminItems(response.data);
      }
    } catch (e) {
      debugPrint('[ADMIN INVENTORY] loadLocations failed: $e');
    }
  }

  @override
  Future<ApiResponse> fetch() => api.inventory(
        page: page.value,
        limit: 20,
        search: search.value,
        merchantId: merchantFilter.value,
        location: locationFilter.value,
        lowStockOnly: lowStockOnly.value,
      );

  @override
  void parse(Map<String, dynamic> data) {
    totalValue.value = adminDouble(data['totalValue']);
    totalUnits.value = adminInt(data['totalUnits']);
  }

  Future<void> loadAlerts() async {
    isLoadingAlerts.value = true;
    try {
      final response = await api.inventoryAlerts();
      if (response.success && response.data is Map) {
        stockAlerts.value = adminItems(response.data, 'stock');
        productAlerts.value = adminItems(response.data, 'products');
      }
    } catch (e) {
      debugPrint('[ADMIN INVENTORY] loadAlerts failed: $e');
    } finally {
      isLoadingAlerts.value = false;
    }
  }

  void toggleLowStockOnly() {
    lowStockOnly.toggle();
    load(resetPage: true);
  }

  void clearMerchantFilter() {
    merchantFilter.value = '';
    load(resetPage: true);
  }

  void setLocationFilter(String value) {
    if (locationFilter.value == value) return;
    locationFilter.value = value;
    load(resetPage: true);
  }

  int get alertCount => stockAlerts.length + productAlerts.length;

  /// Saves an edited stock line, then refreshes both the list and the alert
  /// counts — a restock should clear its own alert, not leave a stale badge.
  Future<bool> updateItem(String id, Map<String, dynamic> body) async {
    final ok = await mutate(
      () => api.updateInventoryItem(id, body),
      successTitle: 'Stock updated',
    );
    if (ok) {
      await loadAlerts();
      await loadLocations();
    }
    return ok;
  }

  /// Convenience for the +/− buttons on a row.
  Future<bool> adjustStock(Map<String, dynamic> item, int delta) async {
    final current = adminInt(item['currentStock']);
    final next = current + delta;
    if (next < 0) {
      // The merchant app hit exactly this: an unbounded minus button drove
      // stock negative and made the inventory value negative with it.
      adminToast(
        'Already at zero',
        '${adminString(item['name'], 'This item')} cannot go below 0.',
        isError: true,
      );
      return false;
    }
    return updateItem(adminString(item['_id']), {'currentStock': next});
  }
}
