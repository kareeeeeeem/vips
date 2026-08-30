import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/admin_api_service.dart';

/// Low-stock alerts across both collections that can run out.
///
/// `Stock` lines are the merchant's own store-room counts; `Product` rows are
/// the customer-facing catalogue with their own `alertQty`. A screen that read
/// only one of the two would miss half the stockouts, so this keeps them
/// separate but shows them together.
class LowStockController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Map<String, dynamic>> stockAlerts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> productAlerts = <Map<String, dynamic>>[].obs;

  /// '' | 'stock' | 'products'
  final RxString sourceFilter = ''.obs;

  int get total => stockAlerts.length + productAlerts.length;

  /// Items already at zero — the ones actually blocking a sale right now.
  int get outOfStockCount =>
      stockAlerts.where((a) => adminInt(a['currentStock']) == 0).length +
      productAlerts.where((a) => adminInt(a['stock']) == 0).length;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.inventoryAlerts(limit: 100);
      if (response.success && response.data is Map) {
        stockAlerts.value = adminItems(response.data, 'stock');
        productAlerts.value = adminItems(response.data, 'products');
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load low-stock alerts.';
      }
    } catch (e) {
      debugPrint('[ADMIN LOW STOCK] load failed: $e');
      errorMessage.value = 'Could not load low-stock alerts. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void setSourceFilter(String value) => sourceFilter.value = value;

  bool get showStock => sourceFilter.value.isEmpty || sourceFilter.value == 'stock';
  bool get showProducts => sourceFilter.value.isEmpty || sourceFilter.value == 'products';
}
