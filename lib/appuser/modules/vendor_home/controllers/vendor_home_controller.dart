import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vip/core/services/api_service.dart';

class VendorHomeController extends GetxController {
  // Observable states
  final _isNotificationPermissionGranted = true.obs;
  final _isBatteryOptimizationGranted = true.obs;
  final _isStoreActive = true.obs;
  final _isLoading = false.obs;
  final _campaignOnly = false.obs;
  final _selectedOrderIndex = 0.obs;
  final _selectedOfferTab = 0.obs; // 0: All, 1: Discount, 2: Voucher

  final _todayEarning = 0.0.obs;
  final _weekEarning = 0.0.obs;
  final _monthEarning = 0.0.obs;
  final _cashInHand = 0.0.obs;
  final _hasNotification = true.obs;

  // Store info
  final _storeName = ''.obs;
  final _storeCategory = ''.obs;
  final _currentPackage = ''.obs;
  final _uploadLimit = ''.obs;
  final _packageExpiry = ''.obs;
  final _storePhone = ''.obs;
  final _storeAddress = ''.obs;
  final _storeWebsite = ''.obs;
  final _storeEmail = ''.obs;

  // Recent orders from API
  final _recentOrders = <Map<String, dynamic>>[].obs;
  // Remplacer offerTabs par orderTabs
  final orderTabs = ['Last Running Order', 'Recent Running Order'];
  int selectedOrderTab = 0;

  void setOrderTab(int index) {
    selectedOrderTab = index;
    update();
  }

  int getRecentOrdersCount() {
    return _recentOrders.length;
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    if (selectedOrderTab == 0) {
      return getLastRunningOrders();
    } else {
      return getRecentRunningOrders();
    }
  }

  List<Map<String, dynamic>> getLastRunningOrders() {
    return _recentOrders
        .where(
          (o) => o['status'] != 'delivered' && o['status'] != 'cancelled',
        )
        .toList();
  }

  List<Map<String, dynamic>> getRecentRunningOrders() {
    return _recentOrders.toList();
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
  String get storePhone => _storePhone.value;
  String get storeAddress => _storeAddress.value;
  String get storeWebsite => _storeWebsite.value;
  String get storeEmail => _storeEmail.value;

  // Static order data
  final List<String> orderStatuses = [
    'Pending',
    'Confirmed',
    'Processing',
    'Ready',
    'Delivered',
  ];

  final List<String> offerTabs = ['All', 'Discount', 'Voucher'];

  final List<Map<String, dynamic>> orders = [];

  final List<Map<String, dynamic>> offers = [];

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
    try {
      final api = ApiService();
      final results = await Future.wait([
        api.get('/merchant/stats'),
        api.get('/merchant/profile'),
        api.get('/merchant/orders', queryParams: {'status': 'all', 'limit': 10}),
      ]);

      // Stats
      final statsRes = results[0];
      if (statsRes.success && statsRes.data != null) {
        final d = statsRes.data as Map<String, dynamic>;
        _todayEarning.value =
            ((d['today'] as Map?)?['sales'] as num?)?.toDouble() ?? 0.0;
        _monthEarning.value =
            ((d['month'] as Map?)?['sales'] as num?)?.toDouble() ?? 0.0;
        _weekEarning.value =
            ((d['week'] as Map?)?['sales'] as num?)?.toDouble() ?? (_monthEarning.value / 4);
      }

      // Profile
      final profileRes = results[1];
      if (profileRes.success && profileRes.data != null) {
        final p = profileRes.data as Map<String, dynamic>;
        _storeName.value = p['storeName'] ?? p['fullName'] ?? '';
        _storeCategory.value = p['storeCategory'] ?? '';
        _currentPackage.value = p['packageName'] ?? '';
        _storePhone.value = p['phone'] ?? '';
        _storeAddress.value = p['address'] ?? '';
        _storeWebsite.value = p['website'] ?? '';
        _storeEmail.value = p['email'] ?? '';
      }

      // Recent orders
      final ordersRes = results[2];
      if (ordersRes.success && ordersRes.data != null) {
        final d = ordersRes.data as Map<String, dynamic>;
        final orders = (d['orders'] as List?) ?? [];
        _recentOrders.assignAll(
          orders.map((o) => Map<String, dynamic>.from(o as Map)).toList(),
        );
      }
    } catch (_) {}
    _isLoading.value = false;
  }

  Future<void> _checkSystemNotification() async {
    if (await Permission.notification.status.isDenied ||
        await Permission.notification.status.isPermanentlyDenied) {
      debugPrint('Notification is disabled');
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
