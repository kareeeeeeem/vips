import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class VoucherOffer {
  final String id;
  final String title;
  final String subtitle;
  final int discountPercent;
  final int pointsRequired;
  final String memberType;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;
  final String termsAndConditions;
  final bool isPopular;
  final String? badge;

  VoucherOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountPercent,
    required this.pointsRequired,
    required this.memberType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    required this.termsAndConditions,
    this.isPopular = false,
    this.badge,
  });
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

  // Voucher offers
  final vouchers =
      <VoucherOffer>[
        VoucherOffer(
          id: '1',
          title: '10% discount voucher',
          subtitle: 'For all members',
          discountPercent: 10,
          pointsRequired: 1500,
          memberType: 'All Members',
          primaryColor: const Color(0xFFB24BF3),
          secondaryColor: const Color(0xFF8B2FC9),
          description:
              'Sure thing! Your "10% discount voucher" is a fabulous offer that allows you to enjoy 10% off the regular price on selected items or services.\n\nThis voucher is your ticket to some sweet savings—whether you\'re treating yourself or snagging a great deal for someone special.',
          termsAndConditions:
              '• Valid for 30 days from redemption\n• Cannot be combined with other offers\n• Applicable to selected items only\n• Non-transferable\n• No cash alternative',
        ),
        VoucherOffer(
          id: '2',
          title: '25% discount voucher',
          subtitle: 'For platinum member',
          discountPercent: 25,
          pointsRequired: 3000,
          memberType: 'Platinum Member',
          primaryColor: const Color(0xFF6C63FF),
          secondaryColor: const Color(0xFF5449CC),
          isPopular: true,
          badge: 'Popular',
          description:
              'Sure thing! Your "25% discount voucher" is a fabulous offer that allows you to enjoy a quarter off the regular price on selected items or services.\n\nThis voucher is your ticket to some sweet savings—whether you\'re treating yourself or snagging a great deal for someone special.',
          termsAndConditions:
              '• Valid for 60 days from redemption\n• Exclusive to Platinum members\n• Cannot be combined with other offers\n• Applicable to selected items only\n• Non-transferable\n• No cash alternative',
        ),
        VoucherOffer(
          id: '3',
          title: '20% discount voucher',
          subtitle: 'For gold member',
          discountPercent: 20,
          pointsRequired: 2500,
          memberType: 'Gold Member',
          primaryColor: const Color(0xFFFF9B3D),
          secondaryColor: const Color(0xFFFF7A00),
          description:
              'Sure thing! Your "20% discount voucher" is a fabulous offer that allows you to enjoy 20% off the regular price on selected items or services.\n\nThis voucher is your ticket to some sweet savings—whether you\'re treating yourself or snagging a great deal for someone special.',
          termsAndConditions:
              '• Valid for 45 days from redemption\n• Exclusive to Gold members\n• Cannot be combined with other offers\n• Applicable to selected items only\n• Non-transferable\n• No cash alternative',
        ),
        VoucherOffer(
          id: '4',
          title: '15% discount voucher',
          subtitle: 'For silver member',
          discountPercent: 15,
          pointsRequired: 2000,
          memberType: 'Silver Member',
          primaryColor: const Color(0xFFC0C0C0),
          secondaryColor: const Color(0xFFA8A8A8),
          description:
              'Sure thing! Your "15% discount voucher" is a fabulous offer that allows you to enjoy 15% off the regular price on selected items or services.\n\nThis voucher is your ticket to some sweet savings—whether you\'re treating yourself or snagging a great deal for someone special.',
          termsAndConditions:
              '• Valid for 30 days from redemption\n• Exclusive to Silver members\n• Cannot be combined with other offers\n• Applicable to selected items only\n• Non-transferable\n• No cash alternative',
        ),
      ].obs;

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

  Future<void> redeemVoucher() async {
    if (selectedVoucher.value == null) return;

    // Show loading
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: selectedVoucher.value!.primaryColor,
        ),
      ),
      barrierDismissible: false,
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    Get.back();

    // Show success dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      selectedVoucher.value!.primaryColor,
                      selectedVoucher.value!.secondaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Voucher Redeemed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your ${selectedVoucher.value!.title} has been successfully redeemed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedVoucher.value!.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View My Vouchers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RedeemView extends GetView<RedeemController> {
  const RedeemView({Key? key}) : super(key: key);

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
            color: const Color(0xFFE5E7EB).withOpacity(0.5),
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
                        banner.backgroundColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: banner.backgroundColor.withOpacity(0.3),
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
                            color: Colors.white.withOpacity(0.1),
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
                                color: Colors.white.withOpacity(0.25),
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
                              .withOpacity(0.4),
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
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity * 1.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withOpacity(0.8),
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
            onPressed: () {},
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
              color: voucher.primaryColor.withOpacity(0.3),
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
                    color: Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.25),
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
                          '${voucher.discountPercent}% off',
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
            color: voucher.primaryColor.withOpacity(0.4),
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
                color: Colors.white.withOpacity(0.15),
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
                  color: Colors.white.withOpacity(0.25),
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
                          '${voucher.discountPercent}% off',
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final voucher = controller.selectedVoucher.value!;
          return GestureDetector(
            onTap: controller.redeemVoucher,
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF9B3D), const Color(0xFFFF7A00)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9B3D).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
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
