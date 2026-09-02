import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

/// The merchant's guarantee and its three budgets (§5.1, §5.2).
///
/// The deposit is the merchant's own money, held to cover the points their
/// offers hand out. They decide the split; the platform only records what
/// arrived and what has been taken back out.
class MerchantGuaranteeController extends GetxController {
  final isLoading = false.obs;
  final isMutating = false.obs;
  final error = ''.obs;

  final depositedTnd = 0.0.obs;
  final refundedTnd = 0.0.obs;
  final unallocated = 0.obs;
  final discount = 0.obs;
  final packages = 0.obs;
  final general = 0.obs;
  final totalTnd = 0.0.obs;
  final suspended = false.obs;

  // §5.2
  final refundableTnd = 0.0.obs;
  final minimumTnd = 100.0.obs;
  final cycleDays = 60.obs;
  final reviewWorkingDays = 5.obs;
  final canRequestRefund = false.obs;
  final refundBlockers = <String>[].obs;

  final ledger = <Map<String, dynamic>>[].obs;

  // §5.1's two ways to put points behind offers: move back what customers
  // already spent here, or send money.
  final recoverablePoints = 0.obs;
  final pendingBankDeposits = <Map<String, dynamic>>[].obs;

  Future<void> loadTopupSources() async {
    try {
      final response = await ApiService().get('/merchant/guarantee/topup');
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        final rec = Map<String, dynamic>.from(d['recoverable'] as Map? ?? {});
        recoverablePoints.value = _int(rec['points']);
        pendingBankDeposits.value = ((d['pendingBankDeposits'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('topup sources failed: $e');
    }
  }

  /// Declares a bank transfer. Points appear once it is confirmed as
  /// received — this does not create them.
  Future<bool> declareBankTransfer(double amount,
      {String reference = '', String bankName = ''}) async {
    if (amount <= 0) {
      safeSnackbar('Amount missing', 'Enter how much you transferred.');
      return false;
    }
    isMutating.value = true;
    try {
      final response = await ApiService().post('/merchant/guarantee/topup/bank', {
        'amountTnd': amount,
        'reference': reference,
        'bankName': bankName,
      });
      if (response.success) {
        safeSnackbar('Sent', response.message,
            backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
        await loadTopupSources();
        return true;
      }
      safeSnackbar('Not sent', response.message);
      return false;
    } catch (e) {
      debugPrint('declareBankTransfer failed: $e');
      safeSnackbar('Error', 'Could not reach the server. Try again.');
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  static const budgets = ['discount', 'packages', 'general'];

  static String budgetLabel(String key) => switch (key) {
        'discount' => 'Discount',
        'packages' => 'Packages',
        'general' => 'General',
        _ => key,
      };

  /// What each budget pays for, said in the merchant's terms rather than the
  /// document's — they are choosing a split, not reading a specification.
  static String budgetBlurb(String key) => switch (key) {
        'discount' => 'Pays the points customers earn on their purchases',
        'packages' => 'Pays the difference on bundles you price below the total',
        'general' => 'Where voucher spending lands back',
        _ => '',
      };

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);
  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await ApiService().get('/merchant/guarantee');
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        depositedTnd.value = _num(d['depositedTnd']);
        refundedTnd.value = _num(d['refundedTnd']);
        unallocated.value = _int(d['unallocatedPoints']);
        totalTnd.value = _num(d['totalTnd']);
        suspended.value = d['suspended'] == true;

        final b = Map<String, dynamic>.from(d['budgets'] as Map? ?? {});
        discount.value = _int(b['discount']);
        packages.value = _int(b['packages']);
        general.value = _int(b['general']);

        if (d['refund'] is Map) {
          final r = Map<String, dynamic>.from(d['refund'] as Map);
          refundableTnd.value = _num(r['availableTnd']);
          minimumTnd.value = _num(r['minimumTnd']);
          cycleDays.value = _int(r['cycleDays']);
          reviewWorkingDays.value = _int(r['reviewWorkingDays']);
          canRequestRefund.value = r['canRequest'] == true;
          refundBlockers.value =
              (r['reasons'] as List?)?.map((e) => '$e').toList() ?? <String>[];
        }
      } else {
        error.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load your guarantee.';
      }
      await loadLedger();
      await loadTopupSources();
    } catch (e) {
      debugPrint('guarantee load failed: $e');
      error.value = 'Could not reach the server.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLedger() async {
    try {
      final response = await ApiService().get('/merchant/guarantee/ledger',
          queryParams: {'limit': '30'});
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);
        ledger.value = ((d['items'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('guarantee ledger failed: $e');
    }
  }

  int budgetValue(String key) => switch (key) {
        'discount' => discount.value,
        'packages' => packages.value,
        'general' => general.value,
        _ => 0,
      };

  Future<bool> allocate(String budget, int points) async {
    if (points <= 0) {
      safeSnackbar('Nothing to move', 'Enter how many points to put in this budget.');
      return false;
    }
    if (points > unallocated.value) {
      safeSnackbar('Not enough',
          'You have ${unallocated.value} points waiting to be split.');
      return false;
    }
    return _mutate('/merchant/guarantee/allocate',
        {'budget': budget, 'points': points}, 'Budget updated.');
  }

  Future<bool> reallocate(String from, String to, int points) async {
    if (from == to) {
      safeSnackbar('Pick two budgets', 'Choose a different budget to move points into.');
      return false;
    }
    if (points <= 0 || points > budgetValue(from)) {
      safeSnackbar('Not enough',
          '${budgetLabel(from)} holds ${budgetValue(from)} points.');
      return false;
    }
    return _mutate('/merchant/guarantee/reallocate',
        {'fromBudget': from, 'toBudget': to, 'points': points}, 'Points moved.');
  }

  Future<bool> requestRefund(double amount, {String note = ''}) async {
    if (amount < minimumTnd.value) {
      safeSnackbar('Below the minimum',
          'The smallest refund is ${minimumTnd.value.toStringAsFixed(0)} TND.');
      return false;
    }
    return _mutate('/merchant/guarantee/refund', {'amount': amount, 'note': note},
        'Requested. Reviewed within ${reviewWorkingDays.value} working days.');
  }

  Future<bool> _mutate(String path, Map<String, dynamic> body, String success) async {
    isMutating.value = true;
    try {
      final response = await ApiService().post(path, body);
      if (response.success) {
        safeSnackbar('Done', success,
            backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
        await load();
        return true;
      }
      safeSnackbar('Could not do that', response.message);
      return false;
    } catch (e) {
      debugPrint('guarantee mutate failed: $e');
      safeSnackbar('Error', 'Could not reach the server. Try again.');
      return false;
    } finally {
      isMutating.value = false;
    }
  }
}
