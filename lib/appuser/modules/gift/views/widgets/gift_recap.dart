import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../../mobile/views/widgets/order_details.dart';

class GiftRecapController extends GetxController {
  // The gift was already sent for real (POST /rewards/send-gift succeeded)
  // by the time this screen is reached — these are the real recipient/amount
  // passed through from GiftController.proceed(), not placeholder data.
  late final String transferTo;
  late final double giftAmount;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    transferTo = (args['transferTo'] as String?) ?? '';
    giftAmount = (args['giftAmount'] as num?)?.toDouble() ?? 0.0;
  }

  // The transfer already completed on the previous screen — this is a
  // receipt, not a pending action, so there's nothing left to PIN-confirm.
  void proceed() {
    Get.to(
      () => OrderDetailsView(),
      arguments: {
        'orderType': 'Gift',
        'phone': transferTo,
        'paymentMethod': 'Wallet',
        'status': 'PAID',
        'items': [
          {'quantity': 1, 'name': 'Gift to $transferTo', 'price': giftAmount},
        ],
        'amount': giftAmount,
      },
    );
  }

  void cancel() {
    Get.back();
  }
}

class GiftRecapView extends GetView<GiftRecapController> {
  const GiftRecapView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GiftRecapController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: 50.h),
              Spacer(),
              _buildGiftCard(),
              SizedBox(height: 55.h),
              Spacer(),
              _buildActionButtons(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        SizedBox(width: 8.w),
        Text(
          'Gift Recap',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGiftCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          SizedBox(height: 8.h),
          _buildTransferInfo(),
          SizedBox(height: 11.h),
          _buildDivider(),
          SizedBox(height: 18.h),
          _buildGiftDetails(),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 61.w,
          height: 58.h,
          decoration: BoxDecoration(
            color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.card_giftcard,
            color: AppColors.AppPrimaryColor,
            size: 32.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTransferInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gift to',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          controller.transferTo,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2)),
    );
  }

  Widget _buildGiftDetails() {
    return Column(
      children: [
        _buildDetailRow('Gift Amount', controller.giftAmount),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: _buildDivider(),
        ),
        _buildTotalRow(),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value is double
              ? '${value.toStringAsFixed(0)} TND'
              : value.toString(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          '${controller.giftAmount.toStringAsFixed(0)} TND',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.AppPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: controller.proceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.AppPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'View Receipt',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 13.w),
        Expanded(
          child: SizedBox(
            height: 54.h,
            child: OutlinedButton(
              onPressed: controller.cancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.AppPrimaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.AppPrimaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
