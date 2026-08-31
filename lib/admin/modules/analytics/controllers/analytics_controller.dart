import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/admin_api_service.dart';
import '../../dashboards/models/dashboard_models.dart';

/// Visitors, and the conversion rate they finally give a denominator to.
class AnalyticsController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt days = 30.obs;
  final RxMap<String, dynamic> data = <String, dynamic>{}.obs;

  static const List<int> windows = [7, 30, 90];

  bool get hasData => data.isNotEmpty;

  /// Whether anything has been recorded at all. Distinct from "zero visitors
  /// this week", which is a real measurement.
  bool get isTracking => data['tracking'] == true;

  String get trackingNote => data['trackingNote']?.toString() ?? '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.analyticsOverview(days: days.value);
      if (response.success && response.data is Map) {
        data.value = Map<String, dynamic>.from(response.data as Map);
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : 'Could not load analytics.';
      }
    } catch (e) {
      debugPrint('[ADMIN ANALYTICS] load failed: $e');
      errorMessage.value = 'Could not load analytics. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void setDays(int value) {
    if (days.value == value) return;
    days.value = value;
    load();
  }

  Map<String, dynamic> _block(String key) {
    final raw = data[key];
    return raw is Map ? Map<String, dynamic>.from(raw) : const {};
  }

  int _int(String block, String key) {
    final value = _block(block)[key];
    return value is num ? value.toInt() : 0;
  }

  // ── Visitors ──────────────────────────────────────────────
  int get totalVisitors => _int('visitors', 'total');
  int get visitorsToday => _int('visitors', 'today');
  int get visitorsThisWeek => _int('visitors', 'thisWeek');
  int get visitorsInWindow => _int('visitors', 'inWindow');
  int get screenViews => _int('visitors', 'screenViews');
  int get signedInSessions => _int('visitors', 'signedIn');

  /// Screen views per session. One person opening the app and looking at nine
  /// screens is one visitor, so this is depth, not volume.
  double get viewsPerSession =>
      visitorsInWindow == 0 ? 0 : screenViews / visitorsInWindow;

  // ── Conversion ────────────────────────────────────────────
  /// False while tracking is younger than the window: the ratio would count
  /// orders against only part of the visits they came from, and can read well
  /// above 100%. The screen shows the reason instead of the number.
  bool get conversionMeasurable => _block('conversion')['measurable'] == true;
  String get conversionReason => _block('conversion')['reason']?.toString() ?? '';
  double get conversionRate {
    final value = _block('conversion')['rate'];
    return value is num ? value.toDouble() : 0;
  }

  double get buyerRate {
    final value = _block('conversion')['buyerRate'];
    return value is num ? value.toDouble() : 0;
  }

  int get ordersInWindow => _int('conversion', 'orders');
  int get buyersInWindow => _int('conversion', 'buyers');

  DateTime? get trackingStartedAt =>
      adminDate(_block('conversion')['trackingStartedAt']);

  // ── People ────────────────────────────────────────────────
  int get totalCustomers => _int('customers', 'total');
  int get newCustomers => _int('customers', 'newInWindow');
  int get totalMerchants => _int('merchants', 'total');
  int get activeMerchants => _int('merchants', 'active');
  int get pendingMerchants => _int('merchants', 'pendingApproval');

  // ── Series and tables ─────────────────────────────────────
  List<Map<String, dynamic>> _table(String key) {
    final raw = data[key];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  List<ChartPoint> get visitorsByDay => _table('visitorsByDay')
      .map((r) => ChartPoint(adminString(r['date'], '—'), adminDouble(r['value'])))
      .toList();

  List<Map<String, dynamic>> get topScreens => _table('topScreens');

  List<ChartPoint> get byApp => _table('byApp')
      .map((r) => ChartPoint(
            adminLabelForApp(adminString(r['app'], 'unknown')),
            adminDouble(r['sessions']),
          ))
      .toList();

  List<ChartPoint> get byPlatform => _table('byPlatform')
      .map((r) => ChartPoint(
            adminString(r['platform'], 'unknown'),
            adminDouble(r['sessions']),
          ))
      .toList();
}

/// The three apps by the names an operator uses for them, not their codes.
String adminLabelForApp(String app) => switch (app) {
      'consumer' => 'Customer app',
      'merchant' => 'Merchant app',
      'admin' => 'Admin console',
      _ => 'Unknown',
    };
