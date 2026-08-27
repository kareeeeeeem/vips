import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vip/appuser/core/util/images.dart';
import 'package:vip/appuser/modules/profile/views/widgets/redeem_page.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class WalletPointsController extends GetxController {
  final selectedTab = 'Redeem History'.obs;
  final selectedFilter = 'Activity'.obs;

  // Date range management - extended to 90 days to include all test data
  final fromDate = DateTime.now().subtract(const Duration(days: 90)).obs;
  final toDate = DateTime.now().obs;

  // Track which transactions are expanded
  final RxList<bool> expandedTransactions = <bool>[].obs;
  final isLoading = false.obs;
  final _api = ApiService();

  // Live transaction data — populated from /user/transactions API
  final allTransactions = <Map<String, dynamic>>[].obs;

  // Live wallet points total — populated from /user/wallet API
  final walletPoints = 0.obs;

  // Live diamond stats — populated from /auth/me (User model fields
  // pendingDiamonds/suspendedDiamonds; "Approved" is the wallet points
  // balance itself, i.e. diamonds that already cleared).
  final pendingDiamonds = 0.obs;
  final suspendedDiamonds = 0.obs;

  List<Map<String, dynamic>> get filteredTransactions {
    var filtered =
        allTransactions.where((transaction) {
          // Filter by date range
          final transactionDate = transaction['dateTime'] as DateTime;
          if (transactionDate.isBefore(fromDate.value) ||
              transactionDate.isAfter(
                toDate.value.add(const Duration(days: 1)),
              )) {
            return false;
          }

          // Filter by category based on selected filter
          if (selectedFilter.value == 'Activity') {
            return true; // Show all
          } else if (selectedFilter.value == 'On Upgrade') {
            return transaction['category'] == 'on_upgrade';
          } else if (selectedFilter.value == 'Upgrade') {
            return transaction['category'] == 'upgrade';
          } else if (selectedFilter.value == 'On Redeem') {
            return transaction['category'] == 'on_redeem';
          } else if (selectedFilter.value == 'Redeem') {
            return transaction['category'] == 'redeem';
          }
          return true;
        }).toList();

    return filtered;
  }

  int get resultCount => filteredTransactions.length;

  int get pendingCount {
    return filteredTransactions.where((t) => t['status'] == 'pending').length;
  }

  int get doneCount {
    return filteredTransactions.where((t) => t['status'] == 'done').length;
  }

  @override
  void onInit() {
    super.onInit();
    expandedTransactions.value = List.generate(allTransactions.length, (_) => false);
    fetchTransactions();
    fetchWalletBalance();
    fetchDiamondStats();
  }

  Future<void> fetchWalletBalance() async {
    try {
      final response = await _api.get('/user/wallet');
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        walletPoints.value = (data['points'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      debugPrint('fetchWalletBalance error: $e');
    }
  }

  Future<void> fetchDiamondStats() async {
    try {
      final response = await _api.get('/auth/me');
      if (response.success && response.data is Map) {
        final raw = response.data['user'] ?? response.data;
        final user = raw is Map ? raw : <String, dynamic>{};
        pendingDiamonds.value = (user['pendingDiamonds'] as num?)?.toInt() ?? 0;
        suspendedDiamonds.value = (user['suspendedDiamonds'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      debugPrint('fetchDiamondStats error: $e');
    }
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/user/transactions', queryParams: {'limit': '50'});
      if (response.success && response.data != null) {
        final raw = response.data as Map<String, dynamic>;
        final list = (raw['transactions'] as List?) ?? [];
        final mapped = list.map<Map<String, dynamic>>((tx) {
          final createdAt = DateTime.tryParse(tx['createdAt']?.toString() ?? '') ?? DateTime.now();
          final type = (tx['type'] as String?) ?? 'credit';
          final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
          // Real Transaction.type enum: credit/debit/gift_back/reward/
          // expense/income/transfer — matches the same outgoing-vs-incoming
          // split already fixed in transactions_extract_controller.dart
          // and vips_club_history_view.dart (only expense/debit are
          // outgoing; 'redeem' isn't a real backend value at all).
          final isDebit = type == 'expense' || type == 'debit';
          final merchant = (tx['merchantId'] as Map<String, dynamic>?);
          final location = merchant?['storeName'] ?? merchant?['fullName'] ?? 'VIPs';
          return {
            'type': type,
            'isCredit': !isDebit,
            'category': _categoryForType(type),
            'status': (tx['status'] as String?) == 'completed' ? 'done' : (tx['status'] ?? 'pending'),
            'title': (tx['description'] as String?) ?? _titleForType(type),
            'points': isDebit ? '-${amount.toStringAsFixed(0)}' : '+${amount.toStringAsFixed(0)}',
            'date': DateFormat('dd MMM yyyy').format(createdAt),
            'time': DateFormat('HH:mm').format(createdAt),
            'orderId': (tx['reference'] as String?) ?? tx['_id']?.toString() ?? '',
            'expenseType': _titleForType(type),
            'location': location,
            'dateTime': createdAt,
          };
        }).toList();

        if (mapped.isNotEmpty) {
          allTransactions.assignAll(mapped);
          expandedTransactions.value = List.generate(mapped.length, (_) => false);
        }
      }
    } catch (e) {
      debugPrint('fetchTransactions error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _categoryForType(String type) {
    switch (type) {
      case 'credit':
      case 'reward':
      case 'income':
        return 'upgrade';
      case 'expense':
      case 'debit':
        return 'redeem';
      case 'transfer':
        return 'on_upgrade';
      case 'gift_back':
        return 'on_redeem';
      default:
        return 'upgrade';
    }
  }

  String _titleForType(String type) {
    switch (type) {
      case 'credit':    return 'Credit';
      case 'reward':    return 'Reward earned';
      case 'income':    return 'Income';
      case 'expense':   return 'Expense';
      case 'debit':     return 'Debit';
      case 'transfer':  return 'Transfer';
      case 'gift_back': return 'Gift Back';
      default:          return 'Transaction';
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void toggleTransaction(int index) {
    expandedTransactions[index] = !expandedTransactions[index];
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  Future<void> selectDateRange() async {
    final picked = await Get.dialog<DateTimeRange>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Date Range',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              CalendarDatePicker(
                initialDate: fromDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateChanged: (date) {
                  fromDate.value = date;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(
                          result: DateTimeRange(
                            start: fromDate.value,
                            end: toDate.value,
                          ),
                        );
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
    }
  }
}

class WalletPointsView extends StatelessWidget {
  final Color primaryColor;
  final controller = Get.put(WalletPointsController());

  WalletPointsView({super.key, this.primaryColor = const Color(0xFFFF9B7A)});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black87,
                size: 20.sp,
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          'Wallet Points',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ==================== SCROLLABLE HEADER CONTENT ====================
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // My Points Card avec stats qui dépassent
                  _buildPointsCardWithStats(),

                  SizedBox(height: 50.h),

                  // Credit & Redeem Cards
                  _buildActionCards(),

                  SizedBox(height: 24.h),

                  // Add New Card
                  _buildAddCard(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),

            // ==================== STICKY FILTER HEADER ====================
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                child: Obx(
                  () => Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterButtons(),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => controller.selectDateRange(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'From: ${controller.formatDate(controller.fromDate.value)}  To: ${controller.formatDate(controller.toDate.value)}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${controller.resultCount} Result Found',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================== TRANSACTION LIST ====================
            Obx(() {
              final transactions = controller.filteredTransactions;

              // Si aucune transaction, afficher l'état vide
              if (transactions.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == transactions.length) {
                    return SizedBox(height: 20.h);
                  }
                  final transaction = transactions[index];
                  return _buildTransactionItem(transaction, index);
                }, childCount: transactions.length + 1),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ==================== FILTER BUTTONS ====================
  Widget _buildFilterButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: [
              Container(
                width: 35.w,
                height: 35.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    final filters = ['Activity', 'On Upgrade', 'Upgrade', 'On Redeem', 'Redeem'];
                    final current = controller.selectedFilter.value;
                    final next = filters[(filters.indexOf(current) + 1) % filters.length];
                    controller.selectedFilter.value = next;
                  },
                  icon: Icon(
                    Icons.sort_rounded,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 8.w),
              _buildFilterButton('Activity'),
              SizedBox(width: 8.w),
              _buildFilterButton('On Upgrade'),
              SizedBox(width: 8.w),
              _buildFilterButton('Upgrade'),
              SizedBox(width: 8.w),
              _buildFilterButton('On Redeem'),
              SizedBox(width: 8.w),
              _buildFilterButton('Redeem'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = controller.selectedFilter.value == label;

    return GestureDetector(
      onTap: () => controller.changeFilter(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          border:
              !isSelected
                  ? Border.all(color: Colors.grey.shade300, width: 1)
                  : null,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // ==================== POINTS CARD ====================
  Widget _buildPointsCardWithStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Points Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 24.w,
              bottom: 60.h, // Extra space for stats cards
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'My Points',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),

                // Points Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        Images.logo,
                        height: 25,
                        width: 25,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Obx(() => Text(
                      controller.walletPoints.value.toString(),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    )),
                  ],
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),

          // Stats Row - Positioned half inside, half outside
          Positioned(
            left: 0,
            right: 0,
            bottom: -30.h, // Half outside
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Obx(
                () => Row(
                  children: [
                    _buildStatCard(controller.pendingDiamonds.value.toString(), 'Pending', Colors.white),
                    SizedBox(width: 8.w),
                    _buildStatCard(controller.walletPoints.value.toString(), 'Approved', Colors.white),
                    SizedBox(width: 8.w),
                    _buildStatCard(controller.suspendedDiamonds.value.toString(), 'Suspended', Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color textColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACTION CARDS ====================
  Widget _buildActionCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Credit Now Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.toNamed('/packages');
              },
              child: Container(
                height: 160.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D1B69), Color(0xFF1A0E3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Platinum',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              AutoSizeText(
                                'Upgrade Now',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Redeem Now Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(() => RedeemView());
              },
              child: Container(
                height: 160.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor.withValues(alpha: 0.9), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VIPs Club',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              AutoSizeText(
                                'Redeem Now',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  // ==================== ADD CARD ====================
  Widget _buildAddCard() {
    return InkWell(
      onTap: () {
        // No real payment processor wired yet — same honest state used in
        // the Credit / Buy VIPS Credits screen's add-card sheet.
        safeSnackbar(
          'Coming Soon',
          'Adding payment cards will be available in a future update',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              'Add New Card',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TRANSACTION ITEM ====================
  Widget _buildTransactionItem(Map<String, dynamic> transaction, int index) {
    final isExpanded = controller.expandedTransactions[index];
    final isCredit = transaction['isCredit'] == true;

    return GestureDetector(
      onTap: () => controller.toggleTransaction(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color:
                        isCredit ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green : Colors.orange,
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                // Transaction Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transaction['title'],
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            transaction['points'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: isCredit ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${transaction['date']} • ${transaction['time']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Expanded Details
            if (isExpanded) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Order ID', transaction['orderId']),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Type', transaction['expenseType']),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Location', transaction['location']),
                    SizedBox(height: 8.h),
                    _buildDetailRow('Status', transaction['status']),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64.sp,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Transactions Found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'You don\'t have any transactions in this category.\nTry changing the filter or date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              controller.changeFilter('Activity');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'View All Transactions',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== STICKY FILTER DELEGATE ====================
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 110.h;
  @override
  double get maxExtent => 110.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: 110.h, child: child);
  }

  @override
  bool shouldRebuild(_StickyFilterDelegate oldDelegate) {
    return false;
  }
}
