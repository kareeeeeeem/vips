import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../design_system/atoms/app_colors.dart';
import 'package:vip/core/services/api_service.dart';
import '../views/transactions_extract_view.dart';
import '../views/widgets/filter.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class TransactionsExtractController extends GetxController {
  // Observables
  final RxString selectedFilter = 'All'.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;

  // Stats observables
  final RxDouble totalRewards = 0.0.obs;
  final RxDouble totalExtract = 0.0.obs;
  final RxDouble netBalance = 0.0.obs;

  // Date range
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    calculateStats();
  }

  // Charger les transactions
  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get(
        '/user/transactions',
        queryParams: {'limit': '50'},
      );
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['transactions'] ?? [];
        transactions.value =
            data.map((t) {
              return Transaction(
                id: t['reference'] ?? t['_id'].toString(),
                // Real enum (models/Transaction.js): credit/debit/gift_back/
                // reward/expense/income/transfer. Only checking for
                // 'expense' meant a 'debit' transaction — e.g. the sender's
                // side of a gift transfer (routes/user.js's /transfer) —
                // was shown as an incoming "+" Reward instead of an
                // outgoing "-" Extract, which also inflated Net Balance.
                type:
                    (t['type'] == 'expense' || t['type'] == 'debit')
                        ? TransactionType.extract
                        : TransactionType.reward,
                amount: ((t['amount'] ?? 0) as num).toDouble(),
                title: t['description'] ?? 'Transaction',
                time:
                    t['createdAt'] != null
                        ? '${DateTime.parse(t['createdAt']).hour}:${DateTime.parse(t['createdAt']).minute}'
                        : '',
                date:
                    t['createdAt'] != null
                        ? DateTime.parse(t['createdAt'])
                        : DateTime.now(),
                // Real enum (models/Transaction.js): pending/completed/
                // failed/cancelled. TransactionStatus.failed already
                // existed in this enum but was never reachable — a real
                // failed or cancelled transaction silently displayed as
                // "PENDING" (implying still-processing) instead of
                // "FAILED", both in the detail sheet and the shared
                // receipt text.
                status:
                    t['status'] == 'completed'
                        ? TransactionStatus.completed
                    : (t['status'] == 'failed' || t['status'] == 'cancelled')
                        ? TransactionStatus.failed
                        : TransactionStatus.pending,
              );
            }).toList();
        calculateStats();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  // Calculer les statistiques
  void calculateStats() {
    double rewards = 0;
    double extracts = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.reward) {
        rewards += transaction.amount;
      } else {
        extracts += transaction.amount;
      }
    }

    totalRewards.value = rewards;
    totalExtract.value = extracts;
    netBalance.value = rewards - extracts;
  }

  // Filtrer les transactions
  List<Transaction> get _typeFiltered {
    switch (selectedFilter.value) {
      case 'Rewards':
        return transactions.where((t) => t.type == TransactionType.reward).toList();
      // Matches the label the filter sheet actually sets
      // (widgets/filter.dart's "Extracts Only" option) — this used to say
      // 'Extract' (no "s"), so it never matched and silently fell through
      // to showing everything.
      case 'Extracts':
        return transactions.where((t) => t.type == TransactionType.extract).toList();
      case 'Pending':
        return transactions.where((t) => t.status == TransactionStatus.pending).toList();
      default:
        return transactions;
    }
  }

  List<Transaction> get todayTransactions {
    final today = DateTime.now();
    return _typeFiltered.where((t) {
      return t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day;
    }).toList();
  }

  List<Transaction> get yesterdayTransactions {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return _typeFiltered.where((t) {
      return t.date.year == yesterday.year &&
          t.date.month == yesterday.month &&
          t.date.day == yesterday.day;
    }).toList();
  }

  // Everything older than yesterday that still matches the type filter —
  // the view only had Today/Yesterday sections, silently dropping every
  // other transaction with no way to see it. Surfaced as "Earlier" below.
  //
  // Once openDatePicker() has been used, this narrows to just the picked
  // day instead of "everything before yesterday" — previously picking a
  // date only showed a toast claiming to filter and never touched the
  // actual list.
  final RxBool hasCustomDate = false.obs;

  List<Transaction> get earlierTransactions {
    if (hasCustomDate.value) {
      final picked = selectedDate.value;
      return _typeFiltered.where((t) {
        return t.date.year == picked.year &&
            t.date.month == picked.month &&
            t.date.day == picked.day;
      }).toList();
    }
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final cutoff = DateTime(yesterday.year, yesterday.month, yesterday.day);
    return _typeFiltered.where((t) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      return d.isBefore(cutoff);
    }).toList();
  }

  // Real active period label — this used to be a static 'Jan' RxString
  // with a selectMonth() setter no button anywhere ever called, so the
  // calendar-icon label at the top of the screen always said "Jan"
  // regardless of the actual date or the real date filter below it.
  String get currentPeriodLabel =>
      hasCustomDate.value ? _formatDate(selectedDate.value) : _formatDate(DateTime.now());

  // Ouvrir le sélecteur de date
  void openDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.AppPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.AppPrimaryColor,
                textStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.AppPrimaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              dayStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              headerHeadlineStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
              headerHelpStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              yearStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
      hasCustomDate.value = true;

      // Feedback visuel
      safeSnackbar(
        'Date Updated',
        'Showing transactions for ${_formatDate(picked)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.AppPrimaryColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
        icon: Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Ouvrir le filtre
  void openFilterSheet() {
    Get.bottomSheet(
      FilterBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Actions sur une transaction
  void showTransactionActions(Transaction transaction) {
    Get.bottomSheet(
      TransactionActionsSheet(transaction: transaction),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Télécharger l'extrait — shares a plain-text summary via the OS share sheet
  void downloadExtract() {
    if (transactions.isEmpty) {
      safeSnackbar('No Data', 'No transactions to export',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('VIPs Transaction Extract — $currentPeriodLabel');
    buffer.writeln('Total Rewards: ${totalRewards.value.toStringAsFixed(3)} TND');
    buffer.writeln('Net Balance:   ${netBalance.value.toStringAsFixed(3)} TND');
    buffer.writeln('─' * 40);
    for (final tx in transactions) {
      final sign = tx.type == TransactionType.reward ? '+' : '-';
      final dateStr = '${tx.date.day}/${tx.date.month}/${tx.date.year}';
      buffer.writeln('$sign${tx.amount.toStringAsFixed(3)} TND  ${tx.title}  $dateStr  ${tx.time}');
    }
    SharePlus.instance.share(ShareParams(
      text: buffer.toString(),
      subject: 'VIPs Transactions — $currentPeriodLabel',
    ));
  }

  // Partager une transaction individuelle
  void shareTransaction(Transaction transaction) {
    final sign = transaction.type == TransactionType.reward ? '+' : '-';
    final dateStr = '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';
    SharePlus.instance.share(ShareParams(
      text: 'VIPs Transaction\n'
          '$sign${transaction.amount.toStringAsFixed(3)} TND\n'
          '${transaction.title}\n'
          'Date: $dateStr  ${transaction.time}\n'
          'Status: ${transaction.status.name}\n'
          'Ref: #${transaction.id}',
      subject: 'VIPs Transaction #${transaction.id}',
    ));
  }

  // Télécharger le reçu d'une transaction individuelle
  void downloadReceipt(Transaction transaction) {
    final sign = transaction.type == TransactionType.reward ? '+' : '-';
    final dateStr = '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}';
    final buffer = StringBuffer();
    buffer.writeln('VIPs Transaction Receipt');
    buffer.writeln('─' * 40);
    buffer.writeln('${transaction.title}');
    buffer.writeln('Amount: $sign${transaction.amount.toStringAsFixed(3)} TND');
    buffer.writeln('Date:   $dateStr  ${transaction.time}');
    buffer.writeln('Status: ${transaction.status.name}');
    buffer.writeln('Ref:    #${transaction.id}');
    SharePlus.instance.share(ShareParams(
      text: buffer.toString(),
      subject: 'VIPs Receipt — #${transaction.id}',
    ));
  }

  // Voir les détails
  void viewDetails(Transaction transaction) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Transaction Details',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16.h),
            _detailRow('ID', '#${transaction.id}'),
            _detailRow('Title', transaction.title),
            _detailRow(
              'Amount',
              '${transaction.type == TransactionType.extract ? '-' : '+'}${transaction.amount.toStringAsFixed(2)} TND',
            ),
            _detailRow(
              'Date',
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
            ),
            _detailRow('Time', transaction.time),
            _detailRow('Status', transaction.status.name.toUpperCase()),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Modèle de transaction
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String title;
  final String time;
  final DateTime date;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.time,
    required this.date,
    required this.status,
  });
}

enum TransactionType { reward, extract }

enum TransactionStatus { completed, pending, failed }
