import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class AdminOffersController extends AdminListController {
  final typeFilter = ''.obs;
  final statusFilter = ''.obs;

  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>()
          ? Get.find<AdminAuthController>()
          : null;
  bool get canUpdate => _auth?.can('offers.update') ?? false;
  bool get canDelete => _auth?.can('offers.delete') ?? false;

  @override
  Future<ApiResponse> fetch() => api.offers(
    page: page.value,
    search: search.value.isEmpty ? null : search.value,
    type: typeFilter.value.isEmpty ? null : typeFilter.value,
    status: statusFilter.value.isEmpty ? null : statusFilter.value,
  );

  void setType(String value) {
    typeFilter.value = value;
    load(resetPage: true);
  }

  void setStatus(String value) {
    statusFilter.value = value;
    load(resetPage: true);
  }

  Future<bool> setActive(String id, bool active) => mutate(
    () => api.setOfferActive(id, active),
    successTitle: active ? 'Offer activated' : 'Offer suspended',
    failureTitle: 'Could not update offer',
  );

  Future<bool> remove(String id) => mutate(
    () => api.deleteOffer(id),
    successTitle: 'Offer deleted',
    failureTitle: 'Could not delete offer',
  );
}
