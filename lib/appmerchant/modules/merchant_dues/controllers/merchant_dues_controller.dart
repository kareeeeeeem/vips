import 'package:get/get.dart';

class DueItem {
  final String id;
  final String partyName;
  final String phone;
  final double totalAmount;
  final double paidAmount;
  final DateTime lastTransaction;
  final bool isCustomer; // true for customer (receivable), false for supplier (payable)

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
}

class MerchantDuesController extends GetxController {
  final dues = <DueItem>[].obs;
  
  final totalReceivable = 0.0.obs;
  final totalPayable = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    _calculateTotals();
  }

  void _loadMockData() {
    dues.assignAll([
      DueItem(
        id: '1',
        partyName: 'Jamil Test',
        phone: '959190000',
        totalAmount: 1200.0,
        paidAmount: 800.0,
        lastTransaction: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DueItem(
        id: '2',
        partyName: 'Ahmed Ali',
        phone: '959190001',
        totalAmount: 500.0,
        paidAmount: 100.0,
        lastTransaction: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DueItem(
        id: '3',
        partyName: 'Global Supplier Co.',
        phone: '959190002',
        totalAmount: 3000.0,
        paidAmount: 2500.0,
        lastTransaction: DateTime.now().subtract(const Duration(days: 10)),
        isCustomer: false,
      ),
    ]);
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

  void collectPayment(String id, double amount) {
    int index = dues.indexWhere((element) => element.id == id);
    if (index != -1) {
      var old = dues[index];
      dues[index] = DueItem(
        id: old.id,
        partyName: old.partyName,
        phone: old.phone,
        totalAmount: old.totalAmount,
        paidAmount: old.paidAmount + amount,
        lastTransaction: DateTime.now(),
        isCustomer: old.isCustomer,
      );
      _calculateTotals();
    }
  }
}
