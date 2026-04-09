import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../profile/controllers/profile_controller.dart';

// Version avec FAB Scan au centre - HAUTEUR RÉDUITE
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onScanTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
  });

  // Couleurs selon le rôle
  static const Color vendorGreen = Color(0xFFFFC107);
  static const Color vendorGreenLight = Color(0xFFFFC107);
  static const Color adminBlue = Color(0xFF2196F3);
  static const Color adminBlueLight = Color(0xFF2196F3);
  static const Color defaultOrange = Color(0xFFFF6B35);
  static const Color defaultOrangeDark = Color(0xFFE55100);

  void _handleNavigation(int index) {
    onTap(index);
  }

  Color _getPrimaryColor() {
    try {
      final profileController = Get.find<ProfileController>();
      switch (profileController.selectedRole.value) {
        case 'Vendor':
          return vendorGreen;
        case 'Admin':
          return adminBlue;
        default:
          return defaultOrange;
      }
    } catch (e) {
      return defaultOrange;
    }
  }

  List<Color> _getGradientColors() {
    try {
      final profileController = Get.find<ProfileController>();
      switch (profileController.selectedRole.value) {
        case 'Vendor':
          return [vendorGreen, vendorGreenLight];
        case 'Admin':
          return [adminBlue, adminBlueLight];
        default:
          return [defaultOrange, defaultOrangeDark];
      }
    } catch (e) {
      return [defaultOrange, defaultOrangeDark];
    }
  }

  String _getRole() {
    try {
      final profileController = Get.find<ProfileController>();
      return profileController.selectedRole.value;
    } catch (e) {
      return 'Customer';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final primaryColor = _getPrimaryColor();
      final gradientColors = _getGradientColors();
      final role = _getRole();
      final isVendor = role == 'Vendor';

      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Bar
          Container(
            height: 65.h,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Premier onglet : Home ou Brand
                    _buildNavItem(
                      icon: isVendor ? Icons.store : CupertinoIcons.home,
                      label: isVendor ? 'Brand' : 'Home',
                      index: 0,
                      primaryColor: primaryColor,
                    ),

                    // Deuxième onglet : Offers ou Order
                    _buildNavItem(
                      icon: isVendor ? Icons.receipt_long : CupertinoIcons.gift,
                      label: isVendor ? 'Order' : 'Offers',
                      index: 1,
                      primaryColor: primaryColor,
                    ),

                    // Espace vide pour le FAB
                    SizedBox(width: MediaQuery.of(context).size.width * 0.2),

                    // Troisième onglet : Bills
                    _buildNavItem(
                      icon: CupertinoIcons.command,
                      // svgAsset: "assets/icons/digital.png",
                      label: 'Digital',
                      index: 2,
                      primaryColor: primaryColor,
                    ),

                    // Quatrième onglet : Account
                    _buildNavItem(
                      icon: CupertinoIcons.person,
                      label: 'Account',
                      index: 3,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button centré
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 28.w,
            top: -22.h,
            child: Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28.r),
                  onTap: onScanTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color primaryColor,
    String? svgAsset, // Nouveau paramètre optionnel pour l'image SVG
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _handleNavigation(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: MediaQuery.of(Get.context!).size.width * 0.15,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            svgAsset != null
                ? Image.asset(
                  svgAsset,
                  width: 20.sp,
                  height: 20.sp,
                  // color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                )
                : Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                fontFamily: 'SF Pro Text',
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
