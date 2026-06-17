import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../../../design_system/organisms/pin/pin.dart';
import '../../../mobile/views/widgets/order_details.dart';

class GiftRecapController extends GetxController {
  // Gift details
  final String transferTo = '#12355866'; // User ID of recipient
  final String offerId = '#123456';
  final bool isExpressDelivery = true;
  final double giftAmount = 2000.0;
  final double fees = 200.0;
  final double vpToAwards = 1000.0;

  double get totalVP => vpToAwards + fees;

  void proceed() {
    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor:
            Colors.orange, // Utilisez la couleur primaire de votre app
        validatePin: (pin) {
          return pin == '1234';
        },
        validateBiometrics: () async {
          final LocalAuthentication localAuth = LocalAuthentication();
          return await localAuth.authenticate(
            localizedReason: 'Authentifiez-vous',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );
        },
        onValidPin: () {
          Get.to(() => OrderDetailsView());
        },
        supportedMethods: [ValidationMethod.pin, ValidationMethod.biometrics],
      ),
    );
  }

  void cancel() {
    Get.back();
  }
}

class GiftRecapView extends GetView<GiftRecapController> {
  const GiftRecapView({Key? key}) : super(key: key);

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
            color: Colors.black.withOpacity(0.08),
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
          SizedBox(height: 16.h),
          _buildDeliveryType(),
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
            color: AppColors.AppPrimaryColor.withOpacity(0.1),
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
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
    );
  }

  Widget _buildGiftDetails() {
    return Column(
      children: [
        _buildDetailRow('Offer ID', controller.offerId),
        SizedBox(height: 12.h),
        _buildDetailRow('Gift Amount', controller.giftAmount),
        SizedBox(height: 12.h),
        _buildDetailRow('Fees', controller.fees),
        SizedBox(height: 12.h),
        _buildDetailRow('VP to Awards', controller.vpToAwards),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: _buildDivider(),
        ),
        _buildTotalRow(),
      ],
    );
  }

  Widget _buildDeliveryType() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD5C1), Color(0xFFFFE5D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.AppPrimaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Delivery Type',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            controller.isExpressDelivery ? 'Express' : 'Standard',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.AppPrimaryColor,
            ),
          ),
        ],
      ),
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
          'Total VP',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          '${controller.totalVP.toStringAsFixed(0)} VP',
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
                'Confirm Gift',
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
                'Cancel',
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
