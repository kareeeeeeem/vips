import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

class AllMerchantsView extends StatelessWidget {
  const AllMerchantsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: Text('trending_merchants'.tr),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: Obx(
        () {
          if (controller.trendingMerchants.isEmpty) {
            return Center(
              child: Text(
                'no_merchants_found'.tr,
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.trendingMerchants.length,
            itemBuilder: (context, index) {
              final merchant = controller.trendingMerchants[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16.h),
                child: ListTile(
                  leading: merchant['logo'] != null
                      ? Image.network(
                          merchant['logo'].toString(),
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.store),
                  title: Text(merchant['storeName']?.toString() ?? ''),
                  subtitle: Text(merchant['storeCategory']?.toString() ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Get.toNamed(
                    '/merchant-details',
                    arguments: merchant,
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
