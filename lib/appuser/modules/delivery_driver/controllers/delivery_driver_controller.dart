import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class DeliveryDriverController extends GetxController {
  final _api = ApiService();

  final RxBool isLoading = false.obs;

  // Driver info
  final RxString driverName = ''.obs;
  final RxString driverPhone = ''.obs;
  final RxString driverPhoto = ''.obs;

  // Earnings
  final RxDouble todayEarning = 0.0.obs;
  final RxDouble weekEarning = 0.0.obs;
  final RxDouble cashInHand = 0.0.obs;

  final RxBool isOnline = true.obs;

  // Current order
  final RxBool hasActiveOrder = false.obs;
  final Rx<Map<String, dynamic>?> currentOrder = Rx<Map<String, dynamic>?>(
    null,
  );

  // Orders from API
  final _allOrders = <Map<String, dynamic>>[].obs;

  // Orders tabs
  final orderTabs = ['Request', 'Active History', 'History'];
  final RxInt selectedOrderTab = 0.obs;

  // Expanded order index
  final Rx<int?> expandedOrderIndex = Rx<int?>(null);

  // Notification permission
  final RxBool isNotificationPermissionGranted = true.obs;
  final RxBool isBatteryOptimizationGranted = true.obs;
  final RxBool hasNotification = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _api.get('/merchant/profile'),
        _api.get('/merchant/stats'),
        _api.get('/merchant/orders', queryParams: {'status': 'all', 'limit': 20}),
      ]);

      // Profile → driver identity
      final profileRes = results[0];
      if (profileRes.success && profileRes.data != null) {
        final p = profileRes.data as Map<String, dynamic>;
        driverName.value = p['storeName'] ?? p['fullName'] ?? '';
        driverPhone.value = p['phone'] ?? '';
        driverPhoto.value = p['profileImageUrl'] ?? '';
      }

      // Stats → earnings
      final statsRes = results[1];
      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data as Map<String, dynamic>;
        todayEarning.value =
            ((d['today'] as Map?)?['sales'] as num?)?.toDouble() ?? 0.0;
        weekEarning.value =
            ((d['month'] as Map?)?['sales'] as num?)?.toDouble() ?? 0.0;
      }

      // Orders
      final ordersRes = results[2];
      if (ordersRes.success && ordersRes.data != null) {
        final d = ordersRes.data as Map<String, dynamic>;
        final orders = (d['orders'] as List?) ?? [];
        _allOrders.assignAll(
          orders.map((o) => Map<String, dynamic>.from(o as Map)).toList(),
        );
        final active = _allOrders.firstWhereOrNull(
          (o) =>
              o['status'] == 'processing' ||
              o['status'] == 'confirmed' ||
              o['status'] == 'pending',
        );
        if (active != null) {
          hasActiveOrder.value = true;
          currentOrder.value = active;
        }
      }
    } catch (_) {}
    isLoading.value = false;
  }

  void setOrderTab(int index) {
    selectedOrderTab.value = index;
    expandedOrderIndex.value = null;
  }

  void toggleOrderCard(int index) {
    if (expandedOrderIndex.value == index) {
      expandedOrderIndex.value = null;
    } else {
      expandedOrderIndex.value = index;
    }
  }

  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;
    if (!isOnline.value) {
      safeSnackbar(
        'Status Changed',
        'You are now offline',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } else {
      safeSnackbar(
        'Status Changed',
        'You are now online',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    }
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    switch (selectedOrderTab.value) {
      case 0:
        return getRequestOrders();
      case 1:
        return getActiveHistoryOrders();
      case 2:
        return getHistoryOrders();
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> getRequestOrders() {
    return _allOrders
        .where((o) => o['status'] == 'pending')
        .toList();
  }

  List<Map<String, dynamic>> getActiveHistoryOrders() {
    return _allOrders
        .where(
          (o) => o['status'] == 'confirmed' || o['status'] == 'processing',
        )
        .toList();
  }

  List<Map<String, dynamic>> getHistoryOrders() {
    return _allOrders
        .where(
          (o) => o['status'] == 'delivered' || o['status'] == 'cancelled',
        )
        .toList();
  }

  void acceptOrder(Map<String, dynamic> order) {
    Get.defaultDialog(
      title: 'Accept Order',
      middleText: 'Do you want to accept this order?',
      textConfirm: 'Accept',
      textCancel: 'Decline',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () async {
        Get.back();
        final orderId = order['id'] ?? order['_id'] ?? order['orderId'];
        try {
          await _api.put('/merchant/orders/$orderId/status', {'status': 'confirmed'});
        } catch (_) {}
        final idx = _allOrders.indexWhere((o) =>
            (o['id'] ?? o['_id'] ?? o['orderId']) == orderId);
        if (idx != -1) {
          _allOrders[idx] = {..._allOrders[idx], 'status': 'confirmed'};
          _allOrders.refresh();
        }
        hasActiveOrder.value = true;
        currentOrder.value = {...order, 'status': 'confirmed'};
        safeSnackbar(
          'Order Accepted',
          'You have accepted order ${order['orderNumber'] ?? order['orderId']}',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      },
    );
  }

  void declineOrder(Map<String, dynamic> order) {
    Get.defaultDialog(
      title: 'Decline Order',
      middleText: 'Are you sure you want to decline this order?',
      textConfirm: 'Decline',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade400,
      onConfirm: () async {
        Get.back();
        final orderId = order['id'] ?? order['_id'] ?? order['orderId'];
        try {
          await _api.put('/merchant/orders/$orderId/status', {'status': 'rejected'});
        } catch (_) {}
        final idx = _allOrders.indexWhere((o) =>
            (o['id'] ?? o['_id'] ?? o['orderId']) == orderId);
        if (idx != -1) {
          _allOrders.removeAt(idx);
          _allOrders.refresh();
        }
        safeSnackbar(
          'Order Declined',
          'You have declined order ${order['orderNumber'] ?? order['orderId']}',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
      },
    );
  }

  void viewOrderDetails(Map<String, dynamic> order) {
    Get.toNamed('/delivery-order-details', arguments: order);
  }

  void startNavigation() {
    final order = currentOrder.value;
    final address = order?['deliveryAddress'] ?? order?['address'] ?? '';
    if (address.isNotEmpty) {
      final encoded = Uri.encodeComponent(address.toString());
      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      safeSnackbar('No Address', 'Delivery address not available');
    }
  }

  void callCustomer() {
    final order = currentOrder.value;
    final phone = order?['customerPhone'] ?? order?['customer']?['phone'] ?? '';
    if (phone.toString().isNotEmpty) {
      launchUrl(Uri.parse('tel:$phone'));
    } else {
      safeSnackbar('No Phone', 'Customer phone not available');
    }
  }

  void callStore() {
    final order = currentOrder.value;
    final phone = order?['storePhone'] ?? order?['merchant']?['phone'] ?? order?['merchantPhone'] ?? '';
    if (phone.toString().isNotEmpty) {
      launchUrl(Uri.parse('tel:$phone'));
    } else {
      safeSnackbar('No Phone', 'Store phone not available');
    }
  }

  void completeDelivery() {
    Get.defaultDialog(
      title: 'Complete Delivery',
      middleText: 'Have you delivered the order?',
      textConfirm: 'Yes, Complete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () async {
        Get.back();
        final order = currentOrder.value;
        if (order != null) {
          final orderId = order['id'] ?? order['_id'] ?? order['orderId'];
          try {
            await _api.put('/merchant/orders/$orderId/status', {'status': 'delivered'});
          } catch (_) {}
          final idx = _allOrders.indexWhere((o) =>
              (o['id'] ?? o['_id'] ?? o['orderId']) == orderId);
          if (idx != -1) {
            _allOrders[idx] = {..._allOrders[idx], 'status': 'delivered'};
            _allOrders.refresh();
          }
        }
        hasActiveOrder.value = false;
        currentOrder.value = null;
        safeSnackbar(
          'Delivery Completed',
          'Order has been marked as delivered',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      },
    );
  }

  void requestNotificationPermission() async {
    // Implement notification permission request
    safeSnackbar('Permission', 'Requesting notification permission...');
  }

  void requestBatteryOptimization() async {
    // Implement battery optimization request
    safeSnackbar('Permission', 'Requesting battery optimization...');
  }

  void closeNotificationPermissionWarning() {
    isNotificationPermissionGranted.value = true;
  }

  void closeBatteryOptimizationWarning() {
    isBatteryOptimizationGranted.value = true;
  }
}
