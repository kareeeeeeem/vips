import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../core/admin_list_controller.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class AdminWalletsController extends AdminListController {
  final role = ''.obs;
  final totals = <String, dynamic>{}.obs;
  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>()
          ? Get.find<AdminAuthController>()
          : null;
  bool get canAdjust => _auth?.can('wallets.adjust') ?? false;

  @override
  Future<ApiResponse> fetch() => api.wallets(
    page: page.value,
    search: search.value.isEmpty ? null : search.value,
    role: role.value.isEmpty ? null : role.value,
  );

  @override
  void parse(Map<String, dynamic> data) =>
      totals.value =
          data['totals'] is Map
              ? Map<String, dynamic>.from(data['totals'] as Map)
              : {};

  void setRole(String value) {
    role.value = value;
    load(resetPage: true);
  }

  Future<bool> adjust(String id, String unit, num delta, String reason) =>
      mutate(
        () => api.adjustWallet(id, unit: unit, delta: delta, reason: reason),
        successTitle: 'Adjustment recorded',
        failureTitle: 'Adjustment rejected',
      );
}
