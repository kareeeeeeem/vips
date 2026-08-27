import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


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
  static const Color defaultOrange = Color(0xFFFF6B35);
  static const Color defaultOrangeDark = Color(0xFFE55100);

  void _handleNavigation(int index) {
    onTap(index);
  }

  // ProfileController.selectedRole is permanently 'Customer' — the consumer
  // app has no role switcher and the multi-role screens were removed in an
  // earlier pass — so the Vendor/Admin branches here could never render. The
  // nav also used them to relabel Home->Brand and Offers->Order, which would
  // have been plain wrong in a customer app.
  Color _getPrimaryColor() => defaultOrange;

  List<Color> _getGradientColors() => [defaultOrange, defaultOrangeDark];


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final primaryColor = _getPrimaryColor();
      final gradientColors = _getGradientColors();
      return Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Bar
          Container(
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Builder(builder: (context) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Premier onglet : Home ou Brand
                      _buildNavItem(
                        screenWidth: screenWidth,
                        icon: CupertinoIcons.home,
                        label: 'Home',
                        index: 0,
                        primaryColor: primaryColor,
                      ),

                      // Deuxième onglet : Offers ou Order
                      _buildNavItem(
                        screenWidth: screenWidth,
                        icon: CupertinoIcons.gift,
                        label: 'Offers',
                        index: 1,
                        primaryColor: primaryColor,
                      ),

                      // Espace vide pour le FAB
                      SizedBox(width: screenWidth * 0.2),

                      // Troisième onglet : Bills
                      _buildNavItem(
                        screenWidth: screenWidth,
                        icon: CupertinoIcons.command,
                        // svgAsset: "assets/icons/digital.png",
                        label: 'Digital',
                        index: 2,
                        primaryColor: primaryColor,
                      ),

                      // Quatrième onglet : Account
                      _buildNavItem(
                        screenWidth: screenWidth,
                        icon: CupertinoIcons.person,
                        label: 'Account',
                        index: 3,
                        primaryColor: primaryColor,
                      ),
                    ],
                  );
                }),
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
                    color: primaryColor.withValues(alpha: 0.4),
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
                  // Opens the Wallet/Quick-Actions sheet (Reward, Gift Back,
                  // Switch, Scan QR) — not a direct camera launch, so a
                  // scanner icon here misled users into expecting the camera
                  // to open immediately.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24.sp,
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
    required double screenWidth,
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
        width: screenWidth * 0.15,
        padding: EdgeInsets.zero,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            svgAsset != null
                ? Image.asset(
                    svgAsset,
                    width: 16.sp,
                    height: 16.sp,
                  // color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                )
                : Icon(
                    icon,
                    size: 16.sp,
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
