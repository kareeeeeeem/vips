import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/packages_controller.dart';

class PackagesView extends GetView<PackagesController> {
  const PackagesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PackagesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          return controller.showDetails.value
              ? _buildDetailsView()
              : _buildPackageListView();
        }),
      ),
    );
  }

  // ==================== PACKAGE LIST VIEW ====================

  Widget _buildPackageListView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageTitle(),
                SizedBox(height: 24.h),
                _buildPackagesList(),
              ],
            ),
          ),
        ),
      ],
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
            child: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Text(
            'Upgrade Package',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontFamily: 'SF Pro Display',
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Unlock premium features and exclusive benefits',
          style: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFF6B7280),
            fontFamily: 'SF Pro Text',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesList() {
    return Obx(() {
      return Column(
        children:
            controller.packages.map((package) {
              return _buildSimplePackageCard(package);
            }).toList(),
      );
    });
  }

  Widget _buildSimplePackageCard(Package package) {
    final isCurrent = package.isCurrent;
    final isPopular = package.isPopular;

    return GestureDetector(
      onTap: () => controller.selectPackage(package),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isPopular ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isPopular
                    ? const Color(0xFFFFD700).withOpacity(0.3)
                    : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: package.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    _getPackageIcon(package.tier),
                    color: package.primaryColor,
                    size: 28.sp,
                  ),
                ),

                SizedBox(width: 16.w),

                // Package info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (isCurrent)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'Current',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF666666),
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ),
                          if (isPopular)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB800),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Most Popular',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'SF Pro Display',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      if (package.price > 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'D ${package.price.toInt()}',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF666666),
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                            Text(
                              ' /day',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF999999),
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Free Forever',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF666666),
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.sp,
                  color: const Color(0xFFCCCCCC),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Benefits list
            Column(
              children: [
                _buildBenefitRow(
                  'VP ${package.redeemPoints} Redeem Digital Products',
                ),
                SizedBox(height: 8.h),
                _buildBenefitRow(
                  '${package.giftPoints} Gift ${package.tier == PackageTier.basic ? "Diamants" : "VIPs Points"} ${package.tier == PackageTier.basic ? "to" : ""} Win${package.tier == PackageTier.basic ? " a Day" : ""}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 6.h),
          width: 4.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: const Color(0xFF999999),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
              fontFamily: 'SF Pro Text',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getPackageIcon(PackageTier tier) {
    switch (tier) {
      case PackageTier.basic:
        return Icons.star_outline_rounded;
      case PackageTier.silver:
        return Icons.stars_rounded;
      case PackageTier.gold:
        return Icons.diamond_outlined;
      case PackageTier.platinum:
        return Icons.workspace_premium_rounded;
    }
  }

  // ==================== IMPROVED DETAILS VIEW ====================

  Widget _buildDetailsView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFAFAFA), const Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          _buildModernHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildModernPackageCard(),
                  SizedBox(height: 24.h),
                  _buildModernTabs(),
                  SizedBox(height: 28.h),
                  _buildModernBenefitsSection(),
                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
          _buildModernBuyButton(),
        ],
      ),
    );
  }

  // ==================== MODERN HEADER ====================

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 16.h,
        bottom: 16.h,
      ),
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
          Expanded(
            child: Center(
              child: Text(
                'Package Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // ==================== MODERN PACKAGE CARD ====================

  Widget _buildModernPackageCard() {
    return Obx(() {
      final package = controller.selectedPackage.value;
      if (package == null) return SizedBox();

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: package.primaryColor.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  package.primaryColor,
                  package.primaryColor.withOpacity(0.85),
                  package.accentColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(28.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon with modern design
                          Container(
                            width: 72.w,
                            height: 72.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _getPackageIcon(package.tier),
                                color: Colors.white,
                                size: 36.sp,
                              ),
                            ),
                          ),

                          SizedBox(width: 16.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4.h),
                                Text(
                                  package.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                    fontFamily: 'SF Pro Display',
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                if (package.price > 0)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'D ${package.price.toInt()}',
                                        style: TextStyle(
                                          fontSize: 36.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontFamily: 'SF Pro Display',
                                          height: 1,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 4.w,
                                          top: 8.h,
                                        ),
                                        child: Text(
                                          '/year',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontFamily: 'SF Pro Text',
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'FREE',
                                    style: TextStyle(
                                      fontSize: 36.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontFamily: 'SF Pro Display',
                                      height: 1,
                                      letterSpacing: -1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Points cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildPointCard(
                              'Redeem Points',
                              package.redeemPoints.toString(),
                              Icons.card_giftcard_rounded,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildPointCard(
                              'Gift Points',
                              package.giftPoints.toString(),
                              Icons.volunteer_activism_rounded,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      _buildModernQuantitySelector(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPointCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'SF Pro Display',
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'SF Pro Text',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuantitySelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'SF Pro Text',
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Years of subscription',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: 'SF Pro Text',
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: controller.decrementQuantity,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Obx(
                    () => Container(
                      constraints: BoxConstraints(minWidth: 32.w),
                      child: Text(
                        '${controller.quantity.value}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: controller.incrementQuantity,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: controller.selectedPackage.value?.primaryColor,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MODERN TABS ====================

  Widget _buildModernTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _buildModernTab('Silver', 0, const Color(0xFFC0C0C0)),
          _buildModernTab('Gold', 1, const Color(0xFFFFB800)),
          _buildModernTab('Platinum', 2, const Color(0xFF4A5568)),
        ],
      ),
    );
  }

  Widget _buildModernTab(String title, int index, Color color) {
    return Expanded(
      child: Obx(() {
        final selectedIndex =
            controller.selectedPackage.value?.tier == PackageTier.silver
                ? 0
                : controller.selectedPackage.value?.tier == PackageTier.gold
                ? 1
                : 2;
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () => controller.changeTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : const Color(0xFF9CA3AF),
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ==================== MODERN BENEFITS SECTION ====================

  Widget _buildModernBenefitsSection() {
    return Obx(() {
      final package = controller.selectedPackage.value;
      if (package == null) return SizedBox();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [package.primaryColor, package.accentColor],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Exclusive Benefits',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            ...package.benefits.asMap().entries.map((entry) {
              return _buildModernBenefitItem(
                entry.value,
                entry.key,
                package.benefits.length,
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildModernBenefitItem(
    PackageBenefit benefit,
    int index,
    int totalCount,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: index == totalCount - 1 ? 0 : 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  benefit.iconColor.withOpacity(0.1),
                  benefit.iconColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(benefit.icon, color: benefit.iconColor, size: 26.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    fontFamily: 'SF Pro Display',
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  benefit.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MODERN BUY BUTTON ====================

  Widget _buildModernBuyButton() {
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
            spreadRadius: -5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final total = controller.totalPrice;
              final quantity = controller.quantity.value;

              return Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($quantity ${quantity > 1 ? "years" : "year"})',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    Text(
                      'D ${total.toInt()}',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 12.h),

            GestureDetector(
              onTap: controller.buyPackage,
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1F2937), const Color(0xFF374151)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1F2937).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Subscribe Now',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                          letterSpacing: -0.3,
                        ),
                      ),
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
}
