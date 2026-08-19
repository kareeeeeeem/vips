import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum FinanceType { income, expense }

class FinanceTransaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final FinanceType type;
  final String account;

  FinanceTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.account,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['description'] ?? json['title'] ?? '',
      category: json['category'] ?? 'Other',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      type: json['type'] == 'income' || json['type'] == 'reward' || json['type'] == 'gift_back'
          ? FinanceType.income
          : FinanceType.expense,
      account: json['account'] ?? 'Cash',
    );
  }
}

class MerchantFinanceController extends GetxController {
  final transactions = <FinanceTransaction>[].obs;
  final isLoading = false.obs;

  // Stats
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final cashBalance = 0.0.obs;
  final bankBalance = 0.0.obs;

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
    loadFinanceData();
  }

  Future<void> loadFinanceData() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/merchant/finance');
      if (response.success && response.data != null) {
        final data = response.data;
        final List<dynamic> txList = data['transactions'] ?? [];
        transactions.value = txList.map((e) => FinanceTransaction.fromJson(e)).toList();
        totalIncome.value = (data['totalIncome'] ?? 0).toDouble();
        totalExpense.value = (data['totalExpense'] ?? 0).toDouble();
        cashBalance.value = (data['cashBalance'] ?? 0).toDouble();
        bankBalance.value = (data['bankBalance'] ?? 0).toDouble();
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to load finance data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction({
    required String title,
    required String category,
    required double amount,
    required FinanceType type,
    required String account,
  }) async {
    try {
      final response = await ApiService().post('/merchant/finance', {
        'title': title,
        'category': category,
        'amount': amount,
        'type': type == FinanceType.income ? 'income' : 'expense',
        'account': account,
      });

      if (response.success) {
        await loadFinanceData();
        Get.back();
        safeSnackbar('Success', 'Transaction added', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to add transaction: $e');
    }
  }
}
