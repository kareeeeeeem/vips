import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class VendorHomeController extends GetxController {
  // Observable states
  final _isNotificationPermissionGranted = true.obs;
  final _isBatteryOptimizationGranted = true.obs;
  final _isStoreActive = true.obs;
  final _isLoading = false.obs;
  final _campaignOnly = false.obs;
  final _selectedOrderIndex = 0.obs;
  final _selectedOfferTab = 0.obs; // 0: All, 1: Discount, 2: Voucher

  // Static data
  final _todayEarning = 1250.50.obs;
  final _weekEarning = 8750.25.obs;
  final _monthEarning = 35420.80.obs;
  final _cashInHand = 5.00.obs;
  final _hasNotification = true.obs;

  // Store info
  final _storeName = 'Pizza Hub'.obs;
  final _storeCategory = 'Restaurant'.obs;
  final _currentPackage = 'Platinum'.obs;
  final _uploadLimit = '5000 time(s)'.obs;
  final _packageExpiry = '2030-03-01'.obs;
  // Remplacer offerTabs par orderTabs
  final orderTabs = ['Last Running Order', 'Recent Running Order'];
  int selectedOrderTab = 0;

  void setOrderTab(int index) {
    selectedOrderTab = index;
    update();
  }

  int getRecentOrdersCount() {
    return 3; // Nombre de commandes récentes
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    if (selectedOrderTab == 0) {
      return getLastRunningOrders();
    } else {
      return getRecentRunningOrders();
    }
  }

  List<Map<String, dynamic>> getLastRunningOrders() {
    return [
      {
        'orderId': 'SP 0023900',
        'itemsCount': 3,
        'status': 'Unpaid',
        'paymentMethod': 'COD',
        'brandName': 'Brand Name',
        'address': '222222222222222222222...',
        'deliveryTime': 30,
        'timeLess': 16,
        'restaurantName': 'Uttora Coffee House',
        'orderedAt': '06 Sept, 10:00pm',
        'images': [
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
          'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
        ],
      },
    ];
  }

  List<Map<String, dynamic>> getRecentRunningOrders() {
    return [
      // Vos commandes récentes ici
    ];
  }

  // AppLifecycleListener
  late final AppLifecycleListener _listener;

  // Getters
  bool get isNotificationPermissionGranted =>
      _isNotificationPermissionGranted.value;
  bool get isBatteryOptimizationGranted => _isBatteryOptimizationGranted.value;
  bool get isStoreActive => _isStoreActive.value;
  bool get isLoading => _isLoading.value;
  bool get campaignOnly => _campaignOnly.value;
  int get selectedOrderIndex => _selectedOrderIndex.value;
  int get selectedOfferTab => _selectedOfferTab.value;
  double get todayEarning => _todayEarning.value;
  double get weekEarning => _weekEarning.value;
  double get monthEarning => _monthEarning.value;
  double get cashInHand => _cashInHand.value;
  bool get hasNotification => _hasNotification.value;
  String get storeName => _storeName.value;
  String get storeCategory => _storeCategory.value;
  String get currentPackage => _currentPackage.value;
  String get uploadLimit => _uploadLimit.value;
  String get packageExpiry => _packageExpiry.value;

  // Static order data
  final List<String> orderStatuses = [
    'Pending',
    'Confirmed',
    'Processing',
    'Ready',
    'Delivered',
  ];

  final List<String> offerTabs = ['All', 'Discount', 'Voucher'];

  final List<Map<String, dynamic>> orders = [
    {
      'id': '#12345',
      'customerName': 'John Doe',
      'items': 3,
      'amount': 45.50,
      'status': 'Pending',
      'time': '10:30 AM',
    },
    {
      'id': '#12346',
      'customerName': 'Jane Smith',
      'items': 2,
      'amount': 32.00,
      'status': 'Pending',
      'time': '10:45 AM',
    },
    {
      'id': '#12347',
      'customerName': 'Bob Johnson',
      'items': 5,
      'amount': 67.25,
      'status': 'Pending',
      'time': '11:00 AM',
    },
  ];

  // Offers/Products data
  final List<Map<String, dynamic>> offers = [
    {
      'id': '1',
      'name': 'Mcdonald\'s happy meal',
      'rating': 4.5,
      'type': 'Free',
      'distance': '20 m',
      'discount': '+3.00 off',
      'image': '', // Add your image URL
      'category': 'discount',
    },
    {
      'id': '2',
      'name': 'Big Mac Combo',
      'rating': 4.8,
      'type': 'Premium',
      'distance': '15 m',
      'discount': '+5.00 off',
      'image': '',
      'category': 'voucher',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeScreen();
  }

  void _initializeScreen() {
    _checkSystemNotification();
    _listener = AppLifecycleListener(onStateChange: _onStateChanged);
    loadData();
    Future.delayed(const Duration(milliseconds: 200), () {
      checkPermission();
    });
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    _todayEarning.value = 1250.50;
    _weekEarning.value = 8750.25;
    _monthEarning.value = 35420.80;
    _cashInHand.value = 5.00;
    _hasNotification.value = true;
    _isLoading.value = false;
  }

  Future<void> _checkSystemNotification() async {
    if (await Permission.notification.status.isDenied ||
        await Permission.notification.status.isPermanentlyDenied) {
      print('Notification is disabled');
    }
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 200), () {
          checkPermission();
        });
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;
    }
  }

  Future<void> checkPermission() async {
    var notificationStatus = await Permission.notification.status;
    var batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      _isNotificationPermissionGranted.value = false;
      _isBatteryOptimizationGranted.value = true;
    } else if (batteryStatus.isDenied) {
      _isBatteryOptimizationGranted.value = false;
      _isNotificationPermissionGranted.value = true;
    } else {
      _isNotificationPermissionGranted.value = true;
      _isBatteryOptimizationGranted.value = true;
    }
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      _isNotificationPermissionGranted.value = true;
    } else {
      await openAppSettings();
    }
    checkPermission();
  }

  Future<void> requestBatteryOptimization() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      _isBatteryOptimizationGranted.value = true;
      return;
    } else if (status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    } else {
      openAppSettings();
    }
    checkPermission();
  }

  void closeNotificationPermissionWarning() {
    _isNotificationPermissionGranted.value = true;
  }

  void closeBatteryOptimizationWarning() {
    _isBatteryOptimizationGranted.value = true;
  }

  void toggleStoreStatus() {
    _isStoreActive.value = !_isStoreActive.value;
  }

  void toggleCampaignOnly() {
    _campaignOnly.value = !_campaignOnly.value;
  }

  void setOrderIndex(int index) {
    _selectedOrderIndex.value = index;
  }

  void setOfferTab(int index) {
    _selectedOfferTab.value = index;
  }

  // Dans VendorHomeController
  final Rx<int?> expandedOrderIndex = Rx<int?>(null);

  void toggleOrderCard(int index) {
    if (expandedOrderIndex.value == index) {
      expandedOrderIndex.value = null; // Fermer
    } else {
      expandedOrderIndex.value = index; // Ouvrir
    }
  }

  List<Map<String, dynamic>> getFilteredOffers() {
    if (_selectedOfferTab.value == 0) {
      return offers;
    } else if (_selectedOfferTab.value == 1) {
      return offers.where((offer) => offer['category'] == 'discount').toList();
    } else {
      return offers.where((offer) => offer['category'] == 'voucher').toList();
    }
  }

  @override
  void onClose() {
    _listener.dispose();
    super.onClose();
  }
}
