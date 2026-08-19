import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';

class MerchantHomeController extends GetxController {
  // --- Dashboard Statistics ---
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxDouble totalSaleDue = 0.0.obs;
  final RxDouble totalDueCollect = 0.0.obs;

  // VIPs Stats
  final RxDouble vipsIn = 0.0.obs;
  final RxDouble vipsOut = 0.0.obs;
  final RxDouble vipsRecovery = 0.0.obs;

  // --- Merchant Profile ---
  final RxString storeName = ''.obs;
  final RxString storePhone = ''.obs;
  final RxString storeImageUrl = ''.obs;
  final RxString merchantId = ''.obs;

  final RxBool isLoading = true.obs;
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        Get.toNamed(MerchantRoutes.STORE_PROFILE);
        break;
      case 1:
        Get.toNamed(MerchantRoutes.FINANCE_DASHBOARD);
        break;
      case 2:
        Get.toNamed(MerchantRoutes.QR_RECEIVE);
        break;
      case 3:
        Get.toNamed(MerchantRoutes.WALLET);
        break;
      case 4:
        Get.toNamed(MerchantRoutes.BUSINESS_PLAN);
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    try {
      await Future.wait([_loadDashboardStats(), _loadMerchantProfile()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await ApiService().get('/merchant/dashboard');
      if (response.success && response.data != null) {
        final data = response.data;
        totalSales.value = (data['totalSales'] ?? 0).toDouble();
        totalExpenses.value = (data['totalExpenses'] ?? 0).toDouble();
        totalPurchases.value = (data['totalPurchases'] ?? 0).toDouble();
        totalSaleDue.value = (data['totalSaleDue'] ?? data['totalDue'] ?? 0).toDouble();
        totalDueCollect.value = (data['totalDueCollect'] ?? data['totalCollected'] ?? 0).toDouble();
        vipsIn.value = (data['totalRewards'] ?? 0).toDouble();
        vipsOut.value = (data['totalGiftBack'] ?? 0).toDouble();
        vipsRecovery.value = (data['netProfit'] ?? 0).toDouble();
      }
    } catch (_) {}
  }

  Future<void> _loadMerchantProfile() async {
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        final data = response.data;
        storeName.value = data['storeName'] ?? data['fullName'] ?? '';
        storePhone.value = data['phone'] ?? '';
        storeImageUrl.value = data['logo'] ?? data['profileImage'] ?? '';
        merchantId.value = data['_id']?.toString() ?? '';
      }
    } catch (_) {}
  }

  Future<void> refreshStats() async {
    await _loadAll();
  }
}

