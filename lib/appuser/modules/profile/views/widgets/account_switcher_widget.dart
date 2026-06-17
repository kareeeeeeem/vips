import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_home/views/merchant_home_view.dart';
import 'package:vip/appmerchant/modules/merchant_home/bindings/merchant_home_binding.dart';
import 'package:vip/appmerchant/routes/merchant_pages.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

/// Displays a premium account switcher bottom sheet.
/// Call: showAccountSwitcher(context);
void showAccountSwitcher(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const AccountSwitcherSheet(),
  );
}

class AccountSwitcherSheet extends StatelessWidget {
  const AccountSwitcherSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch Account',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Choose your workspace',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Customer Account Card (Active)
                _buildAccountCard(
                  icon: Icons.person_rounded,
                  title: 'Full Name',
                  subtitle: 'Customer Account',
                  badge: 'Active',
                  gradientColors: const [Color(0xFFF97316), Color(0xFFEAB308)],
                  isActive: true,
                  onTap: () {
                    Get.back();
                    // Already in customer app
                  },
                ),

                SizedBox(height: 12.h),

                // Merchant Account Card
                _buildAccountCard(
                  icon: Icons.storefront_rounded,
                  title: "McDonald's",
                  subtitle: 'Merchant Dashboard',
                  badge: 'Merchant',
                  gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                  isActive: false,
                  onTap: () {
                    Get.back();
                    _switchToMerchant();
                  },
                ),

                SizedBox(height: 20.h),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Add Account Button
                GestureDetector(
                  onTap: () {
                    Get.back();
                    // Navigate to add merchant account
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Add Merchant Account',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.sp,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required List<Color> gradientColors,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isActive
                    ? [
                      gradientColors[0].withOpacity(0.2),
                      gradientColors[1].withOpacity(0.1),
                    ]
                    : [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.03),
                    ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isActive
                    ? gradientColors[0].withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar with gradient
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26.sp),
            ),

            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient:
                    isActive
                        ? LinearGradient(colors: gradientColors)
                        : null,
                color:
                    isActive ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Arrow
            Icon(
              isActive
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color:
                  isActive
                      ? gradientColors[0]
                      : Colors.white.withOpacity(0.3),
              size: isActive ? 20.sp : 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _switchToMerchant() {
    // Navigate to merchant home using GetX routing within the same app context
    // Since both apps are in the same project, we navigate to MerchantHomeView
    Get.to(
      () => const MerchantHomeView(),
      binding: MerchantHomeBinding(),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 400),
    );
  }
}
