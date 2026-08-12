import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

class HotDealsView extends StatelessWidget {
  const HotDealsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: Text('hot_deals'.tr),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: GetBuilder<HomeController>(
        builder: (ctrl) {
          if (ctrl.hotDeals.isEmpty) {
            return Center(
              child: Text(
                'no_hot_deals_found'.tr,
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: ctrl.hotDeals.length,
            itemBuilder: (context, index) {
              final deal = ctrl.hotDeals[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16.h),
                child: ListTile(
                  title: Text(deal['title']?.toString() ?? ''),
                  subtitle: Text(deal['description']?.toString() ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.toNamed(
                    '/deal-details',
                    arguments: deal,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
