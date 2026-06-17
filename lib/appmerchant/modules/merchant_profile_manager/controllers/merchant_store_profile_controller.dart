import 'package:get/get.dart';

class MerchantStoreProfileController extends GetxController {
  final RxString storeName = "Pizza Hut".obs;
  final RxString category = "Restoran".obs;
  final RxString bannerImage = "assets/images/store_banner.jpg".obs;
  final RxString logoImage = "assets/images/store_logo.png".obs;
  
  final RxInt selectedMainTab = 0.obs; // 0: Edit, 1: Switch, 2: Add New
  final RxInt selectedContentTab = 0.obs; // 0: Coupon, 1: Voucher, 2: Items
  
  void changeMainTab(int index) {
    selectedMainTab.value = index;
  }
  
  void changeContentTab(int index) {
    selectedContentTab.value = index;
  }
  
  void createCoupon() {
    // Navigate to create coupon screen
    print("Create Coupon tapped");
  }
}
