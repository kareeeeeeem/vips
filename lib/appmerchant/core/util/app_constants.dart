import 'dart:ui';

class AppConstants {
  static const String appName = 'VIPsApp Merchant';
  static const double appVersion = 1.0;

  /// Colors
  static const Color merchantGreen = Color(0xFF10B981);
  static const Color merchantGreenDark = Color(0xFF059669);
  static const Color merchantGreenLight = Color(0xFF34D399);
  static const Color merchantBackground = Color(0xFFF9FAFB);
  static const Color merchantTextPrimary = Color(0xFF111827);
  static const Color merchantTextSecondary = Color(0xFF6B7280);
  static const Color merchantBorder = Color(0xFFE5E7EB);

  /// API Endpoints
  static const String baseUrl = 'https://api.vipsapp.com';

  // Auth
  static const String loginUri = '/api/v1/auth/vendor/login';
  static const String forgetPasswordUri = '/api/v1/auth/vendor/forgot-password';
  static const String verifyTokenUri = '/api/v1/auth/vendor/verify-token';
  static const String resetPasswordUri = '/api/v1/auth/vendor/reset-password';

  // Orders
  static const String allOrdersUri = '/api/v1/vendor/all-orders';
  static const String currentOrdersUri = '/api/v1/vendor/current-orders';
  static const String completedOrdersUri = '/api/v1/vendor/completed-orders';
  static const String orderDetailsUri =
      '/api/v1/vendor/order-details?order_id=';
  static const String updatedOrderStatusUri =
      '/api/v1/vendor/update-order-status';
  static const String orderCancellationUri =
      '/api/v1/vendor/order/cancel-reasons';

  // Items/Catalog
  static const String itemListUri = '/api/v1/vendor/get-items-list';
  static const String addItemUri = '/api/v1/vendor/item/store';
  static const String updateItemUri = '/api/v1/vendor/item/update';
  static const String deleteItemUri = '/api/v1/vendor/item/delete';
  static const String updateItemStatusUri = '/api/v1/vendor/item/status';
  static const String itemStockUpdateUri = '/api/v1/vendor/item/stock-update';

  // Profile
  static const String profileUri = '/api/v1/vendor/profile';
  static const String updateProfileUri = '/api/v1/vendor/update-profile';

  // Notifications
  static const String notificationUri = '/api/v1/vendor/notifications';

  // Storage keys
  static const String token = 'token';
  static const String type = 'type';
  static const String languageCode = 'language_code';
  static const String localizationKey = 'localization_key';
  static const String moduleId = 'module_id';
}
