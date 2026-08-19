import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../../../design_system/organisms/pin/pin.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import 'order_details.dart';

class BillInquiryController extends GetxController {
  final RxString pin = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController phoneNumberController = TextEditingController();

  String _userPin = '0000';

  // Real bill data — operator/amount come from the mobile top-up screen,
  // fees come from the /services/bills catalog (same endpoint pay_bills_controller uses).
  late final String transferTo;
  late final double billAmount;
  final RxDouble fees = 0.0.obs;
  final RxDouble vpToAwards = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    transferTo = (args['operator'] as String?) ?? '';
    billAmount = (args['amount'] as double?) ?? 0.0;
    phoneNumberController.text = (args['phoneNumber'] as String?) ?? '';
    // Mirrors the backend's 10% reward rate used in /rewards/expense-to-reward.
    vpToAwards.value = billAmount * 0.1;

    SharedPreferences.getInstance().then((prefs) {
      _userPin = prefs.getString('user_pin') ?? '0000';
    });
    _loadFees();
  }

  Future<void> _loadFees() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/services/bills');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        final match = data.firstWhere(
          (b) => (b['type'] ?? '').toString().toLowerCase() == 'mobile',
          orElse: () => null,
        );
        if (match != null) {
          fees.value = ((match['fee'] ?? 0) as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error fetching bill fee: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get totalVP => vpToAwards.value + fees.value;

  void updatePin(String newPin) {
    pin.value = newPin;
  }

  void proceed() {
    if (phoneNumberController.text.trim().isEmpty) {
      safeSnackbar('Required', 'Please enter the phone number to recharge', snackPosition: SnackPosition.BOTTOM);
      return;
    }

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
        onValidPin: () async {
          Get.back(); // close pin validator

          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          try {
            final response = await ApiService().post('/services/mobile-recharge', {
              'operator': transferTo,
              'amount': billAmount,
              'phoneNumber': phoneNumberController.text.trim(),
            });

            Get.back(); // close loading dialog

            if (response.success) {
              safeSnackbar('Success', response.message.isNotEmpty ? response.message : 'Recharge successful!',
                  snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
              Get.put(OrderDetailsController());
              Get.to(
                () => OrderDetailsView(),
                arguments: {
                  'orderType': 'Mobile Recharge',
                  'phone': phoneNumberController.text.trim(),
                  'paymentMethod': 'Wallet',
                  'status': 'PAID',
                  'items': [
                    {'quantity': 1, 'name': '$transferTo Recharge', 'price': billAmount},
                  ],
                  'amount': billAmount,
                  'serviceFee': fees.value,
                },
              );
            } else {
              safeSnackbar('Error', response.message.isNotEmpty ? response.message : 'Failed to complete recharge',
                  snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
            }
          } catch (e) {
            Get.back(); // close loading dialog
            safeSnackbar('Error', 'Failed to complete recharge: $e', snackPosition: SnackPosition.BOTTOM);
          } finally {
            isProcessing.value = false;
          }
        },
        supportedMethods: [ValidationMethod.pin, ValidationMethod.biometrics],
      ),
    );
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    super.onClose();
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
          SizedBox(height: 16.h),
          _buildPhoneNumberField(),
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

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: TextField(
            controller: controller.phoneNumberController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Enter phone number to recharge',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
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
    return Obx(
      () => Column(
        children: [
          _buildDetailRow('Fees', controller.fees.value),
          SizedBox(height: 12.h),
          _buildDetailRow('VP to Awards', controller.vpToAwards.value),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: _buildDivider(),
          ),
          _buildTotalRow(),
        ],
      ),
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
