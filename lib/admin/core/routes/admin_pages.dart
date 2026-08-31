// ignore_for_file: constant_identifier_names
import 'package:get/get.dart';

import '../../modules/auth/bindings/admin_auth_binding.dart';
import '../../modules/auth/views/admin_login_view.dart';
import '../../modules/auth/views/admin_splash_view.dart';
import '../../modules/dashboard/bindings/admin_dashboard_binding.dart';
import '../../modules/dashboard/views/admin_dashboard_view.dart';
import '../../modules/dashboards/bindings/dashboards_binding.dart';
import '../../modules/dashboards/views/finance_dashboard_view.dart';
import '../../modules/dashboards/views/marketing_dashboard_view.dart';
import '../../modules/dashboards/views/merchants_dashboard_view.dart';
import '../../modules/dashboards/views/operations_dashboard_view.dart';
import '../../modules/dashboards/views/sales_dashboard_view.dart';
import '../../modules/inventory/bindings/inventory_binding.dart';
import '../../modules/inventory/views/inventory_movements_view.dart';
import '../../modules/inventory/views/inventory_overview_view.dart';
import '../../modules/inventory/views/inventory_transfers_view.dart';
import '../../modules/inventory/views/low_stock_alerts_view.dart';
import '../../modules/merchants/bindings/merchants_binding.dart';
import '../../modules/merchants/views/merchant_details_view.dart';
import '../../modules/merchants/views/merchants_list_view.dart';
import '../../modules/orders/bindings/orders_binding.dart';
import '../../modules/products/bindings/products_binding.dart';
import '../../modules/products/views/products_list_view.dart';
import '../../modules/orders/views/order_details_view.dart';
import '../../modules/orders/views/orders_list_view.dart';
import '../../modules/pos/bindings/pos_binding.dart';
import '../../modules/pos/views/pos_checkout_view.dart';
import '../../modules/pos/views/pos_home_view.dart';
import '../../modules/pos/views/pos_invoice_view.dart';
import '../../modules/pos/views/pos_invoices_view.dart';
import '../../modules/reports/bindings/reports_binding.dart';
import '../../modules/reports/views/reports_view.dart';
import '../../modules/settings/bindings/admin_settings_binding.dart';
import '../../modules/staff/bindings/staff_binding.dart';
import '../../modules/staff/views/roles_permissions_view.dart';
import '../../modules/staff/views/staff_add_edit_view.dart';
import '../../modules/staff/views/staff_details_view.dart';
import '../../modules/staff/views/staff_list_view.dart';
import '../../modules/settings/views/admin_settings_view.dart';
import '../../modules/users/bindings/users_binding.dart';
import '../../modules/users/views/user_details_view.dart';
import '../../modules/users/views/users_list_view.dart';
import 'admin_routes.dart';

/// Route table for the admin console.
///
/// Every entry in `AdminRoutes` has a page here, and every page is reachable
/// from the drawer, the bottom bar or a link on another screen — the console
/// has no route that nothing navigates to, and no navigation target without
/// a registered route.
class AdminPages {
  AdminPages._();

  static const INITIAL = AdminRoutes.SPLASH;

