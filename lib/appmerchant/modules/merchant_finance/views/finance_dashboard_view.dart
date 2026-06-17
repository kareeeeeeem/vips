import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_finance_controller.dart';

class FinanceDashboardView extends GetView<MerchantFinanceController> {
  const FinanceDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Finance & Accounting',
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
          // Stats Summary
          _buildSummaryCards(),
          
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('View All', style: TextStyle(color: const Color(0xFF10B981), fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: Obx(() => ListView.builder(
                      itemCount: controller.transactions.length,
                      itemBuilder: (context, index) {
                        final tx = controller.transactions[index];
                        return _buildTransactionItem(tx);
                      },
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(MerchantRoutes.ADD_TRANSACTION),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard('Total Income', controller.totalIncome, const Color(0xFFD1FAE5), const Color(0xFF059669), Icons.trending_up),
              SizedBox(width: 16.w),
              _buildStatCard('Total Expense', controller.totalExpense, const Color(0xFFFEE2E2), const Color(0xFFDC2626), Icons.trending_down),
            ],
          ),
          SizedBox(height: 16.h),
          _buildBalanceBar(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, RxDouble value, Color bg, Color text, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16.sp, color: text),
                SizedBox(width: 8.w),
                Text(title, style: TextStyle(fontSize: 11.sp, color: text, fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(() => Text(
              'D ${value.value.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: text),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
              SizedBox(height: 4.h),
              Obx(() => Text(
                'D ${(controller.cashBalance.value + controller.bankBalance.value).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.w900),
              )),
            ],
          ),
          IconButton(
            onPressed: () => Get.toNamed(MerchantRoutes.ACCOUNTS),
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(FinanceTransaction tx) {
    bool isIncome = tx.type == FinanceType.income;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                Text('${tx.category} • ${DateFormat('dd MMM').format(tx.date)}', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} D ${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp, 
                  fontWeight: FontWeight.w800, 
                  color: isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626)
                ),
              ),
              Text(tx.account, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}
