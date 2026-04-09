import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vip/app/modules/promotions/views/widgets/promotion_info_bottomsheet.dart';

enum PromotionType { orderOffer, shippingOffer }

class Promotion {
  final String id;
  final String title;
  final String brandName;
  final String? brandLogo;
  final String validUntil;
  final PromotionType type;
  final String? description;
  final double? discountPercentage;
  final double? discountAmount;
  bool isSelected;

  Promotion({
    required this.id,
    required this.title,
    required this.brandName,
    this.brandLogo,
    required this.validUntil,
    required this.type,
    this.description,
    this.discountPercentage,
    this.discountAmount,
    this.isSelected = false,
  });
}

class PromotionDetailController extends GetxController {
  // Promotion courante
  var promotion =
      Promotion(
        id: '',
        title: '',
        brandName: '',
        validUntil: '',
        type: PromotionType.orderOffer,
      ).obs;

  @override
  void onInit() {
    super.onInit();
    _loadPromotion();
  }

  void _loadPromotion() {
    // Récupérer la promotion passée en argument
    if (Get.arguments != null && Get.arguments is Promotion) {
      promotion.value = Get.arguments as Promotion;
    }
  }

  // ==================== GETTERS ====================

  String getDiscountText() {
    if (promotion.value.discountPercentage != null) {
      return '${promotion.value.discountPercentage!.toInt()}';
    } else if (promotion.value.discountAmount != null) {
      return '${promotion.value.discountAmount!.toInt()}';
    }
    return '25'; // Default
  }

  String getMainTitle() {
    final promo = promotion.value;

    if (promo.discountPercentage != null) {
      return 'Get ${promo.discountPercentage!.toInt()}% at your next ${promo.brandName} buy';
    } else if (promo.discountAmount != null) {
      return 'Get D ${promo.discountAmount!.toInt()} off at ${promo.brandName}';
    } else if (promo.description != null && promo.description!.isNotEmpty) {
      return promo.description!;
    }

    return promo.title;
  }

  List<String> getConditions() {
    final promo = promotion.value;

    if (promo.type == PromotionType.orderOffer) {
      return [
        'Reedeamable at all ${promo.brandName} restaurants in the UK.',
        'Not valid with any other discounts and promotions.',
        'No cash value.',
      ];
    } else {
      return [
        'Valid for delivery orders only.',
        'Minimum order value may apply.',
        'Cannot be combined with other offers.',
      ];
    }
  }

  String getQRData() {
    final promo = promotion.value;
    return 'V6i8P25s';
  }

  // ==================== ACTIONS ====================

  void goBack() {
    Get.back();
  }

