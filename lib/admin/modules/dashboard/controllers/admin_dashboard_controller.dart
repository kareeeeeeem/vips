import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/widgets/admin_top_bar.dart';
import '../../../services/admin_api_service.dart';

/// One point on the dashboard's daily series.
class DashboardPoint {
  final String date;
  final int orders;
  final double revenue;
  final int users;
  final int merchants;

  DashboardPoint({
    required this.date,
    required this.orders,
    required this.revenue,
    required this.users,
    required this.merchants,
  });

  factory DashboardPoint.fromJson(Map<String, dynamic> json) => DashboardPoint(
        date: adminString(json['date']),
        orders: adminInt(json['orders']),
        revenue: adminDouble(json['revenue']),
        users: adminInt(json['users']),
        merchants: adminInt(json['merchants']),
      );

  /// 'd MMM' from the backend's 'yyyy-MM-dd', for the chart axis.
  String get shortLabel {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]}';
  }
}

class AdminDashboardController extends GetxController {
  final AdminApiService _api = AdminApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Stats, flattened out of the nested response so the view reads one map.
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

  final RxList<DashboardPoint> series = <DashboardPoint>[].obs;
  final RxInt chartDays = 14.obs;
  final RxString chartMetric = 'revenue'.obs; // revenue | orders | users

  final RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> pendingRegistrations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Three independent reads — issued together so the dashboard is not
      // three sequential round trips against a cold Render instance.
      final results = await Future.wait([
        _api.dashboardStats(),
        _api.dashboardCharts(days: chartDays.value),
        _api.dashboardRecent(limit: 6),
      ]);

      final statsRes  = results[0];
      final chartRes  = results[1];
      final recentRes = results[2];

      if (statsRes.success && statsRes.data is Map) {
        stats.value = Map<String, dynamic>.from(statsRes.data as Map);
      } else {
        errorMessage.value = statsRes.message;
      }

      if (chartRes.success && chartRes.data is Map) {
        series.value = adminItems(chartRes.data, 'series')
            .map(DashboardPoint.fromJson)
            .toList();
      }

      if (recentRes.success && recentRes.data is Map) {
        recentOrders.value = adminItems(recentRes.data, 'orders');
        recentUsers.value = adminItems(recentRes.data, 'users');
        pendingRegistrations.value = adminItems(recentRes.data, 'pendingRegistrations');
      }
      // Keep the top-bar badge in step with the dashboard the operator is
      // looking at, rather than leaving a count that is minutes stale.
      if (Get.isRegistered<AdminTopBarController>()) {
        await Get.find<AdminTopBarController>().loadNotifications();
      }
    } catch (e) {
      debugPrint('[ADMIN DASHBOARD] load failed: $e');
      errorMessage.value = 'Could not load the dashboard. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Reloads only the chart when the window changes, so switching 7/14/30
  /// days does not refetch the stat cards and the activity feed too.
  Future<void> setChartDays(int days) async {
    if (chartDays.value == days) return;
    chartDays.value = days;
    try {
      final response = await _api.dashboardCharts(days: days);
      if (response.success && response.data is Map) {
        series.value = adminItems(response.data, 'series')
            .map(DashboardPoint.fromJson)
            .toList();
      }
    } catch (e) {
      debugPrint('[ADMIN DASHBOARD] chart reload failed: $e');
    }
  }

  void setChartMetric(String metric) => chartMetric.value = metric;

  /// Reads a nested stat like `section.key` with a safe fallback — the
  /// dashboard renders before the first response lands.
  num stat(String section, String key) {
    final group = stats[section];
    if (group is! Map) return 0;
    final value = group[key];
    return value is num ? value : 0;
  }

  List<double> get chartValues {
    switch (chartMetric.value) {
      case 'orders':
        return series.map((p) => p.orders.toDouble()).toList();
      case 'users':
        return series.map((p) => p.users.toDouble()).toList();
      default:
        return series.map((p) => p.revenue).toList();
    }
  }

  List<String> get chartLabels => series.map((p) => p.shortLabel).toList();
}
