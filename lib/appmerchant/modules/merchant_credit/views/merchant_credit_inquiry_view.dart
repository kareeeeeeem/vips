import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_credit_controller.dart';

class MerchantCreditInquiryView extends GetView<MerchantCreditController> {
  const MerchantCreditInquiryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Credit',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bill Inquiry',
                                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                                    child: Text('PAID', style: TextStyle(color: const Color(0xFFF97316), fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text('Cash On Delivery', style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Center(
                            child: Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
                              child: Icon(Icons.check, color: Colors.white, size: 32.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Agent Info
                  Row(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.person, color: const Color(0xFF9CA3AF), size: 32.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Agent Ali', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                            Text('House: 80, Road: 00, Test City', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                            Text('01/Jun/2025: 10:47', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                            Text('Phone: 71******', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Detail Rows
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Trans Type', 'Credit'),
                        const Divider(color: Color(0xFFF3F4F6)),
                        _buildDetailRow('Customer Name', 'Jamil Test'),
                        _buildDetailRow('Phone', '959190000'),
                        _buildDetailRow('Trans Address', 'House: 80, Road: 00, Test City'),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Product Card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF10B981)),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Center(child: Icon(Icons.add, color: const Color(0xFF10B981), size: 20.sp)),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pack Go Up', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                            Text('D 100.000', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF10B981))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Totals
                  _buildAmountRow('Credit Amount', 'D 100.000'),
                  _buildAmountRow('Addon Cost', 'D 0.000'),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(color: const Color(0xFFF97316).withOpacity(0.15), borderRadius: BorderRadius.circular(20.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                        Text('D 100.000', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildAmountRow('Service Charge', 'D 0.000'),
                  _buildAmountRow('Vat/Tax', 'D 10.000'),
                  SizedBox(height: 32.h),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Grand Total', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937))),
                      Text('D 110.000', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937))),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      side: const BorderSide(color: Color(0xFFF97316)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Cancel', style: TextStyle(color: const Color(0xFFF97316), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563), fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
        ],
      ),
    );
  }
}
