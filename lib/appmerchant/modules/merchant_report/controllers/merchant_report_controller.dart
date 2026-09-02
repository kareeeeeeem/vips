import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

/// The shop's position: sales, what it is owed, what it owes, and stock.
class MerchantReportController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final period = 'month'.obs;

  static const periods = ['today', 'week', 'month', 'all'];
  static String periodLabel(String key) => switch (key) {
        'today' => 'Today',
        'week' => 'This week',
        'month' => 'This month',
        'all' => 'All time',
        _ => key,
      };

  final onlineSales = 0.0.obs;
  final counterSales = 0.0.obs;
  final totalSales = 0.0.obs;
  final counterInvoices = 0.obs;
  final purchases = 0.0.obs;

  final dueFromCustomers = 0.0.obs;
  final dueToSuppliers = 0.0.obs;
  final customerParties = 0.obs;
  final supplierParties = 0.obs;

  final items = 0.obs;
  final categories = 0.obs;

  final stockValue = 0.0.obs;
  final stockUnits = 0.obs;
  final stockLines = 0.obs;

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);
  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void setPeriod(String value) {
    if (period.value == value) return;
    period.value = value;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final response = await ApiService()
          .get('/merchant/report', queryParams: {'period': period.value});
      if (response.success && response.data is Map) {
        final d = Map<String, dynamic>.from(response.data as Map);

        final sales = Map<String, dynamic>.from(d['sales'] as Map? ?? {});
        onlineSales.value = _num(sales['online']);
        counterSales.value = _num(sales['counter']);
        totalSales.value = _num(sales['total']);
        counterInvoices.value = _int(sales['counterInvoices']);
        purchases.value = _num(d['purchases']);

        final due = Map<String, dynamic>.from(d['due'] as Map? ?? {});
        dueFromCustomers.value = _num(due['fromCustomers']);
        dueToSuppliers.value = _num(due['toSuppliers']);
        customerParties.value = _int(due['customerParties']);
        supplierParties.value = _int(due['supplierParties']);

        final cat = Map<String, dynamic>.from(d['catalogue'] as Map? ?? {});
        items.value = _int(cat['items']);
        categories.value = _int(cat['categories']);

        final stock = Map<String, dynamic>.from(d['stock'] as Map? ?? {});
        stockValue.value = _num(stock['value']);
        stockUnits.value = _int(stock['units']);
        stockLines.value = _int(stock['lines']);
      } else {
        error.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load your report.';
      }
    } catch (e) {
      debugPrint('report load failed: $e');
      error.value = 'Could not reach the server.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Dinars, always. The mock this screen came from was drawn in dollars.
  static String money(double value) => 'D ${value.toStringAsFixed(3)}';
}
