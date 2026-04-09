import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TransactionListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Color primaryColor;
  final RxList<bool> expandedStates;
  final Function(int) onToggle;

  const TransactionListWidget({
    Key? key,
    required this.transactions,
    required this.expandedStates,
    required this.onToggle,
    this.primaryColor = const Color(0xFFFF9B7A),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                'No transactions found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        // Find the original index in allTransactions for expansion state
        return _buildTransactionCard(transaction, index);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    final isCredit = transaction['type'] == 'credit';
    final isPending = transaction['status'] == 'pending';

    return GestureDetector(
      onTap: () => onToggle(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                // Order ID and Status
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Order ID : ${transaction['orderId']}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          transaction['location'] ?? 'In Store',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Text(
                  'D ${transaction['points']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.bookmark_border, color: primaryColor, size: 20.sp),
              ],
            ),

            SizedBox(height: 12.h),

            // Date, Info, and Status
            Row(
              children: [
                // Date Container
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        transaction['date'].split(' ')[0], // Day
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        transaction['date'].split(' ')[1], // Month
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense Type ${transaction['expenseType']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.store, color: primaryColor, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            transaction['location'] ?? 'Pizza Hub',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge (if applicable)
                if (isPending)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            // Expandable Details Section
            Obx(() {
              final isExpanded = expandedStates[index];
              return AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    SizedBox(height: 12.h),
                    Divider(color: Colors.grey.shade300, height: 1),
                    SizedBox(height: 12.h),

                    // Transaction Details
                    Column(
                      children: [
                        _buildDetailRow('Trans ID:', transaction['orderId']),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          'My Points',
                          'Vpt 12580',
                          valueColor: Colors.green,
                        ),
                        SizedBox(height: 8.h),
                        _buildDetailRow('Service Charge', 'Vpt 100'),
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          'Date',
                          '${transaction['date']}  ${transaction['time']}',
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // View Invoice Button
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle view invoice
                          print('View invoice: ${transaction['orderId']}');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View Invoice',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                crossFadeState:
                    isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
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
            fontSize: 13.sp,
            color: valueColor ?? Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
