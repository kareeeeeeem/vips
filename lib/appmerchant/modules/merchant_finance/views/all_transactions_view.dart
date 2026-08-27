import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/merchant_finance_controller.dart';

/// Full finance journal, filterable by type and account and paginated off
/// `GET /merchant/finance`. The dashboard's "View All" used to open the
/// Accounts screen (balances), which showed no transactions at all.
class AllTransactionsView extends StatefulWidget {
  const AllTransactionsView({super.key});

  @override
  State<AllTransactionsView> createState() => _AllTransactionsViewState();
}

class _AllTransactionsViewState extends State<AllTransactionsView> {
  final controller = Get.find<MerchantFinanceController>();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.loadAllTransactions();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'All Transactions',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAll.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.allTransactions.isEmpty) {
                return _buildEmpty();
              }
              return RefreshIndicator(
                onRefresh: () => controller.loadAllTransactions(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.allTransactions.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.allTransactions.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(
                            child: SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                      );
                    }
                    return _buildRow(controller.allTransactions[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              _chip('All', controller.filterType.value == null,
                  () => controller.applyFilters(clearType: true)),
              _chip('Income', controller.filterType.value == 'income',
                  () => controller.applyFilters(type: 'income')),
              _chip('Expense', controller.filterType.value == 'expense',
                  () => controller.applyFilters(type: 'expense')),
              Container(
                width: 1,
                height: 22.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: const Color(0xFFE5E7EB),
              ),
              _chip('All accounts', controller.filterAccount.value == null,
                  () => controller.applyFilters(clearAccount: true)),
              _chip('Cash', controller.filterAccount.value == 'Cash',
                  () => controller.applyFilters(account: 'Cash')),
              _chip('Bank', controller.filterAccount.value == 'Bank',
                  () => controller.applyFilters(account: 'Bank')),
            ],
          ),
        ));
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color:
                selected ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: () => controller.loadAllTransactions(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48.sp, color: const Color(0xFFD1D5DB)),
                SizedBox(height: 12.h),
                Text('No transactions match this filter',
                    style: TextStyle(
                        fontSize: 14.sp, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(FinanceTransaction tx) {
    final isIncome = tx.type == FinanceType.income;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
              color: isIncome
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color:
                  isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title.isEmpty ? tx.category : tx.title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937))),
                Text(
                    '${tx.category} • ${DateFormat('dd MMM yyyy').format(tx.date)}',
                    style: TextStyle(
                        fontSize: 11.sp, color: const Color(0xFF6B7280))),
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
                    color: isIncome
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626)),
              ),
              Text(tx.account,
                  style: TextStyle(
                      fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ],
      ),
    );
  }
}
