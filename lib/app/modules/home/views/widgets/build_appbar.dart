import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/home/controllers/home_controller.dart';

class BuildAppbar extends GetView<HomeController> {
  const BuildAppbar(this.onTap, this.withBackButton, {super.key});

  final bool withBackButton;
  final VoidCallback onTap;

  // Couleurs centralisées pour faciliter la maintenance
  static const _backgroundColor = Color(0xFFF8FAFC);
  static const _borderColor = Color(0xFFE2E8F0);
  static const _iconColor = Color(0xFF475569);
  static const _hintColor = Color(0xFF94A3B8);
  static const _textColor = Color(0xFF1E293B);
  static const _primaryGradientStart = Color(0xFFFF6B35);
  static const _primaryGradientEnd = Color(0xFFE55100);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      padding: EdgeInsets.fromLTRB(0.w, 25.h, 0.w, 10.h),
      child: Row(
        children: [
          // Bouton Menu / Retour
          _buildIconButton(
            icon:
                withBackButton
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.menu_rounded,
            onTap: withBackButton ? () => Get.back() : onTap,
          ),

          SizedBox(width: 12.w),

          // Barre de recherche
          Expanded(child: _buildSearchBar()),

          SizedBox(width: 12.w),

          // Bouton Notifications avec badge
          _buildNotificationButton(),

          SizedBox(width: 8.w),

          // Bouton Panier avec badge
          _buildCartButton(),
        ],
      ),
    );
  }

  /// Bouton icône standard avec bordure
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Center(child: Icon(icon, color: _iconColor, size: 20.sp)),
        ),
      ),
    );
  }

  /// Barre de recherche
  Widget _buildSearchBar() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: controller.navigateToSearch,
          child: Row(
            children: [
              SizedBox(width: 12.w),
              Icon(Icons.search_rounded, color: _hintColor, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'search_placeholder'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: _hintColor,
                    fontFamily: 'SF Pro Text',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton Notifications avec badge
  Widget _buildNotificationButton() {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: controller.navigateToNotifications,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: _iconColor,
                size: 22.sp,
              ),
              // Badge de notification (optionnel - à connecter avec Obx si besoin)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Obx(() {
                  final count = controller.notificationCount.value;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    width: 16.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton Panier avec gradient et badge
  Widget _buildCartButton() {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGradientStart, _primaryGradientEnd],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: _primaryGradientStart.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: controller.navigateToCart,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Nouvelle icône panier
              Icon(
                Icons.shopping_cart_outlined, // ou Icons.local_mall_outlined
                color: Colors.white,
                size: 21.sp,
              ),
              // Badge du panier
              Positioned(
                top: 6.h,
                right: 6.w,
                child: Obx(() {
                  final count = controller.cartItemCount.value;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99' : count.toString(),
                        style: TextStyle(
                          color: _primaryGradientEnd,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
