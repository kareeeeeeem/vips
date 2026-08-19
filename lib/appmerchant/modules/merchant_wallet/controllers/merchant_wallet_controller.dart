import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum TransactionType { vipsIn, vipsOut, recovery, reward, credit }

class TransactionItem {
  final TransactionType type;
  final String displayId;
  final String location;
  final String dateStr;
  final String subDetails;
  final String user;
  final double amount;
  final String? transId;
  final String? transTypeDetails;
  final double? walletPointsTotal;
  final double? serviceCharge;
  final String? fullDateStr;
  final String? statusLabel;
  final RxBool isExpanded;

  TransactionItem({
    required this.type,
    required this.displayId,
    required this.location,
    required this.dateStr,
    required this.subDetails,
    required this.user,
    required this.amount,
    this.transId,
    this.transTypeDetails,
    this.walletPointsTotal,
    this.serviceCharge,
    this.fullDateStr,
    this.statusLabel,
    bool isExpanded = false,
  }) : isExpanded = isExpanded.obs;
}

class MerchantWalletController extends GetxController {
  final RxDouble walletPoints = 0.0.obs;
  final RxDouble pendingPoints = 0.0.obs;
  final RxDouble approvedPoints = 0.0.obs;
  final RxDouble suspendedPoints = 0.0.obs;
  final RxDouble dormantPoints = 0.0.obs;

  // New Summary Stats for the "Performance" style view
  final RxDouble totalVipsIn = 0.0.obs;
  final RxDouble totalVipsOut = 0.0.obs;
  final RxDouble totalVipsRecovery = 0.0.obs;

  final RxString selectedTab = 'Activity'.obs;
  final List<String> tabs = ['Activity', 'Vips In', 'Vips Out', 'Recovery'];

  final RxList<TransactionItem> transactions = <TransactionItem>[].obs;
  final RxBool isLoading = true.obs;

  // Real spendable currency balance (GET /merchant/wallet's `balance`,
  // i.e. User.walletBalance) — separate from the VIPS points shown above,
  // and what a payout request actually draws down.
  final RxDouble availableBalance = 0.0.obs;
  final RxBool isRequestingPayout = false.obs;
  final RxList<Map<String, dynamic>> payouts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
    _loadBalance();
    _loadPayouts();
  }

  Future<void> _loadBalance() async {
    try {
      final response = await ApiService().get('/merchant/wallet');
      if (response.success && response.data != null) {
        availableBalance.value = (response.data['balance'] ?? 0).toDouble();
      }
    } catch (_) {}
  }

  Future<void> _loadPayouts() async {
    try {
      final response = await ApiService().get('/merchant/wallet/payouts');
      if (response.success && response.data is List) {
        payouts.value = (response.data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
  }

  Future<void> requestPayout({
    required double amount,
    required String bankName,
    required String accountName,
    required String accountNumber,
  }) async {
    isRequestingPayout.value = true;
    try {
      final response = await ApiService().post('/merchant/wallet/payout', {
        'amount': amount,
        'bankName': bankName,
        'accountName': accountName,
        'accountNumber': accountNumber,
      });
      if (response.success) {
        safeSnackbar('Payout Requested', 'We\'ll process your request soon.',
            backgroundColor: Colors.green, colorText: Colors.white);
        await Future.wait([_loadBalance(), _loadPayouts()]);
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to request payout: $e');
    } finally {
      isRequestingPayout.value = false;
    }
  }

  Future<void> _loadWalletData() async {
    isLoading.value = true;
    try {
      final dashRes = await ApiService().get('/merchant/dashboard');
      if (dashRes.success && dashRes.data != null) {
        final d = dashRes.data;
        totalVipsIn.value = (d['totalRewards'] ?? 0).toDouble();
        totalVipsOut.value = (d['totalGiftBack'] ?? 0).toDouble();
        totalVipsRecovery.value = (d['netProfit'] ?? 0).toDouble();
        walletPoints.value = (d['totalSales'] ?? 0).toDouble();
      }

      final txRes = await ApiService().get('/merchant/transactions', queryParams: {'limit': '20'});
      if (txRes.success && txRes.data != null) {
        final List<dynamic> list = txRes.data['transactions'] ?? [];
        transactions.value = list.map((e) {
          final type = e['type'] == 'income'
              ? TransactionType.vipsIn
              : e['type'] == 'gift_back'
                  ? TransactionType.vipsOut
                  : e['type'] == 'reward'
                      ? TransactionType.reward
                      : TransactionType.recovery;
          final date = e['createdAt'] != null ? DateTime.parse(e['createdAt']) : DateTime.now();
          final month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][date.month - 1];
          return TransactionItem(
            type: type,
            displayId: (e['reference'] ?? e['_id'] ?? '').toString().replaceAll(RegExp(r'^[A-Z]+-'), ''),
            location: e['type'] == 'income' ? 'Online' : 'On Store',
            dateStr: '${date.day}\n$month',
            subDetails: e['description'] ?? '',
            user: '',
            amount: type == TransactionType.vipsIn || type == TransactionType.reward
                ? (e['amount'] ?? 0).toDouble()
                : -(e['amount'] ?? 0).toDouble(),
            fullDateStr: '${date.day} $month ${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
            statusLabel: e['status'],
          );
        }).toList();
      }
    } catch (e) {
      // Keep empty state on failure
    } finally {
      isLoading.value = false;
    }
  }

  List<TransactionItem> get filteredTransactions {
    switch (selectedTab.value) {
      case 'Vips In':
        return transactions.where((t) => t.type == TransactionType.vipsIn || t.type == TransactionType.reward).toList();
      case 'Vips Out':
        return transactions.where((t) => t.type == TransactionType.vipsOut).toList();
      case 'Recovery':
        return transactions.where((t) => t.type == TransactionType.recovery).toList();
      default:
        return transactions.toList();
    }
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  void toggleExpand(TransactionItem item) {
    item.isExpanded.value = !item.isExpanded.value;
  }
}