  static final List<GetPage> routes = [
    GetPage(
      name: AdminRoutes.SPLASH,
      page: () => const AdminSplashView(),
      binding: AdminSplashBinding(),
    ),
    GetPage(
      name: AdminRoutes.LOGIN,
      page: () => const AdminLoginView(),
    ),
    GetPage(
      name: AdminRoutes.DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),

    // The five analytical dashboards. A binding each, so leaving a board
    // disposes its controller and stops its refresh timer — one shared
    // binding would leave five timers polling from screens nobody is on.
    GetPage(
      name: AdminRoutes.DASH_SALES,
      page: () => const SalesDashboardView(),
      binding: SalesDashboardBinding(),
    ),
    GetPage(
      name: AdminRoutes.DASH_OPERATIONS,
      page: () => const OperationsDashboardView(),
      binding: OperationsDashboardBinding(),
    ),
    GetPage(
      name: AdminRoutes.DASH_FINANCE,
      page: () => const FinanceDashboardView(),
      binding: FinanceDashboardBinding(),
    ),
    GetPage(
      name: AdminRoutes.DASH_MARKETING,
      page: () => const MarketingDashboardView(),
      binding: MarketingDashboardBinding(),
    ),
    GetPage(
      name: AdminRoutes.DASH_MERCHANTS,
      page: () => const MerchantsDashboardView(),
      binding: MerchantsDashboardBinding(),
    ),

    // Detail routes carry the same binding as their list, so opening one
    // directly (a deep link, a hot restart on that route) still finds its
    // controller instead of throwing "controller not found".
    GetPage(
      name: AdminRoutes.USERS,
      page: () => const UsersListView(),
      binding: AdminUsersBinding(),
    ),
    GetPage(
      name: AdminRoutes.USER_DETAILS,
      page: () => const UserDetailsView(),
      binding: AdminUsersBinding(),
    ),

    GetPage(
      name: AdminRoutes.MERCHANTS,
      page: () => const MerchantsListView(),
      binding: AdminMerchantsBinding(),
    ),
    GetPage(
      name: AdminRoutes.MERCHANT_DETAILS,
      page: () => const MerchantDetailsView(),
      binding: AdminMerchantsBinding(),
    ),

    GetPage(
      name: AdminRoutes.ORDERS,
      page: () => const OrdersListView(),
      binding: AdminOrdersBinding(),
    ),
    GetPage(
      name: AdminRoutes.ORDER_DETAILS,
      page: () => const OrderDetailsView(),
      binding: AdminOrdersBinding(),
    ),

    // The catalogue itself. Stock levels live on the Inventory screens; this
    // is the product record behind them — price, cost and visibility.
    GetPage(
      name: AdminRoutes.PRODUCTS,
      page: () => const ProductsListView(),
      binding: AdminProductsBinding(),
    ),

    // The four inventory screens are siblings behind one tab strip.
    GetPage(
      name: AdminRoutes.INVENTORY,
      page: () => const InventoryOverviewView(),
      binding: AdminInventoryBinding(),
    ),
    GetPage(
      name: AdminRoutes.INVENTORY_MOVEMENTS,
      page: () => const InventoryMovementsView(),
      binding: AdminInventoryMovementsBinding(),
    ),
    GetPage(
      name: AdminRoutes.INVENTORY_TRANSFERS,
      page: () => const InventoryTransfersView(),
      binding: AdminInventoryTransfersBinding(),
    ),
    GetPage(
      name: AdminRoutes.INVENTORY_ALERTS,
      page: () => const LowStockAlertsView(),
      binding: AdminLowStockBinding(),
    ),
    // The till. Checkout shares the PosController with the till screen, so
    // it reads the same server-owned cart rather than a copy.
    GetPage(
      name: AdminRoutes.POS,
      page: () => const PosHomeView(),
      binding: PosBinding(),
    ),
    GetPage(
      name: AdminRoutes.POS_CHECKOUT,
      page: () => const PosCheckoutView(),
      binding: PosBinding(),
    ),
    GetPage(
      name: AdminRoutes.POS_INVOICE,
      page: () => const PosInvoiceView(),
    ),
    GetPage(
      name: AdminRoutes.POS_INVOICES,
      page: () => const PosInvoicesView(),
      binding: PosInvoicesBinding(),
    ),
    GetPage(
      name: AdminRoutes.REPORTS,
      page: () => const ReportsView(),
      binding: AdminReportsBinding(),
    ),
    // Console operators. STAFF_NEW is registered before STAFF_DETAILS so the
    // literal '/staff/new' is not captured by the ':id' pattern.
    GetPage(
      name: AdminRoutes.STAFF,
      page: () => const StaffListView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AdminRoutes.STAFF_NEW,
      page: () => const StaffAddEditView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AdminRoutes.STAFF_EDIT,
      page: () => const StaffAddEditView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AdminRoutes.STAFF_DETAILS,
      page: () => const StaffDetailsView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AdminRoutes.ROLES,
      page: () => const RolesPermissionsView(),
      binding: StaffBinding(),
    ),
    GetPage(
      name: AdminRoutes.SETTINGS,
      page: () => const AdminSettingsView(),
      binding: AdminSettingsBinding(),
    ),
  ];
}
