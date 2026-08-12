import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

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
        totalAmount: (json['totalAmount'] ?? 0).toDouble(),
        paidAmount: (json['paidAmount'] ?? 0).toDouble(),
        lastTransaction: json['lastTransaction'] != null
            ? DateTime.parse(json['lastTransaction'])
            : DateTime.now(),
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
        dues.value = list.map((e) => DueItem.fromJson(e)).toList();
        _calculateTotals();
      }
    } catch (_) {
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
    final newPaid = old.paidAmount + amount;
    try {
      final res = await ApiService().put('/merchant/dues/$id/collect', {'paidAmount': newPaid});
      if (res.success) {
        dues[index] = DueItem(
          id: old.id,
          partyName: old.partyName,
          phone: old.phone,
          totalAmount: old.totalAmount,
          paidAmount: newPaid,
          lastTransaction: DateTime.now(),
          isCustomer: old.isCustomer,
        );
        _calculateTotals();
      } else {
        safeSnackbar('Error', 'Failed to collect payment', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to collect payment', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addDue(Map<String, dynamic> body) async {
    try {
      final res = await ApiService().post('/merchant/dues', body);
      if (res.success && res.data != null) {
        dues.insert(0, DueItem.fromJson(res.data));
        _calculateTotals();
      } else {
        safeSnackbar('Error', 'Failed to add due', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to add due', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
