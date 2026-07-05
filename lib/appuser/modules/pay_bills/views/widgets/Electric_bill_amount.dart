import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../../../design_system/organisms/pin/pin.dart';
import '../../../mobile/views/widgets/order_details.dart';

class ElectricBillAmountController extends GetxController {
  final TextEditingController amountController = TextEditingController();
  final RxBool isLoading = false.obs;

  final String operatorName = 'Tunisia Electric Company';
  final String operatorIcon =
      'https://cdn-icons-png.flaticon.com/512/1792/1792931.png';

  // Bill details
  final String billStatus = 'Unpaid';
  final String billingNumber = '80152473300816';
  final String dueDate = '10-08-2024';
  final double serviceFee = 0.500;

  void proceed() {
    if (amountController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      return;
    }

    Get.to(
      () => PinValidator(
        pinLength: 4,
        primaryColor: Colors.orange,
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
        onValidPin: () async {
          Get.back(); // close pin validator

          // Show loading dialog
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          try {
            final response = await ApiService().post('/services/pay-bill', {
              'billServiceId':
                  'electric_company_id_123', // should be dynamic, placeholder for now
              'amount': amount + serviceFee,
              'referenceNumber': billingNumber,
            });

            Get.back(); // close loading dialog

            if (response.success) {
              Get.snackbar(
                'Success',
                'Bill paid successfully!',
                snackPosition: SnackPosition.BOTTOM,
              );
              Get.to(
                () => const OrderDetailsView(),
                arguments: {
                  'amount': amount,
                  'serviceFee': serviceFee,
                  'billNumber': billingNumber,
                  'operator': operatorName,
                },
              );
            } else {
              Get.snackbar(
                'Error',
                response.message,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } catch (e) {
            Get.back(); // close loading dialog
            Get.snackbar(
              'Error',
              'Failed to pay bill: $e',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        supportedMethods: const [
          ValidationMethod.pin,
          ValidationMethod.biometrics,
        ],
      ),
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}

class ElectricBillAmountView extends GetView<ElectricBillAmountController> {
  const ElectricBillAmountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ElectricBillAmountController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    _buildOperatorSection(),
                    SizedBox(height: 30.h),
                    _buildBillDetails(),
                    SizedBox(height: 40.h),
                    _buildAmountSection(),
                  ],
                ),
              ),
            ),
            _buildProceedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 12.w),
          Text(
            'Electric Bill',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operator',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Image.network(
                  controller.operatorIcon,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.flash_on,
                      color: Colors.grey.shade600,
                      size: 24.sp,
                    );
                  },
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay to',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      controller.operatorName,
                      style: TextStyle(
                        fontSize: 15.sp,
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

  Widget _buildBillDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Details',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              _buildDetailRow('Status', controller.billStatus),
              SizedBox(height: 12.h),
              Divider(height: 1, color: Colors.grey.shade300),
              SizedBox(height: 12.h),
              _buildDetailRow('Billing Number', controller.billingNumber),
              SizedBox(height: 12.h),
              Divider(height: 1, color: Colors.grey.shade300),
              SizedBox(height: 12.h),
              _buildDetailRow('Due Date', controller.dueDate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Bill Amount',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Text(
                'TND',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Service Fee: ${controller.serviceFee.toStringAsFixed(3)} TND',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Obx(() {
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
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child:
                controller.isLoading.value
                    ? SizedBox(
                      width: 22.w,
                      height: 22.h,
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
      }),
    );
  }
}
