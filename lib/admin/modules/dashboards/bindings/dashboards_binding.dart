import 'package:get/get.dart';

import '../controllers/finance_dashboard_controller.dart';
import '../controllers/marketing_dashboard_controller.dart';
import '../controllers/merchants_dashboard_controller.dart';
import '../controllers/operations_dashboard_controller.dart';
import '../controllers/sales_dashboard_controller.dart';

/// One binding per dashboard, so leaving a board disposes its controller and
/// with it the refresh timer. A single shared binding would leave five timers
/// polling the API from screens nobody is looking at.

class SalesDashboardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => SalesDashboardController());
}

class OperationsDashboardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => OperationsDashboardController());
}

class FinanceDashboardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => FinanceDashboardController());
}

class MarketingDashboardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MarketingDashboardController());
}

class MerchantsDashboardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MerchantsDashboardController());
}
