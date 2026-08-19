import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_billing_controller.dart';

class BillInquiryView extends GetView<MerchantBillingController> {
  const BillInquiryView({super.key});

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }
        if (controller.bills.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64.sp, color: const Color(0xFFD1D5DB)),
                SizedBox(height: 16.h),
                Text('No bills yet', style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6B7280))),
              ],
            ),
          );
        }

        final bill = controller.bills.first;
        final items = List<Map<String, dynamic>>.from(bill['items'] ?? []);
        final createdAt = DateTime.tryParse(bill['createdAt']?.toString() ?? '');
        final dateTime = createdAt != null ? DateFormat('d MMM yyyy | hh:mm a').format(createdAt) : '';
        final billStatus = (bill['status'] ?? 'active').toString();
        final paymentMethod = (bill['paymentMethod'] ?? 'cash').toString();
        final paymentStatus = (bill['paymentStatus'] ?? 'paid').toString();
        final customerName = (bill['customerName'] ?? 'Walk-in Customer').toString();
        final customerPhone = (bill['customerPhone'] ?? '').toString();

        return Column(
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
                            Icon(Icons.verified_user, color: const Color(0xFFFFB800), size: 40.sp),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('VIPsApp', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                                Text(customerName, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.check_circle_outline, color: const Color(0xFFFFB800), size: 32.sp),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Info Grid
                    _buildInfoRow(bill['billNumber']?.toString() ?? 'N/A', dateTime),
                    SizedBox(height: 12.h),
                    _buildInfoRow(paymentMethod[0].toUpperCase() + paymentMethod.substring(1),
                        paymentStatus[0].toUpperCase() + paymentStatus.substring(1)),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Bill Status', billStatus[0].toUpperCase() + billStatus.substring(1), isHighlighted: true),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Name/Card Details', customerPhone.isNotEmpty ? '$customerName / $customerPhone' : customerName),
                    SizedBox(height: 32.h),

                    // Purchase Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Purchase Details', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
                        Text('Total Item (${items.length})', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Items
                    ...items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4.r)),
                                  child: Text('${item['quantity'] ?? 1}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(item['name']?.toString() ?? '', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF4B5563))),
                                ),
                              ],
                            ),
                          ),
                          Text('${item['total'] ?? item['price'] ?? 0}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                    SizedBox(height: 12.h),

                    // Summary
                    _buildSummaryRow('SubTotal', '${bill['subtotal'] ?? 0}'),
                    if ((bill['taxAmount'] ?? 0) != 0) ...[
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Tax', '${bill['taxAmount']}'),
                    ],
                    if ((bill['serviceCharge'] ?? 0) != 0) ...[
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Service Charge', '${bill['serviceCharge']}'),
                    ],
                    if ((bill['discountAmount'] ?? 0) != 0) ...[
                      SizedBox(height: 12.h),
                      _buildSummaryRow('Discount', '-${bill['discountAmount']}', isDeduction: true),
                    ],
                    SizedBox(height: 32.h),

                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                        Text('${bill['grandTotal'] ?? 0}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
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
        );
      }),
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
