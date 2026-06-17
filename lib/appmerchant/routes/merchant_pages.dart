import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_home/bindings/merchant_home_binding.dart';
import '../modules/merchant_auth/views/merchant_login_view.dart';
import '../modules/merchant_auth/views/merchant_verification_view.dart';
import '../modules/merchant_home/views/merchant_home_view.dart';
import '../modules/merchant_settings/views/merchant_settings_view.dart';
import '../modules/merchant_settings/views/merchant_terms_view.dart';
import '../modules/merchant_settings/views/merchant_privacy_view.dart';
import '../modules/merchant_partnership/bindings/merchant_partnership_binding.dart';
import '../modules/merchant_partnership/views/merchant_onboarding_view.dart';
import '../modules/merchant_partnership/views/merchant_reward_setup_view.dart';
import '../modules/merchant_partnership/views/merchant_partnership_success_view.dart';
import '../modules/business_registration/bindings/business_registration_binding.dart';
import '../modules/business_registration/views/business_registration_view.dart';
import '../modules/business_registration/views/address_details_view.dart';
import '../modules/business_registration/views/social_media_setup_view.dart';
import '../modules/business_registration/views/qr_receive_view.dart';

import '../modules/merchant_ads/bindings/merchant_ads_binding.dart';
import '../modules/merchant_ads/views/new_advertisement_view.dart';

import '../modules/merchant_billing/bindings/merchant_billing_binding.dart';
import '../modules/merchant_billing/views/bill_inquiry_view.dart';
import '../modules/merchant_billing/views/pin_verification_view.dart';
import '../modules/merchant_billing/views/bill_error_view.dart';
import '../modules/merchant_billing/views/merchant_scan_me_view.dart';
import '../modules/merchant_billing/views/invoice_receipt_view.dart';
import '../modules/merchant_catalog/bindings/merchant_catalog_binding.dart';
import '../modules/merchant_catalog/views/create_item_view.dart';
import '../modules/merchant_catalog/views/create_voucher_view.dart';
import '../modules/merchant_catalog/views/create_coupon_view.dart';
import '../modules/merchant_catalog/views/merchant_catalog_view.dart';

import '../modules/merchant_subscription/bindings/merchant_subscription_binding.dart';
import '../modules/merchant_subscription/views/my_business_plan_view.dart';
import '../modules/merchant_subscription/views/subscription_packages_view.dart';
import '../modules/merchant_subscription/views/plan_migration_view.dart';
import '../modules/merchant_gift_back/bindings/merchant_gift_back_binding.dart';
import '../modules/merchant_gift_back/views/gift_back_form_view.dart';
import '../modules/merchant_gift_back/views/gift_back_inquiry_view.dart';
import '../modules/merchant_gift_back/views/gift_back_pin_view.dart';
import '../modules/merchant_gift_back/views/gift_back_scan_me_view.dart';
import '../modules/merchant_gift_back/views/gift_back_status_view.dart';
import '../modules/merchant_orders/bindings/merchant_order_binding.dart';
import '../modules/merchant_orders/views/merchant_orders_view.dart';
import '../modules/merchant_orders/views/merchant_order_detail_view.dart';
import '../modules/merchant_splash/views/merchant_splash_view.dart';
import '../modules/merchant_notifications/views/merchant_notifications_view.dart';
import '../modules/merchant_wallet/bindings/merchant_wallet_binding.dart';
import '../modules/merchant_wallet/views/merchant_wallet_view.dart';
import '../modules/merchant_billing/views/merchant_create_bill_view.dart';
import '../modules/merchant_customers/views/merchant_customers_view.dart';
import '../modules/merchant_settings/views/merchant_settings_view.dart';
import '../modules/merchant_cashiers/views/merchant_cashiers_view.dart';
import '../modules/merchant_reviews/views/merchant_reviews_view.dart';
import '../modules/merchant_credit/bindings/merchant_credit_binding.dart';
import '../modules/merchant_credit/views/merchant_credit_form_view.dart';
import '../modules/merchant_credit/views/merchant_credit_inquiry_view.dart';
import '../modules/merchant_finance/bindings/merchant_finance_binding.dart';
import '../modules/merchant_finance/views/finance_dashboard_view.dart';
import '../modules/merchant_finance/views/add_transaction_view.dart';
import '../modules/merchant_finance/views/accounts_view.dart';
import '../modules/merchant_dues/bindings/merchant_dues_binding.dart';
import '../modules/merchant_dues/views/due_list_view.dart';
import '../modules/merchant_stock/bindings/merchant_stock_binding.dart';
import '../modules/merchant_stock/views/stock_list_view.dart';
import '../modules/merchant_tax/bindings/merchant_tax_binding.dart';
import '../modules/merchant_tax/views/tax_rates_view.dart';
import '../modules/merchant_hrm/bindings/merchant_hrm_binding.dart';
import '../modules/merchant_hrm/views/staff_management_view.dart';
import '../modules/merchant_assets/bindings/merchant_asset_binding.dart';
import '../modules/merchant_assets/views/asset_management_view.dart';
import '../modules/merchant_barcode/views/barcode_generator_view.dart';
import '../modules/merchant_profile_manager/bindings/merchant_profile_binding.dart';
import '../modules/merchant_profile_manager/views/business_switcher_view.dart';
import '../modules/merchant_profile_manager/views/merchant_store_profile_view.dart';

