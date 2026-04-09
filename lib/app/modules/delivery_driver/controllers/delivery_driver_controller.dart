import 'package:get/get.dart';

class DeliveryDriverController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;

  // Driver info
  final RxString driverName = 'John Doe'.obs;
  final RxString driverPhone = '+1 234 567 8900'.obs;
  final RxString driverPhoto = 'https://i.pravatar.cc/150?img=33'.obs;

  // Earnings
  final RxDouble todayEarning = 1250.50.obs;
  final RxDouble weekEarning = 8750.25.obs;
  final RxDouble cashInHand = 450.00.obs;

  // Online status
  final RxBool isOnline = true.obs;

  // Current order
  final RxBool hasActiveOrder = true.obs;
  final Rx<Map<String, dynamic>?> currentOrder = Rx<Map<String, dynamic>?>(
    null,
  );

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
    loadCurrentOrder();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 1));
      // Load data from API
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }

  void loadCurrentOrder() {
    if (hasActiveOrder.value) {
      currentOrder.value = {
        'orderId': 'SP 0023900',
        'storeName': 'Pizza Hut',
        'storeAddress': 'Rd 12, Uttara, Dhaka',
        'customerName': 'John Smith',
        'customerAddress': '123 Main Street, Apt 4B',
        'itemsCount': 3,
        'deliveryTime': 30,
        'timeLess': 16,
        'totalAmount': 127.00,
        'deliveryFee': 5.00,
        'status': 'picking_up', // picking_up, delivering, delivered
        'paymentMethod': 'COD',
        'distance': '2.5 km',
        'orderTime': '06 Sept, 10:00pm',
        'items': [
          {'name': 'Pepperoni Pizza', 'quantity': 2, 'price': 45.00},
          {'name': 'Garlic Bread', 'quantity': 1, 'price': 12.00},
        ],
      };
    }
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
      Get.snackbar(
        'Status Changed',
        'You are now offline',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } else {
      Get.snackbar(
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
    return [
      {
        'orderId': 'SP 0023901',
        'storeName': 'KFC Restaurant',
        'storeAddress': 'Gulshan 2, Dhaka',
        'customerName': 'Sarah Johnson',
        'customerAddress': '456 Park Avenue',
        'itemsCount': 4,
        'deliveryFee': 6.00,
        'totalAmount': 89.50,
        'distance': '3.2 km',
        'status': 'pending',
        'paymentMethod': 'COD',
      },
      {
        'orderId': 'SP 0023902',
        'storeName': 'Burger King',
        'storeAddress': 'Banani, Dhaka',
        'customerName': 'Mike Brown',
        'customerAddress': '789 Oak Street',
        'itemsCount': 2,
        'deliveryFee': 4.00,
        'totalAmount': 56.00,
        'distance': '1.8 km',
        'status': 'pending',
        'paymentMethod': 'Paid',
      },
    ];
  }

  List<Map<String, dynamic>> getActiveHistoryOrders() {
    return [
      {
        'orderId': 'SP 0023900',
        'storeName': 'Pizza Hut',
        'storeAddress': 'Rd 12, Uttara, Dhaka',
        'customerName': 'John Smith',
        'customerAddress': '123 Main Street',
        'itemsCount': 3,
        'deliveryFee': 5.00,
        'totalAmount': 127.00,
        'distance': '2.5 km',
        'status': 'delivering',
        'paymentMethod': 'COD',
      },
    ];
  }

  List<Map<String, dynamic>> getHistoryOrders() {
    return [
      {
        'orderId': 'SP 0023899',
        'storeName': 'Subway',
        'storeAddress': 'Dhanmondi, Dhaka',
        'customerName': 'Emily Davis',
        'customerAddress': '321 Elm Street',
        'itemsCount': 2,
        'deliveryFee': 4.50,
        'totalAmount': 45.00,
        'distance': '2.1 km',
        'status': 'delivered',
        'paymentMethod': 'Paid',
        'completedAt': '05 Sept, 8:30pm',
      },
      {
        'orderId': 'SP 0023898',
        'storeName': "McDonald's",
        'storeAddress': 'Mirpur, Dhaka',
        'customerName': 'David Wilson',
        'customerAddress': '654 Pine Street',
        'itemsCount': 5,
        'deliveryFee': 7.00,
        'totalAmount': 156.00,
        'distance': '4.5 km',
        'status': 'delivered',
        'paymentMethod': 'COD',
        'completedAt': '05 Sept, 7:15pm',
      },
    ];
  }

  void acceptOrder(Map<String, dynamic> order) {
    Get.defaultDialog(
      title: 'Accept Order',
      middleText: 'Do you want to accept this order?',
      textConfirm: 'Accept',
      textCancel: 'Decline',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        hasActiveOrder.value = true;
        currentOrder.value = order;
        Get.snackbar(
          'Order Accepted',
          'You have accepted order ${order['orderId']}',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      },
    );
  }

  void viewOrderDetails(Map<String, dynamic> order) {
    Get.toNamed('/delivery-order-details', arguments: order);
  }

  void startNavigation() {
    Get.snackbar(
      'Navigation',
      'Starting navigation to destination',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void callCustomer() {
    Get.snackbar(
      'Calling',
      'Calling customer...',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void callStore() {
    Get.snackbar(
      'Calling',
      'Calling store...',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  void completeDelivery() {
    Get.defaultDialog(
      title: 'Complete Delivery',
      middleText: 'Have you delivered the order?',
      textConfirm: 'Yes, Complete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () {
        Get.back();
        hasActiveOrder.value = false;
        currentOrder.value = null;
        Get.snackbar(
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
    Get.snackbar('Permission', 'Requesting notification permission...');
  }

  void requestBatteryOptimization() async {
    // Implement battery optimization request
    Get.snackbar('Permission', 'Requesting battery optimization...');
  }

  void closeNotificationPermissionWarning() {
    isNotificationPermissionGranted.value = true;
  }

  void closeBatteryOptimizationWarning() {
    isBatteryOptimizationGranted.value = true;
  }
}
