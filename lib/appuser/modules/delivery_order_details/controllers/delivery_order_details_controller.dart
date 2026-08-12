import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class DeliveryOrderDetailsController extends GetxController {
  final order = Rx<Map<String, dynamic>>({});
  final isLoading = false.obs;
  final isCancelling = false.obs;

  String get orderId => Get.arguments?['orderId'] ?? Get.parameters['id'] ?? '';

  @override
  void onInit() {
    super.onInit();
    if (orderId.isNotEmpty) fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/order/$orderId');
      if (response.success && response.data != null) {
        order.value = Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder() async {
    isCancelling.value = true;
    try {
      final response = await ApiService().put('/order/$orderId/cancel', {});
      if (response.success) {
        order.value = Map<String, dynamic>.from({...order.value, 'status': 'cancelled'});
        safeSnackbar('Cancelled', 'Order has been cancelled', snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to cancel order', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCancelling.value = false;
    }
  }

  Future<void> submitReview(int rating, String reviewText) async {
    try {
      final response = await ApiService().post('/order/$orderId/review', {
        'rating': rating,
        'review': reviewText,
      });
      if (response.success) {
        order.value = Map<String, dynamic>.from({
          ...order.value,
          'rating': rating,
          'review': reviewText,
        });
        safeSnackbar('Review Submitted', 'Thank you for your feedback!', snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to submit review', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String get status => order.value['status']?.toString() ?? '';
  String get merchantName {
    final m = order.value['merchantId'];
    if (m is Map) return m['storeName'] ?? m['fullName'] ?? 'Merchant';
    return 'Merchant';
  }

  List<Map<String, dynamic>> get items =>
      List<Map<String, dynamic>>.from(order.value['items'] ?? []);

  double get totalAmount => (order.value['totalAmount'] as num?)?.toDouble() ?? 0.0;
}
