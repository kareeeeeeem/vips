import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

/// The customer's own orders.
///
/// The app had the endpoints in its constants file but no screen that listed
/// them, so a customer could place an order and then never see it again.
class OrdersController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.get('/order/my-orders');
      if (response.success) {
        final data = response.data;
        // This endpoint has returned both a bare list and an {items} envelope
        // across versions; accepting either keeps the screen from blanking on
        // a shape it did not expect.
        final raw = data is List ? data : (data is Map ? data['items'] : null);
        if (raw is List) {
          orders.value = raw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load your orders.';
      }
    } catch (e) {
      debugPrint('[ORDERS] load failed: $e');
      errorMessage.value = 'Could not load your orders. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
