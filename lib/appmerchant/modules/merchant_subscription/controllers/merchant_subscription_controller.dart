import 'package:get/get.dart';

class MerchantSubscriptionController extends GetxController {
  final currentCommission = 0.3.obs;
  
  // Selected package for migration
  final selectedPackageName = 'Basic'.obs;
  final selectedPackagePrice = 99.00.obs;
  final selectedPackageDuration = 120.obs;
  
  // Payment methods
  final paymentMethod = 'COD'.obs; // 'Wallet', 'Online', 'COD'
  final walletPoints = 28560.obs;
  
  void selectPackage(String name, double price, int duration) {
    selectedPackageName.value = name;
    selectedPackagePrice.value = price;
    selectedPackageDuration.value = duration;
  }
}
