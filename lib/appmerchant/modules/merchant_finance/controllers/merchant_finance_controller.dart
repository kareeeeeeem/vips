import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum FinanceType { income, expense }

/// Transaction types the backend counts as money coming in.
/// Mirrors `INCOME_TYPES` in `routes/merchant.js` — keep the two in sync,
/// otherwise the per-row +/- sign disagrees with the totals above it.
const _incomeTypes = {'income', 'reward', 'gift_back', 'credit'};

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}') ?? 0;
}

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
      title: (json['description'] ?? json['title'] ?? '').toString(),
      category: (json['category'] ?? 'Other').toString(),
      amount: _toDouble(json['amount']),
      // tryParse, not parse — a malformed date must not take down the screen.
      date: DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      type: _incomeTypes.contains(json['type'])
          ? FinanceType.income
          : FinanceType.expense,
      account: (json['account'] ?? 'Cash').toString(),
    );
  }
}

/// Per-account statement figures, straight from `GET /merchant/finance`'s
/// `accounts` array (the Accounts screen used to hardcode these).
class FinanceAccount {
  final String name;
  final double moneyIn;
  final double moneyOut;
  final double balance;
  final int count;

  FinanceAccount({
    required this.name,
    required this.moneyIn,
    required this.moneyOut,
    required this.balance,
    required this.count,
  });

  factory FinanceAccount.fromJson(Map<String, dynamic> json) => FinanceAccount(
        name: (json['name'] ?? '').toString(),
        moneyIn: _toDouble(json['in']),
        moneyOut: _toDouble(json['out']),
        balance: _toDouble(json['balance']),
        count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
      );
}

class MerchantFinanceController extends GetxController {
  final transactions = <FinanceTransaction>[].obs;
  final isLoading = false.obs;

  // Stats
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final cashBalance = 0.0.obs;
  final bankBalance = 0.0.obs;
  final accounts = <FinanceAccount>[].obs;

  // ── Full journal (All Transactions screen) ──
  final allTransactions = <FinanceTransaction>[].obs;
  final isLoadingAll = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;
  final filterType = RxnString(); // null = all, 'income', 'expense'
  final filterAccount = RxnString(); // null = all, 'Cash', 'Bank'
  int _page = 1;
  static const _pageSize = 20;

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
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final txList = data['transactions'];
        transactions.value = txList is List
            ? txList
                .whereType<Map>()
                .map((e) =>
                    FinanceTransaction.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <FinanceTransaction>[];
        totalIncome.value = _toDouble(data['totalIncome']);
        totalExpense.value = _toDouble(data['totalExpense']);
        cashBalance.value = _toDouble(data['cashBalance']);
        bankBalance.value = _toDouble(data['bankBalance']);
        final accList = data['accounts'];
        accounts.value = accList is List
            ? accList
                .whereType<Map>()
                .map((e) => FinanceAccount.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <FinanceAccount>[];
      }
    } catch (e) {
      debugPrint('loadFinance failed: $e');
      safeSnackbar('Error', 'Could not load finance data. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Full journal, filterable + paginated ──

  Future<void> loadAllTransactions({bool reset = true}) async {
    if (reset) {
      _page = 1;
      isLoadingAll.value = true;
    } else {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    }
    try {
      final query = <String, dynamic>{'page': _page, 'limit': _pageSize};
      if (filterType.value != null) query['type'] = filterType.value;
      if (filterAccount.value != null) query['account'] = filterAccount.value;

      final response =
          await ApiService().get('/merchant/finance', queryParams: query);
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final txList = data['transactions'];
        final page = txList is List
            ? txList
                .whereType<Map>()
                .map((e) =>
                    FinanceTransaction.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <FinanceTransaction>[];
        if (reset) {
          allTransactions.value = page;
        } else {
          allTransactions.addAll(page);
        }
        final pagination = data['pagination'];
        final pages = (pagination is Map && pagination['pages'] is num)
            ? (pagination['pages'] as num).toInt()
            : 1;
        hasMore.value = _page < pages;
      }
    } catch (e) {
      debugPrint('loadAllTransactions failed: $e');
      safeSnackbar('Error', 'Could not load transactions. Please try again.');
    } finally {
      isLoadingAll.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasMore.value) return;
    _page++;
    await loadAllTransactions(reset: false);
  }

  /// `type` / `account` of null means "no filter on this axis".
  void applyFilters({String? type, String? account, bool clearType = false, bool clearAccount = false}) {
    if (clearType) {
      filterType.value = null;
    } else if (type != null) {
      filterType.value = type;
    }
    if (clearAccount) {
      filterAccount.value = null;
    } else if (account != null) {
      filterAccount.value = account;
    }
    loadAllTransactions();
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
        // Keep the All Transactions screen in sync if it has been opened.
        if (allTransactions.isNotEmpty) {
          await loadAllTransactions();
        }
        Get.back();
        safeSnackbar('Success', 'Transaction added', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('addTransaction failed: $e');
      safeSnackbar('Error', 'Could not save the transaction. Please try again.');
    }
  }
}
