import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';

/// The seven reports, one date range, one granularity.
///
/// Each report is fetched on demand and cached, so switching tabs does not
/// refetch what is already on screen — but changing the range or granularity
/// clears the cache, because every cached answer was for the old window.
class AdminReportsController extends GetxController {
  final AdminApiService _api = AdminApiService();

  /// Tab order. `merchants` is lifetime data; the rest honour the range.
  static const List<String> reports = [
    'sales',
    'profit',
    'products',
    'customers',
    'orders',
    'merchants',
    'commission',
  ];

  /// Reports whose numbers are lifetime rather than windowed. Saying so on
  /// screen stops the date range being read as applying to them.
  static const Set<String> lifetimeReports = {'merchants'};

  /// Reports that accept a day/week/month/year grouping.
  static const Set<String> groupableReports = {'sales', 'profit', 'customers'};

  static const List<String> granularities = ['day', 'week', 'month', 'year'];

  final RxString activeTab = 'sales'.obs;
  final RxString groupBy = 'day'.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();

  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;
  final RxString errorMessage = ''.obs;

  final RxMap<String, Map<String, dynamic>> cache =
      <String, Map<String, dynamic>>{}.obs;

  Map<String, dynamic>? get current => cache[activeTab.value];

  bool get isLifetime => lifetimeReports.contains(activeTab.value);
  bool get isGroupable => groupableReports.contains(activeTab.value);

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    dateRange.value = DateTimeRange(
      start: now.subtract(const Duration(days: 29)),
      end: now,
    );
    load();
  }

  String? _iso(DateTime? date) => date?.toIso8601String().substring(0, 10);

  Future<void> load({bool force = false}) async {
    final type = activeTab.value;
    if (!force && cache.containsKey(type)) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.report(
        type,
        from: _iso(dateRange.value?.start),
        to: _iso(dateRange.value?.end),
        groupBy: groupableReports.contains(type) ? groupBy.value : null,
      );
      if (response.success && response.data is Map) {
        cache[type] = Map<String, dynamic>.from(response.data as Map);
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load this report.';
      }
    } catch (e) {
      debugPrint('[ADMIN REPORTS] load $type failed: $e');
      errorMessage.value = 'Could not load this report. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    if (activeTab.value == tab) return;
    activeTab.value = tab;
    load();
  }

  /// Both of these invalidate every cached answer: they were all computed
  /// for the previous window.
  void setDateRange(DateTimeRange range) {
    dateRange.value = range;
    cache.clear();
    load(force: true);
  }

  void setGroupBy(String value) {
    if (groupBy.value == value) return;
    groupBy.value = value;
    for (final type in groupableReports) {
      cache.remove(type);
    }
    load(force: true);
  }

  Future<void> refreshCurrent() => load(force: true);

  /// Reads `summary.<key>` off the active report with a safe fallback.
  num summary(String key) {
    final data = current;
    if (data == null || data['summary'] is! Map) return 0;
    final value = (data['summary'] as Map)[key];
    return value is num ? value : 0;
  }

  /// True when the backend explicitly sent null — "no data" rather than zero.
  bool summaryIsNull(String key) {
    final data = current;
    if (data == null || data['summary'] is! Map) return true;
    return (data['summary'] as Map)[key] == null;
  }

  List<Map<String, dynamic>> section(String key) {
    final data = current;
    return data == null ? const [] : adminItems(data, key);
  }

  /// Downloads the active report as CSV.
  ///
  /// Goes through ApiService so the auth header is attached; the file arrives
  /// as a string the caller hands to the browser.
  Future<String?> exportCsv() async {
    if (isExporting.value) return null;
    isExporting.value = true;
    try {
      final response = await _api.exportReport(
        activeTab.value,
        from: _iso(dateRange.value?.start),
        to: _iso(dateRange.value?.end),
        groupBy: isGroupable ? groupBy.value : null,
      );
      if (response.success && response.data is String) {
        return response.data as String;
      }
      adminToast('Export failed', response.message, isError: true);
      return null;
    } catch (e) {
      debugPrint('[ADMIN REPORTS] export failed: $e');
      adminToast('Export failed',
          'Could not build the file. Please try again.', isError: true);
      return null;
    } finally {
      isExporting.value = false;
    }
  }

  String get exportFilename {
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    return 'vips-${activeTab.value}-$stamp.csv';
  }
}
