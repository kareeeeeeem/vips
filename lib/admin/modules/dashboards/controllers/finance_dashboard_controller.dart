import '../models/dashboard_models.dart';
import 'dashboard_base_controller.dart';

/// Revenue against cost, the platform's commission, and money owed out.
class FinanceDashboardController extends DashboardBaseController {
  @override
  String get endpoint => 'finance';

  @override
  String get permission => 'reports.read';

  double get totalRevenue => money('totalRevenue');
  double get totalProfit => money('totalProfit');
  double get totalCommissions => money('totalCommissions');
  double get pendingPayouts => money('pendingPayouts');
  int get pendingPayoutCount => count('pendingPayoutCount');
  double get paidPayouts => money('paidPayouts');

  /// The share of revenue the margin was actually computed over.
  ///
  /// `Product.costPrice` defaults to 0 meaning "not recorded", so a margin
  /// taken over all revenue would read as 100% on every legacy sale. The
  /// screen prints this next to the margin: at 5% coverage, the margin is a
  /// statement about 5% of the business.
  double get costCoverage => money('costCoverage');
  double get costedRevenue => money('costedRevenue');
  double get margin => money('margin');

  /// Merchants selling in this window whose commission rate is still 0.
  /// The figure that explains a suspiciously small commission total.
  int get merchantsOnZeroRate => count('merchantsOnZeroRate');

  List<ChartPoint> get revenueChart => chart('revenueChart');
  List<ChartPoint> get profitChart => chart('profitChart');

  List<ChartPoint> get commissionByCategory =>
      chart('commissionBreakdown', labelKey: 'category', valueKey: 'amount');

  List<Map<String, dynamic>> get commissionBreakdown => table('commissionBreakdown');
  List<Map<String, dynamic>> get recentPayouts => table('recentPayouts');
}
