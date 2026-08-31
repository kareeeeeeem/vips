import '../models/dashboard_models.dart';
import 'dashboard_base_controller.dart';

/// Revenue, order volume and what sold, over the chosen window.
class SalesDashboardController extends DashboardBaseController {
  @override
  String get endpoint => 'sales';

  @override
  String get permission => 'reports.read';

  double get totalRevenue => money('totalRevenue');
  int get totalOrders => count('totalOrders');
  double get averageOrderValue => money('averageOrderValue');
  double get onlineRevenue => money('onlineRevenue');
  double get posRevenue => money('posRevenue');

  /// The platform records no visitor or session data, so orders-over-visitors
  /// has no denominator. The card says so instead of showing a figure derived
  /// from something else and labelled "conversion".
  bool get conversionIsTracked => data['conversionRate'] != null;
  String get conversionNote => data['conversionRateNote'] is String
      ? data['conversionRateNote'] as String
      : 'Not tracked.';

  /// Revenue this ranking cannot attribute to any product, because those
  /// order lines carry neither a product id nor a name.
  double get unattributedRevenue => money('unattributedRevenue');

  List<ChartPoint> get salesChart => chart('salesChart');
  List<ChartPoint> get dailyTrend => chart('dailyTrend');

  /// Orders per bucket, read off the same series as the revenue chart so the
  /// two can never be drawn over different windows.
  List<ChartPoint> get orderVolume => salesChart
      .map((p) => ChartPoint(p.label, p.count.toDouble(), count: p.count))
      .toList();

  List<Map<String, dynamic>> get topProducts => table('topProducts');
  List<Map<String, dynamic>> get topMerchants => table('topMerchants');
  List<Map<String, dynamic>> get recentOrders => table('recentOrders');

  /// Where the money came in — the till against the apps.
  List<ChartPoint> get channelSplit => [
        ChartPoint('Online orders', onlineRevenue),
        ChartPoint('Counter sales', posRevenue),
      ];
}
