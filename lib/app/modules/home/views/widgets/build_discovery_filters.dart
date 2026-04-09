import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/home/controllers/home_controller.dart';

class BuildDiscoveryFilters extends GetView<HomeController> {
  const BuildDiscoveryFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scroll horizontal des cartes
          SizedBox(
            height: 140.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                // Discover Nearest Places (plus large)
                SizedBox(
                  width: 150.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.location_on,
                    title: 'discover_nearest_places'.tr,
                    subtitle: 'find_places_around_you'.tr,
                    backgroundColor: const Color(0xFFFF6B35),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    onTap: () => controller.navigateToNearestPlaces(),
                  ),
                ),

                SizedBox(width: 12.w),

                // Food & Beverage
                SizedBox(
                  width: 130.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.restaurant_menu,
                    title: 'food_beverage'.tr,
                    subtitle: 'delicious_meals'.tr,
                    backgroundColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFFEF4444),
                    textColor: const Color(0xFF1E293B),
                    borderColor: const Color(0xFFE2E8F0),
                    onTap: () => controller.navigateToFoodBeverage(),
                  ),
                ),

                SizedBox(width: 12.w),

                // Fun & Activities
                SizedBox(
                  width: 130.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.celebration_outlined,
                    title: 'fun_activities'.tr,
                    subtitle: 'enjoy_your_time'.tr,
                    backgroundColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFFEC4899),
                    textColor: const Color(0xFF1E293B),
                    borderColor: const Color(0xFFE2E8F0),
                    onTap: () => controller.navigateToFunActivities(),
                  ),
                ),

                SizedBox(width: 12.w),

                // Shopping
                SizedBox(
                  width: 130.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'shopping'.tr,
                    subtitle: 'best_deals'.tr,
                    backgroundColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFF8B5CF6),
                    textColor: const Color(0xFF1E293B),
                    borderColor: const Color(0xFFE2E8F0),
                    onTap: () => controller.navigateToShopping(),
                  ),
                ),

                SizedBox(width: 12.w),

                // Travel
                SizedBox(
                  width: 130.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.flight_takeoff,
                    title: 'travel'.tr,
                    subtitle: 'explore_world'.tr,
                    backgroundColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFF06B6D4),
                    textColor: const Color(0xFF1E293B),
                    borderColor: const Color(0xFFE2E8F0),
                    onTap: () => controller.navigateToTravel(),
                  ),
                ),

                SizedBox(width: 12.w),

                // Health & Wellness
                SizedBox(
                  width: 130.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.medical_services_outlined,
                    title: 'health_wellness'.tr,
                    subtitle: 'stay_healthy'.tr,
                    backgroundColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFF10B981),
                    textColor: const Color(0xFF1E293B),
                    borderColor: const Color(0xFFE2E8F0),
                    onTap: () => controller.navigateToHealth(),
                  ),
                ),

                SizedBox(width: 12.w),

                // Beauty & Spa
                SizedBox(
                  width: 130.w,
                  child: _buildDiscoveryCard(
                    icon: Icons.spa_outlined,
                    title: 'beauty_spa'.tr,
                    subtitle: 'relax_refresh'.tr,
                    backgroundColor: const Color(0xFFF8FAFC),
                    iconColor: const Color(0xFFF59E0B),
                    textColor: const Color(0xFF1E293B),
                    borderColor: const Color(0xFFE2E8F0),
                    onTap: () => controller.navigateToBills(),
                  ),
                ),

                SizedBox(width: 16.w), // Espace final
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border:
              borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icône
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    iconColor == Colors.white
                        ? Colors.white.withOpacity(0.2)
                        : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 24.sp, color: iconColor),
            ),

            // Textes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: 'SF Pro Text',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.7),
                      fontFamily: 'SF Pro Text',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
