import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/appuser/modules/profile/views/profile_view.dart';

class MerchantHomeController extends GetxController {
  // --- Dashboard Statistics (Dummy data for now, will connect to API) ---
  final RxDouble totalSales = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble totalPurchases = 0.0.obs;
  final RxDouble totalSaleDue = 0.0.obs;
  final RxDouble totalDueCollect = 0.0.obs;
  
  // VIPs Stats
  final RxDouble vipsIn = 0.0.obs;
  final RxDouble vipsOut = 0.0.obs;
  final RxDouble vipsRecovery = 0.0.obs;
  
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
      case 2: // Center Scan button
        Get.toNamed(MerchantRoutes.QR_RECEIVE);
        break;
      case 3:
        Get.toNamed(MerchantRoutes.WALLET);
        break;
      case 4:
        Get.to(() => const ProfileView());
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadDashboardStats();
  }

  void _loadDashboardStats() async {
    isLoading.value = true;
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Accounting Stats
    totalSales.value = 1500.0;
    totalExpenses.value = 450.0;
    totalPurchases.value = 800.0;
    totalSaleDue.value = 200.0;
    totalDueCollect.value = 350.0;
    
    // VIPs Stats
    vipsIn.value = 215.20;
    vipsOut.value = 215.20;
    vipsRecovery.value = 215.20;
    
    isLoading.value = false;
  }
  
  // Refresh stats (e.g. pull to refresh)
  Future<void> refreshStats() async {
    _loadDashboardStats();
  }
}
