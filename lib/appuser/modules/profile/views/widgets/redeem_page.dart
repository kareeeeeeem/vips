import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class VoucherOffer {
  final String id;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final int pointsRequired;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;
  final String termsAndConditions;
  final bool isPopular;

  VoucherOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.pointsRequired,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    required this.termsAndConditions,
    this.isPopular = false,
  });

  // GET /rewards/voucher-catalog returns a fixed real tier list (see
  // routes/rewards.js) — colors/copy here are purely decorative, the id,
  // title, and points cost are the real values driving redemption.
  factory VoucherOffer.fromCatalog(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? 'percentage';
    final discount = (json['discount'] ?? 0).toString();
    final badge = type == 'percentage'
        ? '$discount% off'
        : type == 'shipping'
            ? 'Free shipping'
            : '$discount TND off';
    const palette = [
      [Color(0xFFB24BF3), Color(0xFF8B2FC9)],
      [Color(0xFF6C63FF), Color(0xFF5449CC)],
      [Color(0xFFFF9B3D), Color(0xFFFF7A00)],
      [Color(0xFF10B981), Color(0xFF059669)],
      [Color(0xFFEF4444), Color(0xFFDC2626)],
    ];
    final colorPair = palette[json['id'].hashCode.abs() % palette.length];
    return VoucherOffer(
      id: json['id'].toString(),
      title: json['title'].toString(),
      subtitle: 'Redeemable with points',
      badgeLabel: badge,
      pointsRequired: (json['pointsCost'] ?? 0) as int,
      primaryColor: colorPair[0],
      secondaryColor: colorPair[1],
      description:
          'Trade your VIPS points for this voucher — once redeemed, apply the code at checkout for real savings on your order.',
      termsAndConditions:
          '• Valid for 30 days from redemption\n• Single use, one order at a time\n• Cannot be combined with other offers\n• Non-transferable\n• No cash alternative',
    );
  }
}

class PromoBanner {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String? imageUrl;

  PromoBanner({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.imageUrl,
  });
}

