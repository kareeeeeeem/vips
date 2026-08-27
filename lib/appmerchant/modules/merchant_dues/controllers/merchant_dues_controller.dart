import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

class DueItem {
  final String id;
  final String partyName;
  final String phone;
  final double totalAmount;
  final double paidAmount;
  final DateTime lastTransaction;
  final bool isCustomer;

  double get remainingAmount => totalAmount - paidAmount;

  DueItem({
    required this.id,
    required this.partyName,
    required this.phone,
    required this.totalAmount,
    required this.paidAmount,
    required this.lastTransaction,
    this.isCustomer = true,
  });

  factory DueItem.fromJson(Map<String, dynamic> json) => DueItem(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        partyName: json['partyName'] ?? '',
        phone: json['phone'] ?? '',
        totalAmount: _toDouble(json['totalAmount']),
        paidAmount: _toDouble(json['paidAmount']),
        // tryParse — a malformed date must not throw out of the list mapping.
        lastTransaction:
            DateTime.tryParse('${json['lastTransaction'] ?? ''}') ?? DateTime.now(),
        isCustomer: json['isCustomer'] ?? true,
      );
}

class MerchantDuesController extends GetxController {
  final dues = <DueItem>[].obs;
  final isLoading = false.obs;
  final totalReceivable = 0.0.obs;
  final totalPayable = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDues();
  }

  Future<void> loadDues() async {
    isLoading.value = true;
    try {
      final res = await ApiService().get('/merchant/dues');
      if (res.success && res.data != null) {
        final rawData = res.data;
        final List<dynamic> list = rawData is List
            ? rawData
            : (rawData is Map ? (rawData['dues'] ?? rawData['data'] ?? []) : []);
        dues.value = list
            .whereType<Map>()
            .map((e) => DueItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _calculateTotals();
      }
    } catch (e) {
      debugPrint('loadDues failed: $e');
      safeSnackbar('Error', 'Could not load your dues. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTotals() {
    double rec = 0;
    double pay = 0;
    for (var due in dues) {
      if (due.isCustomer) {
        rec += due.remainingAmount;
      } else {
        pay += due.remainingAmount;
      }
    }
    totalReceivable.value = rec;
    totalPayable.value = pay;
  }

  Future<void> collectPayment(String id, double amount) async {
    final index = dues.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final old = dues[index];
    if (amount <= 0) {
      safeSnackbar('Error', 'Enter an amount greater than 0',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // Client-side mirror of the server's guard, so an over-collection is
    // caught before the round-trip.
    if (amount > old.remainingAmount + 0.0001) {
      safeSnackbar('Too much',
          'Only D ${old.remainingAmount.toStringAsFixed(3)} is still outstanding',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      // Send the increment, not a locally-computed absolute total: two
      // devices collecting at once would otherwise overwrite each other.
      final res = await ApiService()
          .put('/merchant/dues/$id/collect', {'payment': amount});
      if (res.success && res.data is Map) {
        dues[index] = DueItem.fromJson(Map<String, dynamic>.from(res.data as Map));
        _calculateTotals();
        safeSnackbar('Collected', 'Payment recorded',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to collect payment',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('collectPayment failed: $e');
      safeSnackbar('Error', 'Could not record that payment. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addDue(Map<String, dynamic> body) async {
    try {
      final res = await ApiService().post('/merchant/dues', body);
      if (res.success && res.data is Map) {
        dues.insert(0, DueItem.fromJson(Map<String, dynamic>.from(res.data as Map)));
        _calculateTotals();
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to add due',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('addDue failed: $e');
      safeSnackbar('Error', 'Could not save that due. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
