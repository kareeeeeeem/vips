import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/main_app/views/widgets/reward_page.dart';

import '../../../QR_scanner/views/q_r_scanner_view.dart';
import 'gift_back_page.dart';

class WalletPointsBottomSheet {
  static void show({
    required Color primaryColor,
    required double points,
    String? role,
  }) {
    final actionColors =
        role != null
            ? _getPredefinedColors(role)
            : _getActionColors(primaryColor);

    final backgroundColor = _getBackgroundColor(role ?? 'Customer');

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Stack(
          children: [
            // Background decoration
            _buildBackgroundDecoration(role ?? 'Customer'),

            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                SizedBox(height: 24.h),

                // Available VIPs Points Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available VIPs Points',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              // Eye icon
                              GestureDetector(
                                onTap: () {
                                  // Toggle visibility
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.visibility_outlined,
                                    size: 20.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Close icon
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 20.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Points display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            points.toInt().toString(),
                            style: TextStyle(
                              fontSize: 56.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Quick Actions Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              title: 'Reward',
                              subtitle: 'Income',
                              icon: Icons.arrow_downward_rounded,
                              color: actionColors['reward']!,
                              onTap: () {
                                Get.to(() => RewardPage());
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildActionCard(
                              title: 'Gift Back',
                              subtitle: 'Income',
                              icon: Icons.arrow_downward_rounded,
                              color: actionColors['giftBack']!,
                              onTap: () {
                                Get.to(() => GiftBackPage());
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              title: 'Switch',
                              subtitle: 'Expense',
                              icon: Icons.arrow_upward_rounded,
                              color: actionColors['switch']!,
                              onTap: () {
                                // Navigate to switch
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildActionCard(
                              title: 'Scan QR',
                              subtitle: '',
                              icon: Icons.qr_code_scanner_rounded,
                              color: actionColors['scanQR']!,
                              onTap: () {
                                Get.to(() => QRScannerView());
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Obtenir la couleur de fond selon le rôle
  static Color _getBackgroundColor(String role) {
    switch (role) {
      case 'Customer':
        return Color(0xFFE8D4F8); // Rose/Violet clair
      case 'Vendor':
        return Color(0xFFFFE4F5); // Rose clair
      case 'Agent':
        return Color(0xFFD4F8E8); // Vert menthe clair
      case 'Business':
        return Color(0xFFFFF4D4); // Jaune/Beige clair
      default:
        return Colors.white;
    }
  }

  // Widget de décoration du background
  static Widget _buildBackgroundDecoration(String role) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: Stack(
          children: [
            // Cercles décoratifs en haut à gauche
            Positioned(
              top: -50.h,
              left: -50.w,
              child: Container(
                width: 150.w,
                height: 150.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),

            // Cercles décoratifs en haut à droite
            Positioned(
              top: -30.h,
              right: -30.w,
              child: Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Cercle moyen à gauche
            Positioned(
              top: 100.h,
              left: -40.w,
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // Cercles décoratifs en bas à droite
            Positioned(
              bottom: -60.h,
              right: -40.w,
              child: Container(
                width: 180.w,
                height: 180.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            // Petit cercle en bas à gauche
            Positioned(
              bottom: 50.h,
              left: 30.w,
              child: Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Palettes de couleurs prédéfinies pour chaque rôle
  static Map<String, Color> _getPredefinedColors(String role) {
    switch (role) {
      case 'Customer':
        return {
          'reward': Color(0xFF8B7FEB), // Bleu violet
          'giftBack': Color(0xFFB37FEB), // Violet
          'switch': Color(0xFFFF9B9B), // Rose corail
          'scanQR': Color(0xFF7A7A7A), // Gris
        };

      case 'Vendor':
        return {
          'reward': Color(0xFF8B7FEB), // Bleu violet
          'giftBack': Color(0xFFB37FEB), // Violet
          'switch': Color(0xFFFF9B9B), // Rose
          'scanQR': Color(0xFF7A7A7A), // Gris
        };

      case 'Agent':
        return {
          'reward': Color(0xFF5ED5A8), // Vert menthe
          'giftBack': Color(0xFF8B7FEB), // Violet
          'switch': Color(0xFFFF9B9B), // Rose corail
          'scanQR': Color(0xFF7A7A7A), // Gris
        };

      case 'Business':
        return {
          'reward': Color(0xFF8B9FEB), // Bleu clair
          'giftBack': Color(0xFFB37FEB), // Violet
          'switch': Color(0xFFFFB84D), // Orange/Jaune
          'scanQR': Color(0xFF7A7A7A), // Gris
        };

      default:
        return {
          'reward': Color(0xFF6B8AFF),
          'giftBack': Color(0xFFB37FEB),
          'switch': Color(0xFFFF9B9B),
          'scanQR': Color(0xFF7A7A7A),
        };
    }
  }

  // Générer des variations de couleur basées sur la primaryColor
  static Map<String, Color> _getActionColors(Color primaryColor) {
    final HSLColor hslColor = HSLColor.fromColor(primaryColor);

    return {
      'reward':
          HSLColor.fromAHSL(
            1.0,
            (hslColor.hue + 30) % 360,
            0.7,
            0.65,
          ).toColor(),
      'giftBack':
          HSLColor.fromAHSL(
            1.0,
            (hslColor.hue + 60) % 360,
            0.6,
            0.65,
          ).toColor(),
      'switch':
          HSLColor.fromAHSL(
            1.0,
            (hslColor.hue + 90) % 360,
            0.65,
            0.7,
          ).toColor(),
      'scanQR': Color(0xFF7A7A7A),
    };
  }

  static Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle.isNotEmpty) ...[
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
