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

  /// Revenue attributable to a merchant. Deliberately not the same figure as
  /// the sales dashboard's total, which counts every sale; the difference is
  /// [unattributedRevenue], so the two boards reconcile instead of quietly
  /// disagreeing about one window.
  double get totalRevenue => money('totalRevenue');

  /// Fulfilled revenue on orders carrying no merchant — a deleted merchant's
  /// record still ranks under 'Deleted merchant', but an order that never had
  /// one cannot appear in a per-merchant ranking at all.
  double get unattributedRevenue => money('unattributedRevenue');
  int get unattributedOrders => count('unattributedOrders');

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
