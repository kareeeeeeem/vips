import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/mobile/views/widgets/transfer_details.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../../../design_system/organisms/pin/pin.dart';

class BillInquiryController extends GetxController {
  final RxString pin = ''.obs;
  final RxBool isProcessing = false.obs;

  String _userPin = '0000';

  // Bill data
  final String transferTo = '#12355866';
  final double billAmount = 2000.0;
  final double fees = 200.0;
  final double vpToAwards = 1000.0;

  @override
  void onInit() {
    super.onInit();
    SharedPreferences.getInstance().then((prefs) {
      _userPin = prefs.getString('user_pin') ?? '0000';
    });
  }

  double get totalVP => vpToAwards + fees;

  void updatePin(String newPin) {
    pin.value = newPin;
  }

  void proceed() {
    isProcessing.value = true;

    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor:
            Colors.orange, // Utilisez la couleur primaire de votre app
        validatePin: (pin) {
          return pin == _userPin;
        },
        validateBiometrics: () async {
          final LocalAuthentication localAuth = LocalAuthentication();
          try {
            return await localAuth.authenticate(
              localizedReason: 'Authentifiez-vous',
              options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: true,
              ),
            );
          } catch (_) {
            return false;
          }
        },
        onValidPin: () {
          Get.to(() => CardDetailsView());
        },
        supportedMethods: [ValidationMethod.pin, ValidationMethod.biometrics],
      ),
    );
  }

  void cancel() {
    Get.back();
  }
}

class BillInquiryView extends GetView<BillInquiryController> {
  const BillInquiryView({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildBillCard(),
              SizedBox(height: 55.h),
              //              _buildPinSection(),
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
          'Bill Inquiry',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBillCard() {
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
          _buildBillAmount(),
          SizedBox(height: 16.h),
          _buildBillDetails(),
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
            Icons.receipt_long,
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
          'Transfer to',
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

  Widget _buildBillAmount() {
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
          color: AppColors.AppPrimaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bill Amount',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '${controller.billAmount.toStringAsFixed(0)} TND',
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

  Widget _buildBillDetails() {
    return Column(
      children: [
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

  Widget _buildDetailRow(String label, double value) {
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
          '${value.toStringAsFixed(0)} VP',
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
        SizedBox(width: 13.w),
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
                'Proceed',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget pour le clavier numérique (optionnel)
class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;

  const NumericKeyboard({super.key,
    required this.onKeyPressed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map((key) => _buildKey(key)).toList(),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map((key) => _buildKey(key)).toList(),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map((key) => _buildKey(key)).toList(),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 60.w),
              _buildKey('0'),
              _buildDeleteKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () => onKeyPressed(key),
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            key,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        width: 60.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.black87,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
