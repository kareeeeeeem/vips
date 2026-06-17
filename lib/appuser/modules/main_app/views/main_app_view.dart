import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/bills/views/bills_view.dart';
import 'package:vip/appuser/modules/home/views/home_view.dart';
import 'package:vip/appuser/modules/vendor_home/views/vendor_home_view.dart';

import '../../home/controllers/home_controller.dart';
import '../../home/views/widgets/navbar.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../vendor_order/views/vendor_order_view.dart';
import '../controllers/main_app_controller.dart';

class MainAppView extends GetView<MainAppController> {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MainAppController());
    Get.put(HomeController());
    final profileController = Get.put(ProfileController());

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

  List<Widget> _getPagesForRole(String role) {
    switch (role) {
      case 'Vendor':
        return [
          VendorHomeView(),
          VendorOrderView(),
          BillsView(),
          ProfileView(),
        ];

      case 'Agent':
        return [
          // AgentHomeView(),  // Si vous avez une vue spécifique pour Agent
          HomeView(fromOffer: false),
          // AgentDeliveriesView(),  // Si vous avez une vue spécifique
          HomeView(fromOffer: true),
          BillsView(),
          ProfileView(),
        ];

      case 'Business':
        return [
          // BusinessHomeView(),  // Si vous avez une vue spécifique pour Business
          HomeView(fromOffer: false),
          HomeView(fromOffer: true),
          BillsView(),
          ProfileView(),
        ];

      case 'Customer':
      default:
        return [
          HomeView(fromOffer: false),
          HomeView(fromOffer: true),
          BillsView(),
          ProfileView(),
        ];
    }
  }
}
