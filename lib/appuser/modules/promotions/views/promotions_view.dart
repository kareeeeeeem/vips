import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/promotions/views/widgets/promotion_detail_dialog.dart'
    hide Promotion;

import '../controllers/promotions_controller.dart';

class PromotionsView extends GetView<PromotionsController> {
  const PromotionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PromotionsController());
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFFF6B35),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildAddPromotionButton(),
                    Expanded(child: _buildPromotionsList()),
                  ],
                );
              }),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 18.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Promotions',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  controller.tabController.animateTo(0);
                  controller.selectedTab.value = 0;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTab.value == 0
                                ? const Color(0xFFFF6B35)
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Order Offers',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            controller.selectedTab.value == 0
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF9CA3AF),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () {
                  controller.tabController.animateTo(1);
                  controller.selectedTab.value = 1;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            controller.selectedTab.value == 1
                                ? const Color(0xFFFF6B35)
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Shipping Offers',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            controller.selectedTab.value == 1
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF9CA3AF),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPromotionButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GestureDetector(
        onTap: controller.addNewPromotion,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: const Color(0xFFFF6B35),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Add New Promotions',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6B35),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              Spacer(),
              Icon(
                Icons.qr_code_scanner,
                color: const Color(0xFFFF6B35),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionsList() {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.currentPromotions.length,
        itemBuilder: (context, index) {
          final promotion = controller.currentPromotions[index];
          return _buildRealisticTicket(promotion);
        },
      ),
    );
  }

  // ==================== ULTRA-REALISTIC TICKET ====================

  Widget _buildRealisticTicket(Promotion promotion) {
    final isSelected = controller.selectedPromotions.contains(promotion.id);

    return GestureDetector(
      onTap: () => controller.togglePromotionSelection(promotion.id),
      onLongPress: () => controller.viewPromotionDetails(promotion),
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        child: Stack(
          children: [
            ClipPath(
              clipper: RealisticTicketClipper(),
              child: Container(
                height: 110.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    // Ombre principale
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    // Ombre secondaire pour plus de profondeur
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Texture papier subtile
                    Positioned.fill(
                      child: CustomPaint(painter: PaperTexturePainter()),
                    ),

                    Positioned(
                      right: 10,
                      child: IconButton(
                        onPressed: () {
                          Get.to(
                            () => PromotionDetailPage(),
                            arguments: promotion,
                            binding: PromotionDetailBinding(),
                            transition: Transition.fadeIn,
                            duration: Duration(milliseconds: 300),
                          );
                        },
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: CupertinoColors.systemGrey3,
                        ),
                      ),
                    ),

                    // Contenu du ticket
                    Row(
                      children: [
                        // Logo Section
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            child: Center(
                              child:
                                  promotion.brandLogo != null
                                      ? CachedNetworkImage(
                                        imageUrl: promotion.brandLogo!,
                                        height: 60.h,
                                        width: 60.w,
                                        fit: BoxFit.contain,
                                        placeholder:
                                            (context, url) => SizedBox(
                                              width: 24.w,
                                              height: 24.h,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: const Color(0xFFFF6B35),
                                              ),
                                            ),
                                        errorWidget:
                                            (context, url, error) => Icon(
                                              Icons.local_offer,
                                              color: const Color(0xFFFF6B35),
                                              size: 32.sp,
                                            ),
                                      )
                                      : Icon(
                                        Icons.local_offer,
                                        color: const Color(0xFFFF6B35),
                                        size: 32.sp,
                                      ),
                            ),
                          ),
                        ),

                        // Perforations verticales fines
                        CustomPaint(
                          size: Size(1.w, 110.h),
                          painter: PerforationLinePainter(),
                        ),

                        // Details Section
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 14.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
                                Text(
                                  promotion.title,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontFamily: 'SF Pro Display',
                                    height: 1.1,
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                SizedBox(height: 6.h),

                                // Brand Name
                                Text(
                                  promotion.brandName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                    fontFamily: 'SF Pro Display',
                                    letterSpacing: -0.2,
                                  ),
                                ),

                                Spacer(),

                                // Valid Until avec icône
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 12.sp,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Valid until ${promotion.validUntil}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF9CA3AF),
                                        fontFamily: 'SF Pro Text',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bordure de sélection (si sélectionné)
            if (isSelected)
              Positioned.fill(
                child: ClipPath(
                  clipper: RealisticTicketClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: controller.applyPromotions,
        child: Container(
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF6B35),
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== REALISTIC TICKET CLIPPER (Découpes ultra-fines) ====================

class RealisticTicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Paramètres des découpes - plus petites et plus fines
    final notchRadius = 8.0; // Rayon réduit pour un look plus fin
    final notchCount = 5; // Nombre de découpes sur chaque côté
    final spacing = size.height / (notchCount + 1);

    // Commencer en haut à gauche
    path.moveTo(0, 0);

    // Bord supérieur
    path.lineTo(size.width, 0);

    // Bord droit avec découpes
    for (int i = 1; i <= notchCount; i++) {
      final y = spacing * i;

      if (i == 1) {
        // Première découpe
        path.lineTo(size.width, y - notchRadius);
      }

      // Découpe circulaire
      path.arcToPoint(
        Offset(size.width, y + notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );

      if (i == notchCount) {
        // Dernière découpe, aller jusqu'au coin
        path.lineTo(size.width, size.height);
      }
    }

    // Bord inférieur
    path.lineTo(0, size.height);

    // Bord gauche avec découpes
    for (int i = notchCount; i >= 1; i--) {
      final y = spacing * i;

      if (i == notchCount) {
        // Première découpe depuis le bas
        path.lineTo(0, y + notchRadius);
      }

      // Découpe circulaire
      path.arcToPoint(
        Offset(0, y - notchRadius),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      );

      if (i == 1) {
        // Dernière découpe, aller jusqu'au coin
        path.lineTo(0, 0);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==================== PERFORATION LINE (Ligne de perforations fines) ====================

class PerforationLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFE5E7EB)
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round;

    const dotRadius = 1.5;
    const spacing = 4.0;
    double currentY = spacing;

    while (currentY < size.height) {
      // Dessiner un petit cercle
      canvas.drawCircle(Offset(size.width / 2, currentY), dotRadius, paint);
      currentY += spacing;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ==================== PAPER TEXTURE (Texture papier subtile) ====================

class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size sizes) {
    final paint =
        Paint()
          ..color = const Color(0xFFFAFAFA).withOpacity(0.3)
          ..style = PaintingStyle.fill;

    // Ajouter un grain très subtil
    final random = math.Random(42);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * sizes.width;
      final y = random.nextDouble() * sizes.height;
      final size = random.nextDouble() * 0.5;

      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
