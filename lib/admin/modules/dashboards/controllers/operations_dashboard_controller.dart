import '../models/dashboard_models.dart';
import 'dashboard_base_controller.dart';

/// The order queue, the fulfilment clock and the stock backlog.
class OperationsDashboardController extends DashboardBaseController {
  @override
  String get endpoint => 'operations';

  /// The shift-level view. A cashier already sees orders and stock, so this
  /// board sits behind dashboard.read rather than the reports permission the
  /// four money boards need.
  @override
  String get permission => 'dashboard.read';

  /// Shorter than the others: this is the board an operator leaves open on a
  /// wall to watch a queue, where two minutes is already stale.
  @override
  Duration get refreshInterval => const Duration(seconds: 60);

  int get pendingOrders => count('pendingOrders');
  int get inProgressOrders => count('inProgressOrders');
  int get completedOrders => count('completedOrders');
  int get cancelledOrders => count('cancelledOrders');
  int get totalOrders => count('totalOrders');
  int get unpaidOrders => count('unpaidOrders');
  double get cancellationRate => money('cancellationRate');

  int get lowStockItems => count('lowStockItems');
  int get outOfStockItems => count('outOfStockItems');

  /// Null when nothing was delivered in the window. "No completed deliveries
  /// to measure" and "delivered instantly" are not the same answer, so the
  /// card must not print 0 for both.
  bool get hasFulfilmentSample => data['averageFulfillmentTime'] != null;
  double get averageFulfilmentHours => money('averageFulfillmentTime');
  int get fulfilmentSampleSize => count('fulfillmentSampleSize');

  List<ChartPoint> get statusDistribution =>
      chart('orderStatusDistribution', labelKey: 'status', valueKey: 'count');

  /// The queue as a bar chart: the four stages an order moves through.
  List<ChartPoint> get queueStages => [
        ChartPoint('Pending', pendingOrders.toDouble()),
        ChartPoint('In progress', inProgressOrders.toDouble()),
        ChartPoint('Completed', completedOrders.toDouble()),
        ChartPoint('Cancelled', cancelledOrders.toDouble()),
      ];

  List<Map<String, dynamic>> get lowStockList => table('lowStockList');
  List<Map<String, dynamic>> get recentActivity => table('recentActivity');
}
