import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_credit_controller.dart';

class MerchantCreditInquiryView extends GetView<MerchantCreditController> {
  const MerchantCreditInquiryView({super.key});

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
                                'Credit Inquiry',
                                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                                child: Text('PENDING', style: TextStyle(color: const Color(0xFFF97316), fontSize: 10.sp, fontWeight: FontWeight.bold)),
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

                  // Who this credit is for
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Customer', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
                            Obx(() => controller.selectedCustomerId.value != null
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, size: 14.sp, color: const Color(0xFF10B981)),
                                      SizedBox(width: 4.w),
                                      Text('Existing customer', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
                                    ],
                                  )
                                : const SizedBox.shrink()),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Search box — looks up real customers who've
                        // transacted with this merchant before via
                        // GET /merchant/customers?search=
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search existing customer by name or phone',
                            isDense: true,
                            prefixIcon: Icon(Icons.search, size: 18.sp, color: const Color(0xFF9CA3AF)),
                          ),
                          onChanged: controller.searchCustomers,
                        ),
                        Obx(() {
                          if (controller.isSearching.value) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          if (controller.searchResults.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: EdgeInsets.only(top: 8.h),
                            constraints: BoxConstraints(maxHeight: 180.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: controller.searchResults.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                              itemBuilder: (context, index) {
                                final c = controller.searchResults[index];
                                return ListTile(
                                  dense: true,
                                  title: Text((c['fullName'] ?? 'Unknown').toString(), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                  subtitle: Text((c['phone'] ?? '').toString(), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                                  onTap: () => controller.selectCustomer(c),
                                );
                              },
                            ),
                          );
                        }),
                        SizedBox(height: 12.h),
                        Text('Or enter manually', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: controller.customerNameCtrl,
                          decoration: const InputDecoration(hintText: 'Customer name', isDense: true),
                          onChanged: (_) => controller.clearSelectedCustomer(),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: controller.customerPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: 'Customer phone', isDense: true),
                          onChanged: (_) => controller.clearSelectedCustomer(),
                        ),
                      ],
                    ),
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
                        _buildDetailRow('Payment Method', 'Bank'),
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
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                            Text('Credit Amount', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                            Obx(() => Text('D ${controller.amount.value}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Totals
                  Obx(() {
                    final amt = double.tryParse(controller.amount.value) ?? 0;
                    final serviceCharge = amt * controller.serviceChargeRate;
                    final total = amt + serviceCharge;
                    final amtStr = 'D ${amt.toStringAsFixed(3)}';
                    final scStr = 'D ${serviceCharge.toStringAsFixed(3)}';
                    final totalStr = 'D ${total.toStringAsFixed(3)}';
                    return Column(
                      children: [
                        _buildAmountRow('Credit Amount', amtStr),
                        _buildAmountRow('Addon Cost', 'D 0.000'),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20.r)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                              Text(amtStr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildAmountRow('Service Charge', scStr),
                        _buildAmountRow('Vat/Tax', 'D 0.000'),
                        SizedBox(height: 32.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand Total', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937))),
                            Text(totalStr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937))),
                          ],
                        ),
                      ],
                    );
                  }),
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
                    onPressed: () => controller.confirmCredit(),
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
