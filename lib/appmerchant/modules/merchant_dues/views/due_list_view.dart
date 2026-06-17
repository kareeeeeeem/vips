import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/merchant_dues_controller.dart';

class DueListView extends GetView<MerchantDuesController> {
  const DueListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Dues Management',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Summary Header
          _buildSummaryHeader(),
          
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Dues',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                      ),
                      const Icon(Icons.filter_list, color: Color(0xFF6B7280)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Obx(() => ListView.builder(
                      itemCount: controller.dues.length,
                      itemBuilder: (context, index) {
                        final due = controller.dues[index];
                        return _buildDueItem(due);
                      },
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          _buildStatBox('Receivable', controller.totalReceivable, const Color(0xFF10B981)),
          SizedBox(width: 16.w),
          _buildStatBox('Payable', controller.totalPayable, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, RxDouble amount, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Obx(() => Text(
              'D ${amount.value.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDueItem(DueItem due) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: due.isCustomer ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                child: Text(due.partyName[0], style: TextStyle(color: due.isCustomer ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(due.partyName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                    Text(due.phone, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: due.isCustomer ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  due.isCustomer ? 'Customer' : 'Supplier',
                  style: TextStyle(fontSize: 10.sp, color: due.isCustomer ? const Color(0xFF065F46) : const Color(0xFFDC2626), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining Due', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                  Text('D ${due.remainingAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: due.isCustomer ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0,
                ),
                child: Text(due.isCustomer ? 'Collect' : 'Pay Now', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: due.paidAmount / due.totalAmount,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(due.isCustomer ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
            minHeight: 4,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid: D ${due.paidAmount}', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
              Text('Total: D ${due.totalAmount}', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}
