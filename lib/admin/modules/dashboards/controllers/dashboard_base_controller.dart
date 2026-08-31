import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../models/dashboard_models.dart';

/// What every analytical dashboard does the same way.
///
/// The five dashboards differ only in which endpoint they read and how they
/// present it; window handling, loading, error reporting, the periodic
/// refresh and CSV export are identical, so they live here once. Five copies
/// is how one of them ends up quietly not clearing its cache on a date change.
abstract class DashboardBaseController extends GetxController {
  final AdminApiService api = AdminApiService();

  /// The `/admin/dashboards/<name>` segment this controller reads.
  String get endpoint;

  /// The permission the backend requires. Checked before the first request so
  /// a role that cannot see this board gets a plain explanation instead of a
  /// 403 rendered as "something went wrong".
  String get permission;

  /// How often to re-read while the screen is open. The dashboards are wall
  /// displays as much as pages, so they refresh themselves — but only while
  /// mounted, and never on top of a request already in flight.
  Duration get refreshInterval => const Duration(minutes: 2);

  final Rx<DashboardPeriod> period = DashboardPeriod.month.obs;
  final Rxn<DateTimeRange> customRange = Rxn<DateTimeRange>();

  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isForbidden = false.obs;
  final Rxn<DateTime> lastUpdated = Rxn<DateTime>();

  final RxMap<String, dynamic> data = <String, dynamic>{}.obs;

  Timer? _timer;

  bool get hasData => data.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
    _timer = Timer.periodic(refreshInterval, (_) {
      // Silent: a background tick must never blank the screen or pop a toast
      // over whatever the operator is reading.
      if (!isLoading.value && !isForbidden.value) load(silent: true);
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  String? _iso(DateTime? date) => date?.toIso8601String().substring(0, 10);

  Future<void> load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    if (!silent) errorMessage.value = '';
    try {
      final response = await api.dashboard(
        endpoint,
        period: period.value.key,
        startDate: period.value == DashboardPeriod.custom
            ? _iso(customRange.value?.start)
            : null,
        endDate: period.value == DashboardPeriod.custom
            ? _iso(customRange.value?.end)
            : null,
      );

      if (response.success && response.data is Map) {
        data.value = Map<String, dynamic>.from(response.data as Map);
        lastUpdated.value = DateTime.now();
        errorMessage.value = '';
        isForbidden.value = false;
      } else if (response.statusCode == 403) {
        isForbidden.value = true;
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Your role does not allow this dashboard.';
      } else if (!silent) {
        // The previous figures stay on screen behind the message rather than
        // being replaced by an empty board — a failed refresh should not look
        // like the platform suddenly earned nothing.
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load this dashboard.';
      }
    } catch (e) {
      debugPrint('[ADMIN DASHBOARD] $endpoint load failed: $e');
      if (!silent) {
        errorMessage.value = 'Could not load this dashboard. Please try again.';
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> refreshData() => load();

  void setFilter(DashboardPeriod next, DateTimeRange? range) {
    if (next == DashboardPeriod.custom && range == null) return;
    period.value = next;
    if (next == DashboardPeriod.custom) customRange.value = range;
    load();
  }

  // ── Reading the payload ───────────────────────────────────
  // Every accessor is total: a missing or unexpectedly shaped key returns a
  // neutral value rather than throwing inside a build method, which is how a
  // single odd row blanks a whole screen.

  num number(String key) {
    final value = data[key];
    return value is num ? value : 0;
  }

  double money(String key) => adminDouble(data[key]);

  int count(String key) => adminInt(data[key]);

  /// True when the backend explicitly sent null — "not measurable" rather
  /// than zero. The two must never render the same way.
  bool isNull(String key) => !data.containsKey(key) || data[key] == null;

  /// A percentage change against the previous window, or null when there was
  /// no baseline to compare against.
  double? change(String key) {
    final block = data['change'];
    if (block is! Map) return null;
    final value = block[key];
    return value is num ? value.toDouble() : null;
  }

  num previous(String key) {
    final block = data['previous'];
    if (block is! Map) return 0;
    final value = block[key];
    return value is num ? value : 0;
  }

  /// A nested `{...}` block such as `engagementMetrics`.
  num nested(String block, String key) {
    final map = data[block];
    if (map is! Map) return 0;
    final value = map[key];
    return value is num ? value : 0;
  }

  List<Map<String, dynamic>> table(String key) {
    final raw = data[key];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<ChartPoint> chart(
    String key, {
    String labelKey = 'date',
    String valueKey = 'value',
  }) =>
      table(key)
          .map((row) => ChartPoint.fromJson(row, labelKey: labelKey, valueKey: valueKey))
          .toList();

  // ── The window, as the server applied it ──────────────────

  Map<String, dynamic> get window {
    final raw = data['window'];
    return raw is Map ? Map<String, dynamic>.from(raw) : const {};
  }

  /// The window actually used, read back off the response.
  ///
  /// Not the requested one: an unparseable custom range falls back on the
  /// server, and a filter chip still reading "Custom" over last month's
  /// numbers is how an operator misreads a whole board.
  String get appliedWindowLabel {
    final start = adminDate(window['startDate']);
    final end = adminDate(window['endDate']);
    if (start == null || end == null) return period.value.label;
    final grouping = adminString(window['groupBy'], 'day');
    return '${adminDateLabel(start)} – ${adminDateLabel(end)} · by $grouping';
  }

  String get lastUpdatedLabel {
    final at = lastUpdated.value;
    if (at == null) return '';
    return 'Updated ${adminRelative(at)}';
  }

  // ── Export ────────────────────────────────────────────────

  Future<String?> exportCsv() async {
    if (isExporting.value) return null;
    isExporting.value = true;
    try {
      final response = await api.exportDashboard(
        endpoint,
        period: period.value.key,
        startDate: period.value == DashboardPeriod.custom
            ? _iso(customRange.value?.start)
            : null,
        endDate: period.value == DashboardPeriod.custom
            ? _iso(customRange.value?.end)
            : null,
      );
      if (response.success && response.data is String) return response.data as String;
      adminToast(
        'Export failed',
        response.message.isNotEmpty
            ? response.message
            : 'Could not build the file.',
        isError: true,
      );
      return null;
    } catch (e) {
      debugPrint('[ADMIN DASHBOARD] $endpoint export failed: $e');
      adminToast('Export failed', 'Could not build the file. Please try again.',
          isError: true);
      return null;
    } finally {
      isExporting.value = false;
    }
  }

  String get exportFilename {
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    return 'vips-$endpoint-dashboard-$stamp.csv';
  }
}
