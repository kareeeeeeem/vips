import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import '../controllers/merchant_dues_controller.dart';

class DueListView extends GetView<MerchantDuesController> {
  const DueListView({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = 'All'.obs; // All | Customer | Supplier

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)),
            onPressed: () => _showAddDueDialog(context),
          ),
        ],
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
                      Obx(() => Text(
                        filter.value == 'All' ? 'All Dues' : '${filter.value}s',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                      )),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.filter_list, color: Color(0xFF6B7280)),
                        onSelected: (v) => filter.value = v,
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'All', child: Text('All')),
                          PopupMenuItem(value: 'Customer', child: Text('Customers (receivable)')),
                          PopupMenuItem(value: 'Supplier', child: Text('Suppliers (payable)')),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Obx(() {
                      final dues = filter.value == 'All'
                          ? controller.dues
                          : controller.dues
                              .where((d) => d.isCustomer == (filter.value == 'Customer'))
                              .toList();

                      if (controller.dues.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 56.sp, color: Colors.grey.shade300),
                              SizedBox(height: 16.h),
                              Text('No dues recorded',
                                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8.h),
                              Text('Tap the + button to record a due',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
                            ],
                          ),
                        );
                      }
                      if (dues.isEmpty) {
                        return Center(
                          child: Text('No ${filter.value.toLowerCase()} dues',
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                        );
                      }
                      return ListView.builder(
                        itemCount: dues.length,
                        itemBuilder: (context, index) {
                          final due = dues[index];
                          return _buildDueItem(due);
                        },
                      );
                    }),
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
    return Obx(() => Container(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          _buildStatBox('Receivable', controller.totalReceivable, const Color(0xFF10B981)),
          SizedBox(width: 16.w),
          _buildStatBox('Payable', controller.totalPayable, const Color(0xFFEF4444)),
        ],
      ),
    ));
  }

  Widget _buildStatBox(String label, RxDouble amount, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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

  void _showCollectDialog(DueItem due) {
    final amountCtrl = TextEditingController(
        text: due.remainingAmount.toStringAsFixed(2));
    Get.dialog(AlertDialog(
      title: Text(due.isCustomer ? 'Collect payment' : 'Record payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${due.partyName} — D ${due.remainingAmount.toStringAsFixed(3)} outstanding',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(amountCtrl.text.trim());
            if (amount == null) {
              safeSnackbar('Error', 'Enter a valid amount',
                  snackPosition: SnackPosition.BOTTOM);
              return;
            }
            Get.back();
            controller.collectPayment(due.id, amount);
          },
          child: const Text('Confirm'),
        ),
      ],
    ));
  }

  void _showAddDueDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final isCustomer = true.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record a Due'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Party Name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Total Amount'), keyboardType: TextInputType.number),
              SizedBox(height: 8.h),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Customer owes me'),
                      value: true,
                      groupValue: isCustomer.value,
                      onChanged: (v) => isCustomer.value = v!,
                    ),
                  ),
                ],
              )),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('I owe a supplier'),
                      value: false,
                      groupValue: isCustomer.value,
                      onChanged: (v) => isCustomer.value = v!,
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (nameController.text.isNotEmpty && amount != null && amount > 0) {
                controller.addDue({
                  'partyName': nameController.text,
                  'phone': phoneController.text,
                  'totalAmount': amount,
                  'paidAmount': 0,
                  'isCustomer': isCustomer.value,
                });
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
      amountController.dispose();
    });
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
                backgroundColor: due.isCustomer ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEF4444).withValues(alpha: 0.1),
                child: Text(due.partyName.isNotEmpty ? due.partyName[0].toUpperCase() : '?', style: TextStyle(color: due.isCustomer ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
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
                // This used to settle the whole remaining balance instantly
                // with no confirmation and no way to record a part-payment —
                // which is the normal case for a running tab.
                onPressed: due.remainingAmount <= 0
                    ? null
                    : () => _showCollectDialog(due),
                style: ElevatedButton.styleFrom(
                  backgroundColor: due.isCustomer ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  elevation: 0,
                ),
                child: Text(
                  due.remainingAmount <= 0
                      ? 'Settled'
                      : (due.isCustomer ? 'Collect' : 'Pay Now'),
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: due.totalAmount > 0 ? due.paidAmount / due.totalAmount : 0.0,
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
