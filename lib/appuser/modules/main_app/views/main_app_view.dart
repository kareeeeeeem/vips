import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/bills/views/bills_view.dart';
import 'package:vip/appuser/modules/home/views/home_view.dart';

import '../../home/views/widgets/navbar.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_app_controller.dart';

class MainAppView extends GetView<MainAppController> {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      bottomNavigationBar: Obx(
        () => CustomBottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (int index) {
            controller.changePage(index);
          },
          onScanTap: () {
            controller.onScanTap();
          },
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: _getPagesForRole(profileController.selectedRole.value),
        ),
      ),
    );
  }

  // AppUser is the Customer-only flavor of this app (Vendor/merchant
  // features live in the separate AppMerchant flavor) — always the real
  // Customer page set.
  List<Widget> _getPagesForRole(String role) {
    return [
      HomeView(fromOffer: false),
      HomeView(fromOffer: true),
      BillsView(),
      ProfileView(),
    ];
  }
}
