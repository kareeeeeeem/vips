import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
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
  void loadTransactions() {
    isLoading.value = true;

    // Simuler le chargement des données
    Future.delayed(Duration(seconds: 1), () {
      transactions.value = [
        Transaction(
          id: '1259632555',
          type: TransactionType.reward,
          amount: 1650,
          title: 'Expense to Reward',
          time: '4:34 PM',
          date: DateTime.now(),
          status: TransactionStatus.completed,
        ),
        Transaction(
          id: '1259632556',
          type: TransactionType.extract,
          amount: 850,
          title: 'Extract to Wallet',
          time: '3:15 PM',
          date: DateTime.now(),
          status: TransactionStatus.completed,
        ),
        Transaction(
          id: '1259632557',
          type: TransactionType.reward,
          amount: 2100,
          title: 'Expense to Reward',
          time: '2:10 PM',
          date: DateTime.now().subtract(Duration(days: 1)),
          status: TransactionStatus.completed,
        ),
        Transaction(
          id: '1259632558',
          type: TransactionType.extract,
          amount: 1200,
          title: 'Extract to Bank',
          time: '11:45 AM',
          date: DateTime.now().subtract(Duration(days: 1)),
          status: TransactionStatus.pending,
        ),
      ];
      isLoading.value = false;
    });
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
