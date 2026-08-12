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
  static const String baseUrl = 'https://vips-backend.onrender.com';

  // Auth
  static const String loginUri = '/api/auth/merchant-login';
  static const String forgetPasswordUri = '/api/auth/forgot-password';
  static const String verifyTokenUri = '/api/auth/verify-token';
  static const String resetPasswordUri = '/api/auth/reset-password';

  // Orders
  static const String allOrdersUri = '/api/merchant/orders';
  static const String currentOrdersUri = '/api/merchant/orders?status=pending';
  static const String completedOrdersUri = '/api/merchant/orders?status=delivered';
  static const String orderDetailsUri = '/api/merchant/orders/';
  static const String updatedOrderStatusUri = '/api/merchant/orders';
  static const String orderCancellationUri = '/api/merchant/orders';

  // Items/Catalog
  static const String itemListUri = '/api/merchant/products';
  static const String addItemUri = '/api/merchant/products';
  static const String updateItemUri = '/api/merchant/products';
  static const String deleteItemUri = '/api/merchant/products';
  static const String updateItemStatusUri = '/api/merchant/products';
  static const String itemStockUpdateUri = '/api/merchant/products';

  // Profile
  static const String profileUri = '/api/merchant/profile';
  static const String updateProfileUri = '/api/merchant/profile';

  // Notifications
  static const String notificationUri = '/api/merchant/notifications';

  // Storage keys
  static const String token = 'token';
  static const String type = 'type';
  static const String languageCode = 'language_code';
  static const String localizationKey = 'localization_key';
  static const String moduleId = 'module_id';
}
