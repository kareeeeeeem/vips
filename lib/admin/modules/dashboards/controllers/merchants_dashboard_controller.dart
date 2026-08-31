import '../models/dashboard_models.dart';
import 'dashboard_base_controller.dart';

/// The merchant roster, who is selling, and who is not.
class MerchantsDashboardController extends DashboardBaseController {
  @override
  String get endpoint => 'merchants';

  @override
  String get permission => 'reports.read';

  int get totalMerchants => count('totalMerchants');
  int get activeMerchants => count('activeMerchants');
  int get inactiveMerchants => count('inactiveMerchants');
  int get pendingApprovals => count('pendingApprovals');
  int get newMerchants => count('newMerchants');
  int get sellingMerchants => count('sellingMerchants');

  /// Merchants on the books who sold nothing in this window. Invisible in any
  /// top-N ranking, and the more actionable half of the roster.
  int get idleMerchants => count('idleMerchants');

  double get totalRevenue => money('totalRevenue');

  List<ChartPoint> get growthChart => chart('merchantGrowthChart');

  List<ChartPoint> get categories =>
      chart('merchantCategories', labelKey: 'category', valueKey: 'count');

  /// The top ten by revenue, as a bar chart against each other.
  List<ChartPoint> get revenueRanking => topMerchants
      .map((m) => ChartPoint(
            m['name']?.toString() ?? 'Unknown',
            (m['revenue'] is num ? m['revenue'] as num : 0).toDouble(),
            count: m['orders'] is num ? (m['orders'] as num).toInt() : 0,
          ))
      .toList();

  List<Map<String, dynamic>> get topMerchants => table('topMerchants');
  List<Map<String, dynamic>> get merchantPerformance => table('merchantPerformance');
}