import 'merchant_routes.dart';

class MerchantAppPages {
  MerchantAppPages._();

  static const INITIAL = MerchantRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: MerchantRoutes.SPLASH,
      page: () => const MerchantSplashView(),
    ),
    GetPage(
      name: MerchantRoutes.NOTIFICATIONS,
      page: () => const MerchantNotificationsView(),
    ),
    GetPage(
      name: MerchantRoutes.WALLET,
      page: () => const MerchantWalletView(),
      binding: MerchantWalletBinding(),
    ),
    GetPage(
      name: MerchantRoutes.CREATE_BILL,
      page: () => const MerchantCreateBillView(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: MerchantRoutes.CUSTOMERS,
      page: () => const MerchantCustomersView(),
    ),
    GetPage(
      name: MerchantRoutes.SETTINGS,
      page: () => const MerchantSettingsView(),
    ),
    GetPage(
      name: MerchantRoutes.CASHIERS,
      page: () => const MerchantCashiersView(),
    ),
    GetPage(
      name: MerchantRoutes.REVIEWS,
      page: () => const MerchantReviewsView(),
    ),
    GetPage(name: MerchantRoutes.LOGIN, page: () => const MerchantLoginView()),
    GetPage(
      name: MerchantRoutes.VERIFICATION,
      page: () => const MerchantVerificationView(),
    ),
    GetPage(
      name: MerchantRoutes.HOME,
      page: () => const MerchantHomeView(),
      binding: MerchantHomeBinding(),
    ),
    GetPage(
      name: MerchantRoutes.SETTINGS,
      page: () => const MerchantSettingsView(),
    ),
    GetPage(name: MerchantRoutes.TERMS, page: () => const MerchantTermsView()),
    GetPage(
      name: MerchantRoutes.PRIVACY,
      page: () => const MerchantPrivacyView(),
    ),
    GetPage(
      name: MerchantRoutes.ONBOARDING,
      page: () => const MerchantOnboardingView(),
      binding: MerchantPartnershipBinding(),
    ),
    GetPage(
      name: MerchantRoutes.REWARD_SETUP,
      page: () => const MerchantRewardSetupView(),
      binding: MerchantPartnershipBinding(),
    ),
    GetPage(
      name: MerchantRoutes.SUCCESS,
      page: () => const MerchantPartnershipSuccessView(),
      binding: MerchantPartnershipBinding(),
    ),
    GetPage(
      name: MerchantRoutes.BUSINESS_REGISTRATION,
      page: () => const BusinessRegistrationView(),
      binding: BusinessRegistrationBinding(),
    ),
    GetPage(
      name: MerchantRoutes.ADDRESS_DETAILS,
      page: () => const AddressDetailsView(),
    ),
    GetPage(
      name: MerchantRoutes.SOCIAL_MEDIA_SETUP,
      page: () => const SocialMediaSetupView(),
    ),
    GetPage(name: MerchantRoutes.QR_RECEIVE, page: () => const QrReceiveView()),
    GetPage(
      name: MerchantRoutes.ADD_ADVERTISEMENT,
      page: () => const NewAdvertisementView(),
      binding: MerchantAdsBinding(),
    ),
    GetPage(
      name: MerchantRoutes.BILL_INQUIRY,
      page: () => const BillInquiryView(),
      binding: MerchantBillingBinding(),
    ),
    GetPage(
      name: MerchantRoutes.BILL_PIN,
      page: () => const PinVerificationView(),
      binding: MerchantBillingBinding(),
    ),
    GetPage(
      name: MerchantRoutes.BILL_ERROR,
      page: () => const BillErrorView(),
      binding:
          MerchantBillingBinding(), // Error might not need binding but keeping consistent
    ),
    GetPage(
      name: MerchantRoutes.BILL_SCAN_ME,
      page: () => const MerchantScanMeView(),
      binding: MerchantBillingBinding(),
    ),
    GetPage(
      name: MerchantRoutes.INVOICE_RECEIPT,
      page: () => const InvoiceReceiptView(),
      binding: MerchantBillingBinding(),
    ),
    GetPage(
      name: MerchantRoutes.CREATE_ITEM,
      page: () => const CreateItemView(),
      binding: MerchantCatalogBinding(),
    ),
    GetPage(
      name: MerchantRoutes.CREATE_VOUCHER,
      page: () => const CreateVoucherView(),
      binding: MerchantCatalogBinding(),
    ),
    GetPage(
      name: MerchantRoutes.CREATE_COUPON,
      page: () => const CreateCouponView(),
      binding: MerchantCatalogBinding(),
    ),
    GetPage(
      name: MerchantRoutes.CATALOG,
      page: () => const MerchantCatalogView(),
      binding: MerchantCatalogBinding(),
    ),
    GetPage(
      name: MerchantRoutes.BUSINESS_PLAN,
      page: () => const MyBusinessPlanView(),
      binding: MerchantSubscriptionBinding(),
    ),
    GetPage(
      name: MerchantRoutes.SUBSCRIPTION_PACKAGES,
      page: () => const SubscriptionPackagesView(),
      binding: MerchantSubscriptionBinding(),
    ),
    GetPage(
      name: MerchantRoutes.PLAN_MIGRATION,
      page: () => const PlanMigrationView(),
      binding: MerchantSubscriptionBinding(),
    ),
    GetPage(
      name: MerchantRoutes.GIFT_BACK_FORM,
      page: () => const GiftBackFormView(),
      binding: MerchantGiftBackBinding(),
    ),
    GetPage(
      name: MerchantRoutes.GIFT_BACK_INQUIRY,
      page: () => const GiftBackInquiryView(),
      binding: MerchantGiftBackBinding(),
    ),
    GetPage(
      name: MerchantRoutes.GIFT_BACK_PIN,
      page: () => const GiftBackPinView(),
      binding: MerchantGiftBackBinding(),
    ),
    GetPage(
      name: MerchantRoutes.GIFT_BACK_STATUS,
      page: () => const GiftBackStatusView(),
      binding: MerchantGiftBackBinding(),
    ),
    GetPage(
      name: MerchantRoutes.GIFT_BACK_SCAN_ME,
      page: () => const GiftBackScanMeView(),
      binding: MerchantGiftBackBinding(),
    ),
    GetPage(
      name: MerchantRoutes.ORDERS,
      page: () => const MerchantOrdersView(),
      binding: MerchantOrderBinding(),
    ),
    GetPage(
      name: MerchantRoutes.ORDER_DETAIL,
      page: () => const MerchantOrderDetailView(),
      binding: MerchantOrderBinding(),
    ),
    GetPage(
      name: MerchantRoutes.MERCHANT_CREDIT_FORM,
      page: () => const MerchantCreditFormView(),
      binding: MerchantCreditBinding(),
    ),
    GetPage(
      name: MerchantRoutes.MERCHANT_CREDIT_INQUIRY,
      page: () => const MerchantCreditInquiryView(),
      binding: MerchantCreditBinding(),
    ),
    GetPage(
      name: MerchantRoutes.FINANCE_DASHBOARD,
      page: () => const FinanceDashboardView(),
      binding: MerchantFinanceBinding(),
    ),
    GetPage(
      name: MerchantRoutes.ADD_TRANSACTION,
      page: () => const AddTransactionView(),
      binding: MerchantFinanceBinding(),
    ),
    GetPage(
      name: MerchantRoutes.ACCOUNTS,
      page: () => const AccountsView(),
      binding: MerchantFinanceBinding(),
    ),
    GetPage(
      name: MerchantRoutes.DUE_LIST,
      page: () => const DueListView(),
      binding: MerchantDuesBinding(),
    ),
    GetPage(
      name: MerchantRoutes.STOCK_LIST,
      page: () => const StockListView(),
      binding: MerchantStockBinding(),
    ),
    GetPage(
      name: MerchantRoutes.TAX_RATES,
      page: () => const TaxRatesView(),
      binding: MerchantTaxBinding(),
    ),
    GetPage(
      name: MerchantRoutes.STAFF_MANAGEMENT,
      page: () => const StaffManagementView(),
      binding: MerchantHRMBinding(),
    ),
    GetPage(
      name: MerchantRoutes.STAFF_LEDGER,
      page:
          () =>
              const StaffManagementView(), // Reuse for now or create specialized ledger
      binding: MerchantHRMBinding(),
    ),
    GetPage(
      name: MerchantRoutes.HRM,
      page: () => const StaffManagementView(),
      binding: MerchantHRMBinding(),
    ),
    GetPage(
      name: MerchantRoutes.ASSET_MANAGEMENT,
      page: () => const AssetManagementView(),
      binding: MerchantAssetBinding(),
    ),
    GetPage(
      name: MerchantRoutes.BARCODE_GEN,
      page: () => const BarcodeGeneratorView(),
    ),
    GetPage(
      name: MerchantRoutes.SWITCH_BUSINESS,
      page: () => const BusinessSwitcherView(),
      binding: MerchantProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: MerchantRoutes.STORE_PROFILE,
      page: () => const MerchantStoreProfileView(),
      binding: MerchantProfileBinding(),
    ),
  ];
}
