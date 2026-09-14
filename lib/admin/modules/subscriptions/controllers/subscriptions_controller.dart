import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../core/admin_list_controller.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class AdminSubscriptionsController extends AdminListController {
  final audience = 'customer'.obs;
  final status = ''.obs;
  final paymentStatus = ''.obs;

  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>()
          ? Get.find<AdminAuthController>()
          : null;
  bool get canUpdate => _auth?.can('subscriptions.update') ?? false;
  bool get canReviewPayment =>
      _auth?.can('subscriptions.review_payment') ?? false;

  @override
  Future<ApiResponse> fetch() => api.subscriptions(
    audience: audience.value,
    page: page.value,
    search: search.value.isEmpty ? null : search.value,
    status: status.value.isEmpty ? null : status.value,
    paymentStatus:
        audience.value == 'customer' && paymentStatus.value.isNotEmpty
            ? paymentStatus.value
            : null,
  );

  void setAudience(String value) {
    audience.value = value;
    if (value != 'customer') paymentStatus.value = '';
    load(resetPage: true);
  }

  void setPaymentStatus(String value) {
    paymentStatus.value = value;
    load(resetPage: true);
  }

  void setStatus(String value) {
    status.value = value;
    load(resetPage: true);
  }

  Future<bool> setActive(String id, bool active) => mutate(
    () => api.updateSubscription(audience.value, id, {'isActive': active}),
    successTitle: active ? 'Subscription restored' : 'Subscription suspended',
    failureTitle: 'Could not update subscription',
  );

  Future<bool> reviewPayment(String id, String action, {String reason = ''}) =>
      mutate(
        () => api.reviewSubscriptionPayment(id, action, reason: reason),
        successTitle:
            action == 'approve' ? 'Payment approved' : 'Payment rejected',
        failureTitle: 'Could not review payment',
      );
}