class RedeemController extends GetxController {
  final selectedVoucher = Rx<VoucherOffer?>(null);
  final selectedTab = 'Detail'.obs;
  final currentBannerIndex = 0.obs;
  final currentPoints = 0.obs;
  final isLoading = true.obs;
  final isRedeeming = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCatalog();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final response = await ApiService().get('/user/wallet');
      if (response.success && response.data != null) {
        currentPoints.value = ((response.data['points'] ?? 0) as num).toInt();
      }
    } catch (_) {}
  }

  Future<void> _loadCatalog() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/rewards/voucher-catalog');
      if (response.success && response.data is List) {
        vouchers.value = (response.data as List)
            .map((e) => VoucherOffer.fromCatalog(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> redeemVoucher() async {
    final voucher = selectedVoucher.value;
    if (voucher == null || isRedeeming.value) return;
    if (currentPoints.value < voucher.pointsRequired) {
      safeSnackbar('Not Enough Points', 'You need ${voucher.pointsRequired} points for this voucher.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isRedeeming.value = true;
    try {
      final response = await ApiService().post('/rewards/redeem-points', {'tierId': voucher.id});
      if (response.success && response.data != null) {
        currentPoints.value = ((response.data['newPointsBalance'] ?? 0) as num).toInt();
        final code = response.data['voucher']?['code']?.toString() ?? '';
        selectedVoucher.value = null;
        _showVoucherCodeDialog(code);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to redeem voucher: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isRedeeming.value = false;
    }
  }

  void _showVoucherCodeDialog(String code) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, color: const Color(0xFFFF9B3D), size: 40.sp),
              SizedBox(height: 12.h),
              Text('Voucher Redeemed!', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(code, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        safeSnackbar('Copied', 'Voucher code copied to clipboard', snackPosition: SnackPosition.BOTTOM);
                      },
                      child: Icon(Icons.copy, size: 18.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Text('Enter this code at checkout to apply it.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9B3D)),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Promo banners
  final promoBanners =
      <PromoBanner>[
        PromoBanner(
          title: 'Earn\nExtra Points',
          subtitle: 'Only this weekend',
          backgroundColor: const Color(0xFFFF9B3D),
        ),
        PromoBanner(
          title: 'Special\nOffer',
          subtitle: 'Limited time',
          backgroundColor: const Color(0xFF6C63FF),
        ),
        PromoBanner(
          title: 'VIP\nRewards',
          subtitle: 'Exclusive deals',
          backgroundColor: const Color(0xFFE91E63),
        ),
      ].obs;

  // Voucher offers — populated from GET /rewards/voucher-catalog by
  // _loadCatalog() in onInit(), not hardcoded.
  final vouchers = <VoucherOffer>[].obs;

  void selectVoucher(VoucherOffer voucher) {
    selectedVoucher.value = voucher;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void changeBanner(int index) {
    currentBannerIndex.value = index;
  }

  void goBack() {
    if (selectedVoucher.value != null) {
      selectedVoucher.value = null;
      selectedTab.value = 'Detail';
    } else {
      Get.back();
    }
  }
}

class RedeemView extends GetView<RedeemController> {
  const RedeemView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RedeemController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Obx(() {
          return controller.selectedVoucher.value != null
              ? _buildDetailView()
              : _buildListView();
        }),
      ),
    );
  }

  // ==================== LIST VIEW ====================

  Widget _buildListView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildPromoBanner(),
                SizedBox(height: 32.h),
                _buildSectionHeader(),
                SizedBox(height: 16.h),
                _buildVoucherGrid(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF1F2937),
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Redeem points',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: Obx(() {
            return PageView.builder(
              onPageChanged: controller.changeBanner,
              itemCount: controller.promoBanners.length,
              itemBuilder: (context, index) {
                final banner = controller.promoBanners[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        banner.backgroundColor,
                        banner.backgroundColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: banner.backgroundColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WavePatternPainter(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),

                      // Decorative circles
                      Positioned(
                        right: 30,
                        top: 30,
                        child: _buildDecorativeCircle(120, 0.15),
                      ),
                      Positioned(
                        right: 80,
                        top: 80,
                        child: _buildDecorativeCircle(80, 0.1),
                      ),
                      Positioned(
                        right: 50,
                        bottom: 40,
                        child: _buildDecorativeCircle(60, 0.08),
                      ),

                      // Content
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                banner.subtitle,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              banner.title,
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                                fontFamily: 'SF Pro Display',
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),

        // Pagination Indicators
        SizedBox(height: 16.h),
        _buildPaginationIndicators(),
      ],
    );
  }

  Widget _buildPaginationIndicators() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.promoBanners.length, (index) {
          final isActive = controller.currentBannerIndex.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: isActive ? 24.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? controller.promoBanners[index].backgroundColor
                      : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: controller.promoBanners[index].backgroundColor
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),
          );
        }),
      );
    });
  }

  Widget _buildDecorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity * 1.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.8),
              size: size * 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Redeem Your Points',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/coupon'),
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6C63FF),
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.vouchers.length,
          itemBuilder: (context, index) {
            final voucher = controller.vouchers[index];
            return _buildVoucherCard(voucher);
          },
        );
      }),
    );
  }

  Widget _buildVoucherCard(VoucherOffer voucher) {
    return GestureDetector(
      onTap: () => controller.selectVoucher(voucher),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [voucher.primaryColor, voucher.secondaryColor],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: voucher.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Wave pattern background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: CustomPaint(
                  painter: WavePatternPainter(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    voucher.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      voucher.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Discount badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: voucher.secondaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          voucher.badgeLabel,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Points
                  Text(
                    '${voucher.pointsRequired} Points',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFD700),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DETAIL VIEW ====================

  Widget _buildDetailView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Obx(() {
              final voucher = controller.selectedVoucher.value!;
              return Column(
                children: [
                  SizedBox(height: 24.h),
                  _buildVoucherDetailCard(voucher),
                  SizedBox(height: 24.h),
                  _buildTabs(),
                  SizedBox(height: 24.h),
                  _buildTabContent(voucher),
                  SizedBox(height: 100.h),
                ],
              );
            }),
          ),
        ),
        _buildRedeemButton(),
      ],
    );
  }

  Widget _buildVoucherDetailCard(VoucherOffer voucher) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [voucher.primaryColor, voucher.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: voucher.primaryColor.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Wave pattern
          Positioned.fill(
            child: CustomPaint(
              painter: WavePatternPainter(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                voucher.title,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  voucher.subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        return Row(
          children: [
            _buildTab('Detail'),
            SizedBox(width: 32.w),
            _buildTab('Terms & Conditions'),
          ],
        );
      }),
    );
  }

  Widget _buildTab(String title) {
    final isSelected = controller.selectedTab.value == title;
    return GestureDetector(
      onTap: () => controller.changeTab(title),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected
                      ? controller.selectedVoucher.value!.primaryColor
                      : const Color(0xFF9CA3AF),
              fontFamily: 'SF Pro Display',
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 3,
            width: title == 'Detail' ? 60.w : 140.w,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? controller.selectedVoucher.value!.primaryColor
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(VoucherOffer voucher) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        if (controller.selectedTab.value == 'Detail') {
          return Column(
            children: [
              // Discount badge and points
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: voucher.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          voucher.badgeLabel,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Text(
                    '${voucher.pointsRequired} points',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF9B3D),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Description
              Text(
                voucher.description,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.6,
                  fontFamily: 'SF Pro Text',
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Happy shopping!',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          );
        } else {
          return Text(
            voucher.termsAndConditions,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF6B7280),
              height: 1.6,
              fontFamily: 'SF Pro Text',
            ),
          );
        }
      }),
    );
  }

  Widget _buildRedeemButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final voucher = controller.selectedVoucher.value!;
          final isRedeeming = controller.isRedeeming.value;
          return GestureDetector(
            onTap: isRedeeming ? null : controller.redeemVoucher,
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF9B3D), const Color(0xFFFF7A00)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9B3D).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: isRedeeming
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Redeem Now',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Text(
                    'VP ${voucher.pointsRequired}',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==================== WAVE PATTERN PAINTER ====================
class WavePatternPainter extends CustomPainter {
  final Color color;

  WavePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();
    const waveHeight = 20.0;
    const waveLength = 40.0;

    for (var i = 0; i < 5; i++) {
      path.reset();
      final yOffset = (i * 30.0);

      path.moveTo(0, yOffset);

      for (var x = 0.0; x < size.width; x += waveLength) {
        path.quadraticBezierTo(
          x + waveLength / 4,
          yOffset - waveHeight,
          x + waveLength / 2,
          yOffset,
        );
        path.quadraticBezierTo(
          x + 3 * waveLength / 4,
          yOffset + waveHeight,
          x + waveLength,
          yOffset,
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
