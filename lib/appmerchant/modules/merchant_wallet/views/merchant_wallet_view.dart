import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

import '../controllers/merchant_wallet_controller.dart';

class MerchantWalletView extends GetView<MerchantWalletController> {
  const MerchantWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF111827),
                size: 16.sp,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          'Wallet Points',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              tooltip: 'Refresh',
              icon: Icon(Icons.refresh, size: 22.sp, color: const Color(0xFF111827)),
              onPressed: controller.refreshAll,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3EC465)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildHeaderSection(),
              SizedBox(height: 40.h), // Space for overlapping cards
              _buildActionCards(),
              SizedBox(height: 24.h),
              _buildPayoutSection(),
              SizedBox(height: 24.h),
              _buildPayoutAccountsSection(),
              SizedBox(height: 24.h),
              _buildPayoutRequestsSection(),
              SizedBox(height: 24.h),
              _buildFilterTabs(),
              SizedBox(height: 16.h),
              _buildDateAndResultRow(),
              SizedBox(height: 8.h),
              _buildTransactionList(),
            ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.only(top: 24.h, bottom: 48.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF3AC264), // VIPs Green
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              Text(
                'My Wallet',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVipCoin(24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    controller.walletPoints.value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.w, top: 18.h),
                    child: Text(
                      'PTS',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.pendingPoints.value > 0
                        ? '${controller.pendingPoints.value.toInt()} points pending'
                        : 'No pending points',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.help_outline,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 14.sp,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Point Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -40.h,
          left: 16.w,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerformanceItem('Vips In', controller.totalVipsIn.value, const Color(0xFF10B981)),
                _buildPerformanceDivider(),
                _buildPerformanceItem('Vips Out', controller.totalVipsOut.value, const Color(0xFFFF5252)),
                _buildPerformanceDivider(),
                _buildPerformanceItem('Pending', controller.pendingPayout.value, const Color(0xFF3B82F6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            _buildVipCoin(12.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              value.toInt().toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceDivider() {
    return Container(
      height: 30.h,
      width: 1,
      color: Colors.grey.shade200,
    );
  }


  Widget _buildActionCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(MerchantRoutes.MERCHANT_CREDIT_FORM),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0B2E), // Dark purple
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20.w,
                      bottom: -20.h,
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.white.withValues(alpha: 0.1),
                          size: 40.sp,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'Adjusted Points',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Credit Now',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(MerchantRoutes.GIFT_BACK_FORM),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF3AC264), // VIPs Green
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildVipCoin(16.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          controller.totalVipsOut.value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Points Gifted',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Gift Back Now',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Balance', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                        'D ${controller.availableBalance.value.toStringAsFixed(3)}',
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
                      )),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showPayoutDialog(),
              icon: Icon(Icons.account_balance_outlined, size: 18.sp),
              label: const Text('Request Payout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AC264),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayoutDialog() {
    final amountCtrl = TextEditingController();
    // Prefill from the saved default payout account — the merchant used to
    // have to retype full bank details on every single request.
    final accounts = controller.payoutAccounts;
    final Map<String, dynamic>? preset = accounts.isEmpty
        ? null
        : accounts.firstWhere((a) => a['isDefault'] == true,
            orElse: () => accounts.first);
    final bankCtrl =
        TextEditingController(text: (preset?['bankName'] ?? '').toString());
    final accountNameCtrl =
        TextEditingController(text: (preset?['accountName'] ?? '').toString());
    final accountNumberCtrl =
        TextEditingController(text: (preset?['accountNumber'] ?? '').toString());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request Payout', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                Obx(() => Text(
                      'Available: D ${controller.availableBalance.value.toStringAsFixed(3)}',
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                    )),
                SizedBox(height: 16.h),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: bankCtrl,
                  decoration: InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: accountNameCtrl,
                  decoration: InputDecoration(labelText: 'Account Holder Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: accountNumberCtrl,
                  decoration: InputDecoration(labelText: 'Account / IBAN Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isRequestingPayout.value
                            ? null
                            : () {
                                final amount = double.tryParse(amountCtrl.text) ?? 0;
                                if (amount <= 0 || accountNameCtrl.text.trim().isEmpty || accountNumberCtrl.text.trim().isEmpty) {
                                  safeSnackbar('Incomplete', 'Please fill in amount and account details', snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                Get.back();
                                controller.requestPayout(
                                  amount: amount,
                                  bankName: bankCtrl.text.trim(),
                                  accountName: accountNameCtrl.text.trim(),
                                  accountNumber: accountNumberCtrl.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3AC264)),
                        child: controller.isRequestingPayout.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Submit Request', style: TextStyle(color: Colors.white)),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Payout requests and where each one stands. The list was already being
  /// fetched (GET /merchant/wallet/payouts) but never rendered anywhere, so a
  /// merchant could ask for their money and then had no way to see whether
  /// the request was still pending, approved, paid or rejected.
  Widget _buildPayoutRequestsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payout Requests',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),
            Obx(() {
              final requests = controller.payouts;
              if (requests.isEmpty) {
                return Text(
                  'No payout requests yet.',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                );
              }
              return Column(
                children: requests.map((p) {
                  final status = (p['status'] ?? 'pending').toString();
                  final amount = (p['amount'] as num?) ?? 0;
                  final bank = (p['bankName'] ?? '').toString();
                  final created = DateTime.tryParse(p['createdAt']?.toString() ?? '');
                  final note = (p['note'] ?? '').toString();
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'D ${amount.toStringAsFixed(3)}',
                                style: TextStyle(
                                    fontSize: 14.sp, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                [
                                  if (bank.isNotEmpty) bank,
                                  if (created != null)
                                    '${created.day.toString().padLeft(2, '0')}/'
                                        '${created.month.toString().padLeft(2, '0')}/'
                                        '${created.year}',
                                ].join(' · '),
                                style: TextStyle(
                                    fontSize: 11.sp, color: const Color(0xFF6B7280)),
                              ),
                              if (status == 'rejected' && note.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  note,
                                  style: TextStyle(
                                      fontSize: 11.sp, color: const Color(0xFFEF4444)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _payoutStatusChip(status),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Covers Payout.status's full enum: pending | approved | rejected | paid.
  Widget _payoutStatusChip(String status) {
    final color = switch (status) {
      'paid' => const Color(0xFF10B981),
      'approved' => const Color(0xFF3B82F6),
      'rejected' => const Color(0xFFEF4444),
      _ => const Color(0xFFF59E0B),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10.sp, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  /// Saved bank destinations for payouts. This slot used to be a single
  /// "Add New Card" row that only ever showed a "Coming soon" toast — card
  /// storage needs a PCI-scoped vault that doesn't exist here. What the
  /// payout flow actually needs is a saved *bank* destination, which is real
  /// and is what this now manages
  /// (GET/POST/DELETE /merchant/wallet/payout-accounts).
  Widget _buildPayoutAccountsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout Accounts',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827)),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.payoutAccounts.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  'No saved account yet. Add one so payouts don\'t need the details retyped.',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                ),
              );
            }
            return Column(
              children: controller.payoutAccounts.map((account) {
                final id = (account['_id'] ?? '').toString();
                final number = (account['accountNumber'] ?? '').toString();
                final masked = number.length > 4
                    ? '•••• ${number.substring(number.length - 4)}'
                    : number;
                final isDefault = account['isDefault'] == true;
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_outlined,
                          size: 20.sp, color: const Color(0xFF2563EB)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    (account['accountName'] ?? '').toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1F2937)),
                                  ),
                                ),
                                if (isDefault) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text('Default',
                                        style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF059669))),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              [
                                (account['bankName'] ?? '').toString(),
                                masked,
                              ].where((e) => e.isNotEmpty).join('  •  '),
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 20.sp, color: const Color(0xFFDC2626)),
                        onPressed: id.isEmpty
                            ? null
                            : () => controller.deletePayoutAccount(id),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          GestureDetector(
            onTap: () => _showAddPayoutAccountDialog(),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Add Payout Account',
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPayoutAccountDialog() {
    final bankCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Payout Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankCtrl,
                decoration: const InputDecoration(labelText: 'Bank name (optional)'),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Account holder name'),
              ),
              TextField(
                controller: numberCtrl,
                decoration: const InputDecoration(labelText: 'Account number / RIB'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: controller.isSavingAccount.value
                    ? null
                    : () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            numberCtrl.text.trim().isEmpty) {
                          safeSnackbar('Error',
                              'Account holder name and number are required',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        final ok = await controller.addPayoutAccount(
                          bankName: bankCtrl.text.trim(),
                          accountName: nameCtrl.text.trim(),
                          accountNumber: numberCtrl.text.trim(),
                        );
                        if (ok) Get.back();
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3AC264)),
                child: controller.isSavingAccount.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save', style: TextStyle(color: Colors.white)),
              )),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickDateRange(),
            child: Container(
              padding: EdgeInsets.all(8.w),
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.tune,
                color: const Color(0xFF3AC264),
                size: 20.sp,
              ),
            ),
          ),
          ...controller.tabs.map((tab) => _buildTabItem(tab)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    return Obx(() {
      final isSelected = controller.selectedTab.value == title;
      return GestureDetector(
        onTap: () => controller.selectTab(title),
        child: Container(
          margin: EdgeInsets.only(right: 12.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3AC264) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          controller.fromDate.value != null && controller.toDate.value != null
              ? DateTimeRange(
                  start: controller.fromDate.value!,
                  end: controller.toDate.value!)
              : null,
    );
    if (picked != null) {
      await controller.setDateRange(picked.start, picked.end);
    }
  }

  Widget _buildDateAndResultRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final from = controller.fromDate.value;
            final to = controller.toDate.value;
            String fmt(DateTime d) =>
                '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year % 100}';
            final label = controller.hasDateFilter
                ? 'From: ${from != null ? fmt(from) : '—'}   To: ${to != null ? fmt(to) : '—'}'
                : 'All dates';
            return GestureDetector(
              onTap: () => _pickDateRange(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (controller.hasDateFilter) ...[
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: controller.clearDateRange,
                        child: Icon(Icons.close,
                            size: 14.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          Obx(() => Text(
            '${controller.filteredTransactions.length} Result Found',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          )),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      final items = controller.filteredTransactions;
      if (items.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 48.sp, color: Colors.grey.shade400),
                SizedBox(height: 12.h),
                Text('No transactions found',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) => _buildTransactionItem(items[index]),
        ),
      );
    });
  }

  Widget _buildTransactionItem(TransactionItem item) {
    return Obx(() {
      Color amountColor = const Color(0xFFFF5252); // Red for negative
      String amountPrefix = '-';
      if (item.amount > 0) {
        amountColor = const Color(0xFFFF8C00); // Orange for positive
        amountPrefix = '+';
      }

      String titlePrefix = '';
      if (item.type == TransactionType.reward) {
        titlePrefix = 'Reward ID: ';
      } else if (item.type == TransactionType.other) {
        titlePrefix = 'Trans ID: ';
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            // Top Section (Always visible)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: titlePrefix,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${item.displayId} | ',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: item.location,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildVipCoin(12.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '$amountPrefix${item.amount.abs().toInt()}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                          Text(
                            item.amount.toString().split('.').length > 1
                                ? item.amount
                                    .toString()
                                    .split('.')[1]
                                    .padRight(2, '0')
                                    .substring(0, 2)
                                : '00',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.dateStr.split('\n')[0],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              item.dateStr.split('\n')[1],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.subDetails,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (item.statusLabel != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFD97706,
                                  ), // Yellow/Orange
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  item.statusLabel!,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    item.user,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => controller.toggleExpand(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expanded Section
            if (item.isExpanded.value && item.transId != null) ...[
              Divider(height: 1, color: Colors.grey.shade300),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    _buildDetailRow('Trans ID:', item.transId ?? ''),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Type:', item.transTypeDetails ?? ''),
                    SizedBox(height: 8.h),
                    _buildDetailRowWithCoin(
                      'Wallet Points',
                      item.walletPointsTotal ?? 0,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRowWithCoin(
                      'Service Charge',
                      item.serviceCharge ?? 0,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Date', item.fullDateStr ?? ''),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithCoin(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
        Row(
          children: [
            _buildVipCoin(12.sp, color: Colors.grey.shade500),
            SizedBox(width: 4.w),
            Text(
              amount.toInt().toString(),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '00',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper widget for the VIP Coin icon
  Widget _buildVipCoin(double size, {Color? color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFFF8C00),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'v',
          style: TextStyle(
            color: color == null ? Colors.white : const Color(0xFF3AC264),
            fontSize: size * 0.7,
            fontWeight: FontWeight.bold,
            fontFamily: 'sans-serif',
          ),
        ),
      ),
    );
  }
}
