// ignore_for_file: constant_identifier_names

/// Route names for the admin console.
///
/// Same two-class shape as `MerchantRoutes` / `_MerchantPaths` so the three
/// apps stay navigable in the same way.
abstract class AdminRoutes {
  AdminRoutes._();

  static const SPLASH           = _AdminPaths.SPLASH;
  static const LOGIN            = _AdminPaths.LOGIN;
  static const DASHBOARD        = _AdminPaths.DASHBOARD;
  static const USERS            = _AdminPaths.USERS;
  static const USER_DETAILS     = _AdminPaths.USER_DETAILS;
  static const MERCHANTS        = _AdminPaths.MERCHANTS;
  static const MERCHANT_DETAILS = _AdminPaths.MERCHANT_DETAILS;
  static const ORDERS           = _AdminPaths.ORDERS;
  static const ORDER_DETAILS    = _AdminPaths.ORDER_DETAILS;
  static const INVENTORY            = _AdminPaths.INVENTORY;
  static const INVENTORY_MOVEMENTS  = _AdminPaths.INVENTORY_MOVEMENTS;
  static const INVENTORY_TRANSFERS  = _AdminPaths.INVENTORY_TRANSFERS;
  static const INVENTORY_ALERTS     = _AdminPaths.INVENTORY_ALERTS;
  static const POS              = _AdminPaths.POS;
  static const POS_CHECKOUT     = _AdminPaths.POS_CHECKOUT;
  static const POS_INVOICE      = _AdminPaths.POS_INVOICE;
  static const POS_INVOICES     = _AdminPaths.POS_INVOICES;
  static const REPORTS          = _AdminPaths.REPORTS;
  static const SETTINGS         = _AdminPaths.SETTINGS;

  // ── Builders for the parameterised detail routes ──────────
  // The registered names carry a `:id` segment, so navigation must go through
  // these rather than hand-concatenating a path — that is how a link ends up
  // pointing at a route that was never registered.
  static String userDetails(String id) => '$USERS/$id';
  static String merchantDetails(String id) => '$MERCHANTS/$id';
  static String orderDetails(String id) => '$ORDERS/$id';
}

abstract class _AdminPaths {
  static const SPLASH           = '/';
  static const LOGIN            = '/login';
  static const DASHBOARD        = '/dashboard';
  static const USERS            = '/users';
  static const USER_DETAILS     = '/users/:id';
  static const MERCHANTS        = '/merchants';
  static const MERCHANT_DETAILS = '/merchants/:id';
  static const ORDERS           = '/orders';
  static const ORDER_DETAILS    = '/orders/:id';
  static const INVENTORY            = '/inventory';
  static const INVENTORY_MOVEMENTS  = '/inventory/movements';
  static const INVENTORY_TRANSFERS  = '/inventory/transfers';
  static const INVENTORY_ALERTS     = '/inventory/alerts';
  static const POS              = '/pos';
  static const POS_CHECKOUT     = '/pos/checkout';
  static const POS_INVOICE      = '/pos/invoice';
  static const POS_INVOICES     = '/pos/invoices';
  static const REPORTS          = '/reports';
  static const SETTINGS         = '/settings';
}
