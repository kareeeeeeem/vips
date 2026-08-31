import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../auth/controllers/admin_auth_controller.dart';

/// The people the till has sold to.
///
/// A walk-in has no account until somebody adds one, so this list is the
/// customers a cashier can attach to a sale — not every registered customer,
/// which is the Users screen.
class PosCustomersController extends AdminListController {
  final RxBool isCreating = false.obs;

  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>() ? Get.find<AdminAuthController>() : null;

  /// Adding a till customer creates a real account, so it needs the same
  /// grant as creating one anywhere else.
  bool get canCreate => _auth?.can('users.create') ?? false;

  @override
  Future<ApiResponse> fetch() =>
      api.posCustomers(search: search.value.isEmpty ? null : search.value, limit: 50);

  @override
  void parse(Map<String, dynamic> data) {
    // This endpoint answers with a flat list rather than the paginated
    // envelope the other list screens use, so the paginator is told there is
    // exactly one page instead of showing a stale count from a previous load.
    pages.value = 1;
    page.value = 1;
    total.value = items.length;
  }

  Future<bool> createCustomer({
    required String fullName,
    required String phone,
    String? email,
  }) =>
      mutate(
        () => api.posCreateCustomer(fullName: fullName, phone: phone, email: email),
        successTitle: 'Customer added',
        failureTitle: 'Could not add the customer',
      );
}
