import 'package:get/get.dart';

import '../modules/Cart/bindings/cart_binding.dart';
import '../modules/Cart/views/cart_view.dart' hide CartBinding;
import '../modules/Donation/bindings/donation_binding.dart';
import '../modules/Donation/views/donation_view.dart';
import '../modules/QR_scanner/bindings/q_r_scanner_binding.dart';
import '../modules/QR_scanner/views/q_r_scanner_view.dart';
import '../modules/bills/bindings/bills_binding.dart';
import '../modules/bills/views/bills_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart' hide CheckoutBinding;
import '../modules/contact/bindings/contact_binding.dart';
import '../modules/contact/views/contact_view.dart';
import '../modules/coupon/bindings/coupon_binding.dart';
import '../modules/coupon/views/coupon_view.dart';
import '../modules/createpin/bindings/createpin_binding.dart';
import '../modules/createpin/views/createpin_view.dart';
import '../modules/credit/bindings/credit_binding.dart';
import '../modules/credit/views/credit_view.dart';
import '../modules/delivery_driver/bindings/delivery_driver_binding.dart';
import '../modules/delivery_driver/views/delivery_driver_view.dart';
import '../modules/delivery_order_details/bindings/delivery_order_details_binding.dart';
import '../modules/delivery_order_details/views/delivery_order_details_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/expense_to_reward/bindings/expense_to_reward_binding.dart';
import '../modules/expense_to_reward/views/expense_to_reward_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/gift/bindings/gift_binding.dart';
import '../modules/gift/views/gift_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_app/bindings/main_app_binding.dart';
import '../modules/main_app/views/main_app_view.dart';
import '../modules/mobile/bindings/mobile_binding.dart';
import '../modules/mobile/views/mobile_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/packages/bindings/packages_binding.dart';
import '../modules/packages/views/packages_view.dart';
import '../modules/pay_bills/bindings/pay_bills_binding.dart';
import '../modules/pay_bills/views/pay_bills_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/promotions/bindings/promotions_binding.dart';
import '../modules/promotions/views/promotions_view.dart'
    hide PromotionsBinding;
import '../modules/report/bindings/report_binding.dart';
import '../modules/report/views/report_view.dart';
import '../modules/reset_password/bindings/reset_password_binding.dart';
import '../modules/reset_password/views/reset_password_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shipping/bindings/shipping_binding.dart';
import '../modules/shipping/views/shipping_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';
import '../modules/spin_wheel/bindings/spin_wheel_binding.dart';
import '../modules/spin_wheel/views/spin_wheel_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/success_account/bindings/success_account_binding.dart';
import '../modules/success_account/views/success_account_view.dart';
import '../modules/teams/bindings/teams_binding.dart';
import '../modules/teams/views/teams_view.dart';
import '../modules/transactions_extract/bindings/transactions_extract_binding.dart';
import '../modules/transactions_extract/views/transactions_extract_view.dart';
import '../modules/vIPsClub/bindings/v_i_ps_club_binding.dart';
import '../modules/vIPsClub/views/v_i_ps_club_view.dart';
import '../modules/vendor_home/bindings/vendor_home_binding.dart';
import '../modules/vendor_home/views/vendor_home_view.dart';
import '../modules/vendor_order/bindings/vendor_order_binding.dart';
import '../modules/vendor_order/views/vendor_order_view.dart';
import '../modules/verification/bindings/verification_binding.dart';
import '../modules/verification/views/verification_view.dart';
import '../modules/vips_club_history/bindings/vips_club_history_binding.dart';
import '../modules/vips_club_history/views/vips_club_history_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(fromOffer: true),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(name: _Paths.CART, page: () => CartView(), binding: CartBinding()),
    GetPage(
      name: _Paths.BILLS,
      page: () => BillsView(),
      binding: BillsBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_APP,
      page: () => const MainAppView(),
      binding: MainAppBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION,
      page: () => const VerificationView(false),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: _Paths.CREATEPIN,
      page: () => const CreatepinView(),
      binding: CreatepinBinding(),
    ),
    GetPage(
      name: _Paths.SUCCESS_ACCOUNT,
      page: () => const SuccessAccountView(),
      binding: SuccessAccountBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.CONTACT,
      page: () => const ContactView(),
      binding: ContactBinding(),
    ),
    GetPage(
      name: _Paths.DONATION,
      page: () => const DonationView(),
      binding: DonationBinding(),
    ),
    GetPage(
      name: _Paths.SHIPPING,
      page: () => const ShippingView(),
      binding: ShippingBinding(),
    ),
    GetPage(
      name: _Paths.MOBILE,
      page: () => const MobilesView(),
      binding: MobileBinding(),
    ),
    GetPage(
      name: _Paths.PAY_BILLS,
      page: () => const PayBillsView(),
      binding: PayBillsBinding(),
    ),
    GetPage(
      name: _Paths.GIFT,
      page: () => const GiftView(),
      binding: GiftBinding(),
    ),
    GetPage(
      name: _Paths.EXPENSE_TO_REWARD,
      page: () => const ExpenseToRewardView(),
      binding: ExpenseToRewardBinding(),
      children: [
        GetPage(
          name: _Paths.EXPENSE_TO_REWARD,
          page: () => const ExpenseToRewardView(),
          binding: ExpenseToRewardBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.TRANSACTIONS_EXTRACT,
      page: () => const TransactionsExtractView(),
      binding: TransactionsExtractBinding(),
    ),
    GetPage(
      name: _Paths.CREDIT,
      page: () => const CreditView(),
      binding: CreditBinding(),
    ),
    GetPage(
      name: _Paths.COUPON,
      page: () => const CouponView(),
      binding: CouponBinding(),
    ),
    GetPage(
      name: _Paths.TEAMS,
      page: () => const TeamsView(),
      binding: TeamsBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const ReportView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: _Paths.VENDOR_HOME,
      page: () => const VendorHomeView(),
      binding: VendorHomeBinding(),
    ),
    GetPage(
      name: _Paths.VENDOR_ORDER,
      page: () => const VendorOrderView(),
      binding: VendorOrderBinding(),
    ),
    GetPage(
      name: _Paths.Q_R_SCANNER,
      page: () => QRScannerView(),
      binding: QRScannerBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_DRIVER,
      page: () => const DeliveryDriverView(),
      binding: DeliveryDriverBinding(),
    ),
    GetPage(
      name: _Paths.DELIVERY_ORDER_DETAILS,
      page: () => const DeliveryOrderDetailsView(),
      binding: DeliveryOrderDetailsBinding(),
    ),
    GetPage(
      name: _Paths.VIPS_CLUB_HISTORY,
      page: () => const VipsClubHistoryView(),
      binding: VipsClubHistoryBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: _Paths.PROMOTIONS,
      page: () => const PromotionsView(),
      binding: PromotionsBinding(),
    ),
    GetPage(
      name: _Paths.PACKAGES,
      page: () => const PackagesView(),
      binding: PackagesBinding(),
    ),
    GetPage(
      name: _Paths.V_I_PS_CLUB,
      page: () => const VIPsClubView(),
      binding: VIPsClubBinding(),
    ),
    GetPage(
      name: _Paths.SPIN_WHEEL,
      page: () => const SpinWheelView(),
      binding: SpinWheelBinding(),
    ),
  ];
}
