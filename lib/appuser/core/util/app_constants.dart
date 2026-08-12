class AppConstants {
  static const String appName = 'VIPs';
  static const double appVersion = 1.0;

  static const String fontFamily = 'Roboto';
  static const double limitOfPickedVideoSizeInMB = 50;
  static const double maxSizeOfASingleFile = 10;

  // Base URL for the VIPs backend — update for production deployment
  static const String baseUrl = 'https://vips-backend.onrender.com';

  // ─── VIPs API Endpoints ────────────────────────────────────────────────────
  // Auth
  static const String loginUri = '/api/auth/login';
  static const String registerUri = '/api/auth/register';
  static const String forgotPasswordUri = '/api/auth/forgot-password';
  static const String resetPasswordUri = '/api/auth/reset-password';
  static const String updateProfileUri = '/api/auth/update-profile';
  static const String meUri = '/api/auth/me';
  static const String verifyTokenUri = '/api/auth/verify-token';
  static const String merchantLoginUri = '/api/auth/merchant-login';
  static const String merchantVerifyOtpUri = '/api/auth/merchant-verify-otp';

  // User
  static const String walletUri = '/api/user/wallet';
  static const String notificationsUri = '/api/user/notifications';
  static const String transactionsUri = '/api/user/transactions';
  static const String transferUri = '/api/user/transfer';
  static const String vipsClubUri = '/api/user/vips-club';
  static const String checkInUri = '/api/user/vips-club/checkin';
  static const String convertPointsUri = '/api/user/vips-club/convert';
  static const String deleteAccountUri = '/api/user/account';
  static const String teamsUri = '/api/user/teams';
  static const String contactsUri = '/api/user/contacts';
  static const String leaderboardUri = '/api/user/leaderboard';
  static const String referralUri = '/api/user/referral';
  static const String useReferralUri = '/api/user/referral/use';
  static const String walletTopupUri = '/api/user/wallet/topup';
  static const String reportsUri = '/api/user/reports';

  // Content
  static const String hotDealsUri = '/api/content/hot-deals';
  static const String endingSoonDealsUri = '/api/content/ending-soon-deals';
  static const String outingsUri = '/api/content/outings';
  static const String trendingMerchantsUri = '/api/content/trending-merchants';
  static const String productsUri = '/api/content/products';
  static const String searchUri = '/api/content/search';
  static const String promotionsUri = '/api/content/promotions';
  static const String catalogUri = '/api/content/catalog';

  // Orders
  static const String createOrderUri = '/api/order/create';
  static const String orderHistoryUri = '/api/order/history';
  static const String myOrdersUri = '/api/order/my-orders';
  static const String tripsUri = '/api/order/trips';

  // Legacy order constants (dead code from old module, kept for compile compatibility)
  static const String currentOrdersUri = '/api/order/my-orders';
  static const String completedOrdersUri = '/api/order/history';
  static const String updatedOrderStatusUri = '/api/order/my-orders';
  static const String orderDetailsUri = '/api/order/';
  static const String currentOrderDetailsUri = '/api/order/';
  static const String updateOrderUri = '/api/order/create';
  static const String orderCancellationUri = '/api/order/';
  static const String deliveredOrderNotificationUri = '/api/order/my-orders';

  // Services
  static const String billsUri = '/api/services/bills';
  static const String payBillUri = '/api/services/pay-bill';
  static const String packagesUri = '/api/services/packages';
  static const String subscribeUri = '/api/services/packages/subscribe';
  static const String mobileRechargeUri = '/api/services/mobile-recharge';
  static const String donateUri = '/api/services/donate';

  // Rewards
  static const String couponsUri = '/api/rewards/coupons';
  static const String expenseToRewardUri = '/api/rewards/expense-to-reward';
  static const String applyCouponUri = '/api/rewards/apply-coupon';
  static const String giftVouchersUri = '/api/rewards/gift-vouchers';
  static const String purchaseVoucherUri = '/api/rewards/purchase-voucher';
  static const String sendGiftUri = '/api/rewards/send-gift';
  static const String spinWheelUri = '/api/rewards/spin-wheel';
  static const String validateQrUri = '/api/rewards/validate-qr';

  // Cart
  static const String cartUri = '/api/cart';
  static const String cartAddUri = '/api/cart/add';
  static const String cartUpdateUri = '/api/cart/update';
  static const String cartClearUri = '/api/cart/clear';

  // Favorites
  static const String favoritesUri = '/api/favorites';
  static const String toggleFavoriteUri = '/api/favorites/toggle';

  // Merchant
  static const String merchantDashboardUri = '/api/merchant/dashboard';
  static const String merchantStatsUri = '/api/merchant/stats';
  static const String merchantWalletUri = '/api/merchant/wallet';
  static const String merchantProfileUri = '/api/merchant/profile';
  static const String merchantCustomersUri = '/api/merchant/customers';
  static const String merchantOrdersUri = '/api/merchant/orders';
  static const String merchantFinanceUri = '/api/merchant/finance';
  static const String merchantNotificationsUri = '/api/merchant/notifications';
  static const String merchantCashiersUri = '/api/merchant/cashiers';
  static const String merchantStockUri = '/api/merchant/stock';
  static const String merchantAssetsUri = '/api/merchant/assets';
  static const String merchantBillingUri = '/api/merchant/billing';
  static const String merchantAdsUri = '/api/merchant/ads';
  static const String merchantBarcodesUri = '/api/merchant/barcodes';
  static const String merchantCreditsUri = '/api/merchant/credits';
  static const String merchantPartnershipUri = '/api/merchant/partnership';
  static const String merchantSubscriptionUri = '/api/merchant/subscription';

  // ─── SharedPreferences Keys ───────────────────────────────────────────────
  static const String theme = 'vips_theme';
  static const String intro = 'vips_intro';
  static const String token = 'auth_token';
  static const String type = 'vips_user_type';
  static const String countryCode = 'vips_country_code';
  static const String languageCode = 'vips_language_code';
  static const String cacheCountryCode = 'cache_country_code';
  static const String cacheLanguageCode = 'cache_language_code';
  static const String cartList = 'vips_cart_list';
  static const String userPassword = 'vips_user_password';
  static const String userAddress = 'vips_user_address';
  static const String userNumber = 'vips_user_number';
  static const String userType = 'vips_user_type_key';
  static const String notification = 'vips_notification';
  static const String notificationCount = 'vips_notification_count';
  static const String searchHistory = 'vips_search_history';
  static const String bluetoothMacAddress = 'bluetooth_mac_address';
  static const String lowStockStatus = 'vips_low_stock';
  static const String moduleId = 'moduleId';
  static const String localizationKey = 'X-localization';

  // ─── Order Statuses ───────────────────────────────────────────────────────
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String accepted = 'accepted';
  static const String processing = 'processing';
  static const String handover = 'handover';
  static const String pickedUp = 'picked_up';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';
  static const String failed = 'failed';
  static const String refunded = 'refunded';

  // ─── User Roles ───────────────────────────────────────────────────────────
  static const String customer = 'customer';
  static const String merchant = 'merchant';
  static const String driver = 'driver';
  static const String admin = 'admin';

  // ─── FCM Topics ───────────────────────────────────────────────────────────
  static const String topic = 'all_vips_users';
  static const String merchantTopic = 'all_vips_merchants';
}
