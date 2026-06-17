import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';
import '../../../routes/merchant_routes.dart';

class PlanMigrationView extends GetView<MerchantSubscriptionController> {
  const PlanMigrationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Business Plan',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                   Text(
                    'Shift to New Business Plan',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Comparison Row
                  Row(
                    children: [
                      Expanded(child: _buildComparisonCard('Commission Base Plan', '2.5%')),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.swap_horiz, color: const Color(0xFFEF4444), size: 32.sp),
                      ),
                      Expanded(child: _buildComparisonCard('Basic', 'D 99.00', subtitle: '120 days', isGreen: true)),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Meta Info Row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF3F4F6), width: 1), borderRadius: BorderRadius.circular(12.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMetaItem('Validity', '120 days'),
                        _buildMetaItem('Price', 'D 99.00'),
                        _buildMetaItem('Bill Status', 'Migrate', isBold: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Wallet Points entry
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wallet Points', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                              SizedBox(height: 4.h),
                              Obx(() => Text('VP ${controller.walletPoints.value}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)))),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Get.snackbar(
                            'Wallet applied',
                            'Wallet points selected for payment',
                            snackPosition: SnackPosition.BOTTOM,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: Text('Apply', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Payment Methods section
                  _buildPaymentMethodTile('Cash on Delivery', 'COD'),
                  SizedBox(height: 16.h),
                  _buildPaymentMethodTile('Pay Via Online', 'Online', icon: Icons.payment, subText: 'PayPal, Bkash'),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: const Color(0xFF10B981), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(
                        MerchantRoutes.BILL_PIN,
                        arguments: {
                          'nextSelection': MerchantRoutes.BILL_SCAN_ME,
                          'nextArgs': {
                            'buttonText': 'View Request',
                            'nextRoute': MerchantRoutes.INVOICE_RECEIPT,
                            'nextArgs': {
                              'headerTitle': 'REQUEST',
                              'transType': 'Upgrade Package',
                              'grandTotal': 'D 25.000',
                            },
                          },
                        },
                      ), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Shift Subscription Plan', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
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

  Widget _buildComparisonCard(String title, String price, {String? subtitle, bool isGreen = false}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFF10B981) : Colors.white,
        border: Border.all(color: isGreen ? const Color(0xFF10B981) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isGreen ? Colors.white : const Color(0xFF1F2937)),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isGreen ? Colors.white.withOpacity(0.2) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              price,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: isGreen ? Colors.white : const Color(0xFF1B6DF9)),
            ),
          ),
          if (subtitle != null) ...[
             SizedBox(height: 8.h),
             Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.white.withOpacity(0.8))),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF1F2937))),
      ],
    );
  }

  Widget _buildPaymentMethodTile(String title, String method, {IconData? icon, String? subText}) {
    return Obx(() => Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: controller.paymentMethod.value == method ? const Color(0xFF10B981) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                if (subText != null) ...[
                  SizedBox(height: 4.h),
                  Text(subText, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
                ],
              ],
            ),
          ),
          Radio<String>(
            value: method,
            groupValue: controller.paymentMethod.value,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) => controller.paymentMethod.value = val!,
          ),
        ],
      ),
    ));
  }
}
