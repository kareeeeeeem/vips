import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import 'package:vip/core/services/api_service.dart';
import '../views/transactions_extract_view.dart';

class TransactionsExtractController extends GetxController {
  // Observables
  final RxString selectedMonth = 'Jan'.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;

  // Stats observables
  final RxDouble totalRewards = 1200.0.obs;
  final RxDouble totalExtract = 600.0.obs;
  final RxDouble netBalance = 600.0.obs;

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
      final response = await ApiService().get('/user/transactions?limit=50');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data['transactions'];
        transactions.value =
            data.map((t) {
              return Transaction(
                id: t['reference'] ?? t['_id'].toString(),
                type:
                    t['type'] == 'expense'
                        ? TransactionType.extract
                        : TransactionType.reward,
                amount: (t['amount'] as num).toDouble(),
                title: t['description'] ?? 'Transaction',
                time:
                    t['createdAt'] != null
                        ? '${DateTime.parse(t['createdAt']).hour}:${DateTime.parse(t['createdAt']).minute}'
                        : '',
                date:
                    t['createdAt'] != null
                        ? DateTime.parse(t['createdAt'])
                        : DateTime.now(),
                status:
                    t['status'] == 'completed'
                        ? TransactionStatus.completed
                        : TransactionStatus.pending,
              );
            }).toList();
        calculateStats();
      }
    } catch (e) {
      print('Error loading transactions: $e');
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
  List<Transaction> get todayTransactions {
    final today = DateTime.now();
    return transactions.where((t) {
      return t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day;
    }).toList();
  }

  List<Transaction> get yesterdayTransactions {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return transactions.where((t) {
      return t.date.year == yesterday.year &&
          t.date.month == yesterday.month &&
          t.date.day == yesterday.day;
    }).toList();
  }

  // Sélectionner un mois
  void selectMonth(String month) {
    selectedMonth.value = month;
    loadTransactions();
  }

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
            dialogBackgroundColor: Colors.white,
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
      loadTransactions();

      // Feedback visuel
      Get.snackbar(
        'Date Updated',
        'Showing transactions for ${_formatDate(picked)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.AppPrimaryColor.withOpacity(0.9),
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

  // Télécharger l'extrait
  void downloadExtract() {
    Get.snackbar(
      'Download',
      'Transaction extract is being prepared...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      icon: Icon(Icons.download, color: Colors.white),
    );
  }

  // Partager la transaction
  void shareTransaction(Transaction transaction) {
    Get.snackbar(
      'Share',
      'Sharing transaction #${transaction.id}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // Voir les détails
  void viewDetails(Transaction transaction) {
    Get.toNamed('/transaction-details', arguments: transaction);
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
