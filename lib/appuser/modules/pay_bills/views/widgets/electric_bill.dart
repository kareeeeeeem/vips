import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../../design_system/atoms/app_colors.dart';
import 'Electric_bill_amount.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ElectricBillController extends GetxController {
  final TextEditingController subscriberNumberController =
      TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  final RxBool isLoading = false.obs;

  late final String billServiceId;
  late final String operatorName;
  late final String operatorIcon;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    billServiceId = args['billServiceId']?.toString() ?? '';
    operatorName = args['title']?.toString() ?? 'Bill Payment';
    operatorIcon =
        args['logo']?.toString().isNotEmpty == true
            ? args['logo'].toString()
            : 'https://cdn-icons-png.flaticon.com/512/1792/1792931.png';
  }

  Future<void> proceed() async {
    if (subscriberNumberController.text.isEmpty) {
      safeSnackbar(
        'Required',
        'Please enter your subscriber number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (accountNumberController.text.isEmpty) {
      safeSnackbar(
        'Required',
        'Please enter your account number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService().post('/services/bill-inquiry', {
        'billServiceId': billServiceId,
        'subscriberNumber': subscriberNumberController.text.trim(),
        'accountNumber': accountNumberController.text.trim(),
      });

      if (response.success && response.data != null) {
        Get.to(
          () => ElectricBillAmountView(),
          arguments: {
            'billServiceId': billServiceId,
            'subscriberNumber': subscriberNumberController.text.trim(),
            'accountNumber': accountNumberController.text.trim(),
            'operator': operatorName,
            'dueDate': response.data['dueDate'] ?? '',
            'amountDue': response.data['amountDue']?.toString() ?? '',
            'billStatus': response.data['status'] ?? 'Unpaid',
          },
        );
      } else {
        safeSnackbar(
          'Error',
          response.message.isNotEmpty
              ? response.message
              : 'Could not fetch bill details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        'Failed to look up bill: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    subscriberNumberController.dispose();
    accountNumberController.dispose();
    super.onClose();
  }
}

class ElectricBillView extends GetView<ElectricBillController> {
  const ElectricBillView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ElectricBillController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 35.h),
              _buildOperatorSection(),
              SizedBox(height: 30.h),
              _buildSubscriberNumberField(),
              SizedBox(height: 30.h),
              _buildAccountNumberField(),
              Spacer(),
              _buildProceedButton(),
              SizedBox(height: 10.h),
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
          controller.operatorName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operator',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.AppPrimaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Image.network(
                  controller.operatorIcon,
                  fit: BoxFit.contain,
                  color: AppColors.AppPrimaryColor,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.flash_on,
                      color: AppColors.AppPrimaryColor,
                      size: 24.sp,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          size: 14.sp,
                          color: AppColors.AppPrimaryColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Pay to',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.AppPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.operatorName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriberNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscriber Number',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.subscriberNumberController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter subscriber number',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Number',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller.accountNumberController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter account number',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.confirmation_number_outlined,
                color: Colors.grey.shade400,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 54.h,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.proceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.AppPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
            disabledBackgroundColor: AppColors.AppPrimaryColor.withValues(
              alpha: 0.6,
            ),
          ),
          child:
              controller.isLoading.value
                  ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                  : Text(
                    'Proceed',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
        ),
      );
    });
  }
}
