import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum TransactionType { vipsIn, vipsOut, other, reward }

double _num(dynamic v) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

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
  /// The merchant's real VIPs point balance (`User.walletPoints`, served as
  /// `points` by GET /merchant/wallet). This used to be assigned
  /// `dashboard.totalSales` — a *dinar* figure — and rendered under a VIPs
  /// coin as the headline point balance.
  final RxDouble walletPoints = 0.0.obs;

  /// Point movements the backend still has in `status: 'pending'`.
  /// Previously declared but never assigned, so the "N points pending" line
  /// could never say anything but "No pending points".
  final RxDouble pendingPoints = 0.0.obs;

  /// Currency already requested for payout and held, but not yet paid out.
  final RxDouble pendingPayout = 0.0.obs;

  // Summary Stats for the "Performance" style view
  final RxDouble totalVipsIn = 0.0.obs;
  final RxDouble totalVipsOut = 0.0.obs;

  /// Date range applied to the transaction list. Null = no bound. The wallet
  /// screen's range chip used to be the fixed literal "From: 11/26 To: 12/26"
  /// and filtered nothing.
  final Rxn<DateTime> fromDate = Rxn<DateTime>();
  final Rxn<DateTime> toDate = Rxn<DateTime>();

  final RxString selectedTab = 'Activity'.obs;
  // The 'Recovery' tab that used to sit here filtered on a TransactionType
  // that was just "anything not income/gift_back/reward", under a "VIPs
  // Recovery" label with no matching concept in the backend at all.
  final List<String> tabs = ['Activity', 'Vips In', 'Vips Out'];

  final RxList<TransactionItem> transactions = <TransactionItem>[].obs;
  final RxBool isLoading = true.obs;

  // Real spendable currency balance (GET /merchant/wallet's `balance`,
  // i.e. User.walletBalance) — separate from the VIPS points shown above,
  // and what a payout request actually draws down.
  final RxDouble availableBalance = 0.0.obs;
  final RxBool isRequestingPayout = false.obs;
  final RxList<Map<String, dynamic>> payouts = <Map<String, dynamic>>[].obs;

  /// Saved bank destinations, so a payout doesn't need the details retyped.
  final RxList<Map<String, dynamic>> payoutAccounts = <Map<String, dynamic>>[].obs;
  final RxBool isSavingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
    _loadBalance();
    _loadPayouts();
    loadPayoutAccounts();
  }

  Future<void> _loadBalance() async {
    try {
      final response = await ApiService().get('/merchant/wallet');
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        availableBalance.value = _num(d['balance']);
        walletPoints.value = _num(d['points']);
        pendingPoints.value = _num(d['pendingPoints']);
        pendingPayout.value = _num(d['pendingPayout']);
        totalVipsIn.value = _num(d['totalVipsIn']);
        totalVipsOut.value = _num(d['totalVipsOut']);
      }
    } catch (e) {
      debugPrint('merchant wallet balance failed: $e');
    }
  }

  Future<void> _loadPayouts() async {
    try {
      final response = await ApiService().get('/merchant/wallet/payouts');
      if (response.success && response.data is List) {
        payouts.value = (response.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      debugPrint('merchant payouts failed: $e');
    }
  }

  // ── Saved payout accounts (GET/POST/DELETE /merchant/wallet/payout-accounts) ──

  Future<void> loadPayoutAccounts() async {
    try {
      final response =
          await ApiService().get('/merchant/wallet/payout-accounts');
      if (response.success && response.data is List) {
        payoutAccounts.value = (response.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      debugPrint('payout accounts failed: $e');
    }
  }

  Future<bool> addPayoutAccount({
    required String bankName,
    required String accountName,
    required String accountNumber,
  }) async {
    isSavingAccount.value = true;
    try {
      final response = await ApiService().post(
        '/merchant/wallet/payout-accounts',
        {
          'bankName': bankName,
          'accountName': accountName,
          'accountNumber': accountNumber,
        },
      );
      if (response.success) {
        if (response.data is List) {
          payoutAccounts.value = (response.data as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        safeSnackbar('Saved', 'Payout account added',
            backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      safeSnackbar('Error', response.message);
      return false;
    } catch (e) {
      debugPrint('addPayoutAccount failed: $e');
      safeSnackbar('Error', 'Could not save that account. Please try again.');
      return false;
    } finally {
      isSavingAccount.value = false;
    }
  }

  Future<void> deletePayoutAccount(String id) async {
    try {
      final response =
          await ApiService().delete('/merchant/wallet/payout-accounts/$id');
      if (response.success) {
        if (response.data is List) {
          payoutAccounts.value = (response.data as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('deletePayoutAccount failed: $e');
      safeSnackbar('Error', 'Could not remove that account. Please try again.');
    }
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
        await refreshAll();
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      debugPrint('requestPayout failed: $e');
      safeSnackbar('Error', 'Could not request the payout. Please try again.');
    } finally {
      isRequestingPayout.value = false;
    }
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Real `Transaction.type` values that credit the merchant. Everything
  /// else on the enum (gift_back / expense / debit / transfer) is an outflow.
  static const _inTypes = {'income', 'reward', 'credit'};

  Future<void> _loadWalletData() async {
    isLoading.value = true;
    try {
      final query = <String, dynamic>{'limit': '50'};
      if (fromDate.value != null) {
        query['from'] = fromDate.value!.toIso8601String();
      }
      if (toDate.value != null) {
        // End of the picked day in the merchant's own timezone, so the range
        // covers the last day inclusively regardless of the server's offset.
        final end = DateTime(toDate.value!.year, toDate.value!.month,
            toDate.value!.day, 23, 59, 59, 999);
        query['to'] = end.toIso8601String();
      }
      final txRes =
          await ApiService().get('/merchant/transactions', queryParams: query);
      if (txRes.success && txRes.data is Map) {
        final list = (txRes.data as Map)['transactions'];
        transactions.value = list is List
            ? list.whereType<Map>().map((raw) {
                final e = Map<String, dynamic>.from(raw);
                final rawType = e['type']?.toString() ?? '';
                final type = rawType == 'income'
                    ? TransactionType.vipsIn
                    : rawType == 'gift_back'
                        ? TransactionType.vipsOut
                        : rawType == 'reward'
                            ? TransactionType.reward
                            : TransactionType.other;
                // tryParse — a malformed timestamp must not take down the
                // whole wallet screen.
                final date = DateTime.tryParse('${e['createdAt'] ?? ''}') ??
                    DateTime.now();
                final month = _months[date.month - 1];
                final amount = _num(e['amount']);
                return TransactionItem(
                  type: type,
                  displayId: (e['reference'] ?? e['_id'] ?? '')
                      .toString()
                      .replaceAll(RegExp(r'^[A-Z]+-'), ''),
                  location: rawType == 'income' ? 'Online' : 'On Store',
                  dateStr: '${date.day}\n$month',
                  subDetails: (e['description'] ?? '').toString(),
                  user: '',
                  // Sign from the full real enum, not just the three types
                  // this switch used to know about.
                  amount: _inTypes.contains(rawType) ? amount : -amount,
                  fullDateStr:
                      '${date.day} $month ${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  statusLabel: e['status']?.toString(),
                );
              }).toList()
            : <TransactionItem>[];
      }
    } catch (e) {
      debugPrint('merchant wallet transactions failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh / post-action reload for the whole screen.
  Future<void> refreshAll() async {
    await Future.wait([
      _loadWalletData(),
      _loadBalance(),
      _loadPayouts(),
      loadPayoutAccounts(),
    ]);
  }

  List<TransactionItem> get filteredTransactions {
    switch (selectedTab.value) {
      case 'Vips In':
        return transactions.where((t) => t.type == TransactionType.vipsIn || t.type == TransactionType.reward).toList();
      case 'Vips Out':
        return transactions.where((t) => t.type == TransactionType.vipsOut).toList();
      default:
        return transactions.toList();
    }
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    fromDate.value = from;
    toDate.value = to;
    await _loadWalletData();
  }

  Future<void> clearDateRange() => setDateRange(null, null);

  bool get hasDateFilter => fromDate.value != null || toDate.value != null;

  void toggleExpand(TransactionItem item) {
    item.isExpanded.value = !item.isExpanded.value;
  }
}
