import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

class BuildFilterCategories extends GetView<HomeController> {
  const BuildFilterCategories({super.key});

  @override
  Widget build(BuildContext context) {
    // Liste des catégories
    final categories = [
      {
        'icon': Icons.favorite,
        'label': 'favorites'.tr,
        'onTap': () => controller.navigateToFavorites(),
      },
      {
        'icon': Icons.local_offer,
        'label': 'offers'.tr,
        'isPercentage': true,
        'onTap': () => controller.navigateToOffers(),
      },
      {
        'icon': Icons.description_outlined,
        'label': 'bills'.tr,
        'onTap': () => controller.navigateToBills(),
      },
      {
        'icon': Icons.sports_esports,
        'label': 'gaming'.tr,
        'onTap': () => controller.navigateToGaming(),
      },
      {
        'icon': Icons.card_giftcard,
        'label': 'gift_vouchers'.tr,
        'onTap': () => controller.navigateToGiftVouchers(),
      },
      {
        'icon': Icons.fitness_center,
        'label': 'fitness'.tr,
        'onTap': () => controller.navigateToFitness(),
      },
      {
        'icon': Icons.auto_stories,
        'label': 'education'.tr,
        'onTap': () => controller.navigateToEducation(),
      },
      {
        'icon': Icons.local_movies,
        'label': 'entertainment'.tr,
        'onTap': () => controller.navigateToEntertainment(),
      },
    ];

    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: _buildCategoryIcon(
              icon: category['icon'] as IconData,
              label: category['label'] as String,
              isPercentage: category['isPercentage'] as bool? ?? false,
              onTap: category['onTap'] as VoidCallback,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryIcon({
    required IconData icon,
    required String label,
    bool isPercentage = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child:
                isPercentage
                    ? Text(
                      '%',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                    : Icon(icon, color: Colors.black87, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
