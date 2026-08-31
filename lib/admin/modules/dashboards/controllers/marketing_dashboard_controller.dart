import '../models/dashboard_models.dart';
import 'dashboard_base_controller.dart';

/// Who is signing up, who is buying, and who stopped.
class MarketingDashboardController extends DashboardBaseController {
  @override
  String get endpoint => 'marketing';

  @override
  String get permission => 'reports.read';

  int get totalCustomers => count('totalCustomers');
  int get newCustomers => count('newCustomers');
  int get activeCustomers => count('activeCustomers');
  int get verifiedCustomers => count('verifiedCustomers');

  /// Null when nobody bought in the baseline window: there is no churn rate
  /// out of an empty cohort, and 0% would read as perfect retention.
  bool get hasChurnBaseline => data['churnRate'] != null;
  double get churnRate => money('churnRate');
  int get churnedCustomers => count('churnedCustomers');
  int get churnBaseline => count('churnBaseline');

  /// The backend states what it counted, so the number on screen is not a
  /// percentage nobody can define.
  String get churnDefinition => data['churnDefinition'] is String
      ? data['churnDefinition'] as String
      : '';

  double get ordersPerCustomer =>
      nested('engagementMetrics', 'ordersPerCustomer').toDouble();
  double get repeatRate => nested('engagementMetrics', 'repeatRate').toDouble();
  double get lifetimeValue =>
      nested('engagementMetrics', 'lifetimeValue').toDouble();
  int get buyers => nested('engagementMetrics', 'buyers').toInt();
  int get repeatBuyers => nested('engagementMetrics', 'repeatBuyers').toInt();

  /// Buyers as a share of all customers — the honest denominator for a
  /// conversion figure on a platform with no visitor tracking.
  double get buyerRate => nested('engagementMetrics', 'buyerRate').toDouble();

  List<ChartPoint> get growthChart => chart('customerGrowthChart');

  List<ChartPoint> get segments =>
      chart('customerSegments', labelKey: 'segment', valueKey: 'count');

  List<Map<String, dynamic>> get topCustomers => table('topCustomers');
}
