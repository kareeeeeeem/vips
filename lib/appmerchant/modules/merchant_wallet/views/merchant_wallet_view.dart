import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

import '../controllers/merchant_wallet_controller.dart';

class MerchantWalletView extends GetView<MerchantWalletController> {
  const MerchantWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF111827),
                size: 16.sp,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          'Wallet Points',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3EC465)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildHeaderSection(),
              SizedBox(height: 40.h), // Space for overlapping cards
              _buildActionCards(),
              SizedBox(height: 24.h),
              _buildAddCardButton(),
              SizedBox(height: 24.h),
              _buildFilterTabs(),
              SizedBox(height: 16.h),
              _buildDateAndResultRow(),
              SizedBox(height: 8.h),
              _buildTransactionList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.only(top: 24.h, bottom: 48.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF3AC264), // VIPs Green
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              Text(
                'My Wallet',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVipCoin(24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '112',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    ' 00',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '200 points expiring on 31/12/2025',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.help_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: 14.sp,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Point Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -40.h,
          left: 16.w,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerformanceItem('Vips In', controller.totalVipsIn.value, const Color(0xFF10B981)),
                _buildPerformanceDivider(),
                _buildPerformanceItem('Vips Out', controller.totalVipsOut.value, const Color(0xFFFF5252)),
                _buildPerformanceDivider(),
                _buildPerformanceItem('Recovery', controller.totalVipsRecovery.value, const Color(0xFF3B82F6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            _buildVipCoin(12.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              value.toInt().toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceDivider() {
    return Container(
      height: 30.h,
      width: 1,
      color: Colors.grey.shade200,
    );
  }


  Widget _buildActionCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(MerchantRoutes.MERCHANT_CREDIT_FORM),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0B2E), // Dark purple
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20.w,
                      bottom: -20.h,
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.white.withOpacity(0.1),
                          size: 40.sp,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Adjusted Points',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Credit Now',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF3AC264), // VIPs Green
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildVipCoin(16.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        '861',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '00',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Dormant Points',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Recovery Now',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB), // Blue
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            'Add New Card',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.tune,
              color: const Color(0xFF3AC264),
              size: 20.sp,
            ),
          ),
          ...controller.tabs.map((tab) => _buildTabItem(tab)).toList(),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == title;
      return GestureDetector(
        onTap: () => controller.selectTab(title),
        child: Container(
          margin: EdgeInsets.only(right: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3AC264) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDateAndResultRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  'From: 11/26   To: 12/26',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '21 Result Found',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.transactions.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _buildTransactionItem(controller.transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem item) {
    return Obx(() {
      Color amountColor = const Color(0xFFFF5252); // Red for negative
      String amountPrefix = '-';
      if (item.amount > 0) {
        amountColor = const Color(0xFFFF8C00); // Orange for positive
        amountPrefix = '+';
      }

      String titlePrefix = '';
      if (item.type == TransactionType.reward)
        titlePrefix = 'Reward ID: ';
      else if (item.type == TransactionType.credit)
        titlePrefix = 'Credit ID: ';
      else if (item.type == TransactionType.recovery)
        titlePrefix = 'Recovery ID: ';

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            // Top Section (Always visible)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: titlePrefix,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${item.displayId} | ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: item.location,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildVipCoin(12.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '$amountPrefix${item.amount.abs().toInt()}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                          Text(
                            item.amount.toString().split('.').length > 1
                                ? item.amount
                                    .toString()
                                    .split('.')[1]
                                    .padRight(2, '0')
                                    .substring(0, 2)
                                : '00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.dateStr.split('\n')[0],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              item.dateStr.split('\n')[1],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.subDetails,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (item.statusLabel != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD97706,
                                  ), // Yellow/Orange
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  item.statusLabel!,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    item.user,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => controller.toggleExpand(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded Section
            if (item.isExpanded.value && item.transId != null) ...[
              Divider(height: 1, color: Colors.grey.shade300),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    _buildDetailRow('Trans ID:', item.transId!),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Type:', item.transTypeDetails!),
                    SizedBox(height: 8.h),
                    _buildDetailRowWithCoin(
                      'Wallet Points',
                      item.walletPointsTotal!,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRowWithCoin(
                      'Service Charge',
                      item.serviceCharge!,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Date', item.fullDateStr!),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithCoin(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
        Row(
          children: [
            _buildVipCoin(12.sp, color: Colors.grey.shade500),
            SizedBox(width: 4.w),
            Text(
              amount.toInt().toString(),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '00',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget for the VIP Coin icon
  Widget _buildVipCoin(double size, {Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFFF8C00),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'v',
          style: TextStyle(
            color: color == null ? Colors.white : const Color(0xFF3AC264),
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
            fontFamily: 'sans-serif',
          ),
        ),
      ),
    );
  }
}
