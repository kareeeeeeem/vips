import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';

import '../../../services/admin_api_service.dart';

/// The four reports the backend exposes, loaded together and re-fetched when
/// the date range changes.
///
/// `merchantsReport` is deliberately not date-scoped — it reports the
/// approval funnel and lifetime performance, which a date window would make
/// misleading rather than more precise.
class AdminReportsController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeTab = 'sales'.obs;

  final Rxn<Map<String, dynamic>> sales = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> users = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> merchants = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> orders = Rxn<Map<String, dynamic>>();

  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();

  @override
  void onInit() {
    super.onInit();
    // Default window: the last 30 days, matching what the backend falls back
    // to when no range is given.
    final now = DateTime.now();
    dateRange.value = DateTimeRange(
      start: now.subtract(const Duration(days: 29)),
      end: now,
    );
    load();
  }

  String? _iso(DateTime? date) => date?.toIso8601String().substring(0, 10);

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    final from = _iso(dateRange.value?.start);
    final to = _iso(dateRange.value?.end);

    try {
      final results = await Future.wait([
        _api.salesReport(from: from, to: to),
        _api.usersReport(from: from, to: to),
        _api.merchantsReport(),
        _api.ordersReport(from: from, to: to),
      ]);

      Map<String, dynamic>? unwrap(int index) {
        final response = results[index];
        return response.success && response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : null;
      }

      sales.value = unwrap(0);
      users.value = unwrap(1);
      merchants.value = unwrap(2);
      orders.value = unwrap(3);

      if (sales.value == null && users.value == null &&
          merchants.value == null && orders.value == null) {
        errorMessage.value = results.first.message.isNotEmpty
            ? results.first.message
            : 'Could not load reports.';
      }
    } catch (e) {
      debugPrint('[ADMIN REPORTS] load failed: $e');
      errorMessage.value = 'Could not load reports. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) => activeTab.value = tab;

  void setDateRange(DateTimeRange range) {
    dateRange.value = range;
    load();
  }

  /// Reads `summary.<key>` off one of the four reports.
  num summary(Rxn<Map<String, dynamic>> report, String key) {
    final data = report.value;
    if (data == null || data['summary'] is! Map) return 0;
    final value = (data['summary'] as Map)[key];
    return value is num ? value : 0;
  }

  List<Map<String, dynamic>> section(Rxn<Map<String, dynamic>> report, String key) {
    final data = report.value;
    return data == null ? const [] : adminItems(data, key);
  }
}
