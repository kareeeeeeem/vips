import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/merchant_routes.dart';
import '../controllers/merchant_finance_controller.dart';

class AccountsView extends GetView<MerchantFinanceController> {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Accounts',
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
      body: RefreshIndicator(
        onRefresh: controller.loadFinanceData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              _buildAccountCard('Cash In Hand', controller.cashBalance, const Color(0xFF10B981), Icons.payments_outlined),
              SizedBox(height: 16.h),
              _buildAccountCard('Bank Balance', controller.bankBalance, const Color(0xFF3B82F6), Icons.account_balance_outlined),

              SizedBox(height: 32.h),
              Row(
                children: [
                  const Icon(Icons.history, color: Color(0xFF6B7280)),
                  SizedBox(width: 8.w),
                  Text(
                    'Account Statements',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Real per-account in/out totals from GET /merchant/finance's
              // `accounts` array — these were hardcoded placeholder numbers
              // ("Total In: D 1200 | Out: D 400") shown to every merchant.
              Obx(() {
                if (controller.accounts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      'No account activity yet',
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                    ),
                  );
                }
                return Column(
                  children: controller.accounts
                      .map((a) => _buildStatementItem(a))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(String title, RxDouble balance, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, color: color, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Obx(() => Text(
                  'D ${balance.value.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1F2937)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The chevron on each row now leads somewhere: it opens the full journal
  /// pre-filtered to that account (it used to be purely decorative).
  Widget _buildStatementItem(FinanceAccount account) {
    return GestureDetector(
      onTap: () {
        controller.applyFilters(account: account.name, clearType: true);
        Get.toNamed(MerchantRoutes.ALL_TRANSACTIONS);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${account.name} Account',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                  SizedBox(height: 4.h),
                  Text(
                    'Total In: D ${account.moneyIn.toStringAsFixed(2)}  |  Out: D ${account.moneyOut.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${account.count} transaction${account.count == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}
