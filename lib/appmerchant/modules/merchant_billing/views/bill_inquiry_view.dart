import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class BillInquiryView extends StatelessWidget {
  const BillInquiryView({Key? key}) : super(key: key);

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
          'Bill Inquiry',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user, color: const Color(0xFFFFB800), size: 40.sp), // Dummy logo
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('VIPsApp VIPs Pt', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                              Text('VIPsApp Point Store City', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                      Icon(Icons.check_circle_outline, color: const Color(0xFFFFB800), size: 32.sp),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Info Grid
                  _buildInfoRow('VA-0307', '6 Oct 2021 | 04:15 PM'),
                  SizedBox(height: 12.h),
                  _buildInfoRow('ON 0001', 'Sale Valid'),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Bill Status', 'Pending', isHighlighted: true),
                  SizedBox(height: 12.h),
                  _buildInfoRow('Name/Card Details', 'John Doe / 010...'),
                  SizedBox(height: 32.h),

                  // Purchase Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Purchase Details', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
                      Text('Total Item (1)', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  
                  // Item
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4.r)),
                            child: Text('1', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(width: 8.w),
                          Text('iphone 13 mini', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF4B5563))),
                        ],
                      ),
                      Text('1050', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Summary
                  _buildSummaryRow('VIPs', '1050'),
                  SizedBox(height: 12.h),
                  _buildSummaryRow('Non VIPs', '1050'),
                  SizedBox(height: 16.h),
                  
                  // Subtotal (Highlighted row based on design)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SubTotal', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444))),
                        Text('2100', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444))),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  _buildSummaryRow('VIPs point', '-500', isDeduction: true),
                  SizedBox(height: 32.h),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                      Text('2099', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Buttons
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
                      onPressed: () => Get.toNamed(MerchantRoutes.BILL_PIN), // Move to PIN
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Proceed', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
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

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDeduction ? const Color(0xFF10B981) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