  void sharePromotion() {
    final promo = promotion.value;

    Get.snackbar(
      'Shared!',
      'Promotion shared successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  void showInfo() {
    PromotionInfoBottomSheet.show(
      title: 'FREE SHIPPING',
      description: 'Enjoy free shipping on all orders throughout this month!',
      promoCode: 'V6i8P25s',
      discountText: '100% off shipping (Free shipping).',
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'SF Pro Display',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
            fontFamily: 'SF Pro Text',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void applyPromotion() {
    final promo = promotion.value;

    // Afficher dialog de confirmation
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône de succès
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFF22C55E),
                  size: 50.sp,
                ),
              ),

              SizedBox(height: 20.h),

              // Titre
              Text(
                'Promotion Applied!',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),

              SizedBox(height: 12.h),

              // Message
              Text(
                'Your ${promo.title} discount has been applied to your order.',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Fermer dialog
                        Get.back(); // Retourner à la page précédente
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Continue Shopping',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Fermer dialog
                        Get.offAllNamed('/checkout'); // Aller au checkout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveToWallet() {
    Get.snackbar(
      'Coming Soon',
      'Save to Wallet feature will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      icon: Icon(Icons.wallet_outlined, color: Colors.white, size: 24.sp),
    );
  }
}

/// Page de détails d'une promotion - Design Ticket
class PromotionDetailPage extends GetView<PromotionDetailController> {
  const PromotionDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildTicketCard(),
                      SizedBox(height: 24.h),
                      //_buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================

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
              child: Icon(Icons.close, color: Colors.black, size: 24.sp),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Promotion Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          SizedBox(width: 44.w), // Symmetry
        ],
      ),
    );
  }

  // ==================== TICKET CARD ====================

  Widget _buildTicketCard() {
    return ClipPath(
      clipper: TicketShapeClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [_buildTopSection(), _buildDivider(), _buildQRSection()],
        ),
      ),
    );
  }

  // ==================== TOP SECTION ====================

  Widget _buildTopSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildHeaderRow(),
          SizedBox(height: 15.h),
          _buildMainTitle(),
          SizedBox(height: 24.h),
          _buildConditionsList(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        //  _buildBrandLogo(),
        Spacer(),
        // Badge de réduction
        _buildDiscountBadge(),
      ],
    );
  }

  Widget _buildBrandLogo() {
    return Obx(() {
      final promotion = controller.promotion.value;

      if (promotion.brandLogo == null) {
        return Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.local_offer,
            color: const Color(0xFFFF6B35),
            size: 40.sp,
          ),
        );
      }

      return CachedNetworkImage(
        imageUrl: promotion.brandLogo!,
        width: 100.w,
        height: 70.h,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        placeholder:
            (context, url) => Container(
              width: 100.w,
              height: 70.h,
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFFFF6B35),
                  ),
                ),
              ),
            ),
        errorWidget:
            (context, url, error) => Icon(
              Icons.local_offer,
              color: const Color(0xFFFF6B35),
              size: 40.sp,
            ),
      );
    });
  }

  Widget _buildDiscountBadge() {
    return Obx(() {
      final promotion = controller.promotion.value;
      final badgeText = controller.getDiscountText();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(12.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.percent, color: Colors.white, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              badgeText,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
                height: 1,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'off',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMainTitle() {
    return Obx(() {
      final title = controller.getMainTitle();

      return Text(
        'Get 25% at your next KFC buy',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          fontFamily: 'SF Pro Display',
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      );
    });
  }

  Widget _buildConditionsList() {
    return Obx(() {
      final conditions = controller.getConditions();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            conditions.map((condition) {
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      margin: EdgeInsets.only(top: 9.h, right: 14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        condition,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF4B5563),
                          fontFamily: 'SF Pro Text',
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      );
    });
  }

  // ==================== DIVIDER ====================

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      margin: EdgeInsets.symmetric(horizontal: 28.w),
      child: CustomPaint(
        painter: DashedDividerPainter(),
        size: Size(double.infinity, 1.h),
      ),
    );
  }

  // ==================== QR SECTION ====================

  Widget _buildQRSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 15.h),
      child: Column(
        children: [_buildQRCode(), SizedBox(height: 28.h), _buildBottomInfo()],
      ),
    );
  }

  Widget _buildQRCode() {
    return Obx(() {
      final qrData = controller.getQRData();

      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 200.w,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
        ),
      );
    });
  }

  Widget _buildBottomInfo() {
    return Obx(() {
      final promotion = controller.promotion.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Partage
          _buildIconButton(
            icon: Icons.share_outlined,
            onTap: controller.sharePromotion,
            color: const Color(0xFF0F766E),
          ),

          // Validité
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Valid until ${promotion.validUntil}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton Info
          _buildIconButton(
            icon: Icons.info_outline,
            onTap: controller.showInfo,
            color: const Color(0xFF0F766E),
          ),
        ],
      );
    });
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  // ==================== ACTION BUTTONS ====================

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton Apply
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: ElevatedButton(
            onPressed: controller.applyPromotion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
              shadowColor: const Color(0xFFFF6B35).withOpacity(0.4),
            ),
            child: Text(
              'Apply Promotion',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Bouton Save to Wallet (optionnel)
        SizedBox(
          width: double.infinity,
          height: 54.h,
          child: OutlinedButton(
            onPressed: controller.saveToWallet,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFFE5E7EB), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wallet_outlined,
                  color: const Color(0xFF6B7280),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Save to Wallet',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== TICKET SHAPE CLIPPER ====================

class TicketShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    final notchRadius = 12.0;
    final dividerY = size.height * 0.58; // Position de la séparation

    // Commencer en haut à gauche
    path.moveTo(0, 0);

    // Bord supérieur
    path.lineTo(size.width, 0);

    // Bord droit jusqu'à la découpe
    path.lineTo(size.width, dividerY - notchRadius);

    // Découpe droite
    path.arcToPoint(
      Offset(size.width, dividerY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Bord droit après découpe
    path.lineTo(size.width, size.height);

    // Bord inférieur
    path.lineTo(0, size.height);

    // Bord gauche jusqu'à la découpe
    path.lineTo(0, dividerY + notchRadius);

    // Découpe gauche
    path.arcToPoint(
      Offset(0, dividerY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Bord gauche après découpe
    path.lineTo(0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==================== DASHED DIVIDER PAINTER ====================

class DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFD1D5DB)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ==================== BINDING ====================

class PromotionDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PromotionDetailController>(() => PromotionDetailController());
  }
}
