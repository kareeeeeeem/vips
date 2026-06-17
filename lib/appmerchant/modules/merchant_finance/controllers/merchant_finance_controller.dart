import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FinanceType { income, expense }

class FinanceTransaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final FinanceType type;
  final String account; // 'Cash' or 'Bank'

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.account,
  });
}

class MerchantFinanceController extends GetxController {
  final transactions = <FinanceTransaction>[].obs;
  
  // Stats
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final cashBalance = 1500.0.obs;
  final bankBalance = 5400.0.obs;

  final categories = [
    'Sale',
    'Rent',
    'Salaries',
    'Utilities',
    'Supplies',
    'Marketing',
    'Other'
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    _calculateStats();
  }

  void _loadMockData() {
    transactions.assignAll([
      FinanceTransaction(
        id: '1',
        title: 'Monthly Rent',
        category: 'Rent',
        amount: 500.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: FinanceType.expense,
        account: 'Bank',
      ),
      FinanceTransaction(
        id: '2',
        title: 'Cash Sale - Item A',
        category: 'Sale',
        amount: 150.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: FinanceType.income,
        account: 'Cash',
      ),
      FinanceTransaction(
        id: '3',
        title: 'Electricity Bill',
        category: 'Utilities',
        amount: 80.0,
        date: DateTime.now(),
        type: FinanceType.expense,
        account: 'Cash',
      ),
    ]);
  }

  void _calculateStats() {
    double income = 0;
    double expense = 0;
    for (var tx in transactions) {
      if (tx.type == FinanceType.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    totalIncome.value = income;
    totalExpense.value = expense;
  }

  void addTransaction({
    required String title,
    required String category,
    required double amount,
    required FinanceType type,
    required String account,
  }) {
    final newTx = FinanceTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      amount: amount,
      date: DateTime.now(),
      type: type,
      account: account,
    );
    
    transactions.insert(0, newTx);
    
    if (type == FinanceType.income) {
      if (account == 'Cash') cashBalance.value += amount;
      else bankBalance.value += amount;
    } else {
      if (account == 'Cash') cashBalance.value -= amount;
      else bankBalance.value -= amount;
    }
    
    _calculateStats();
    Get.back();
  }
}
