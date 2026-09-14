import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../core/admin_list_controller.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class AdminAdsController extends AdminListController {
  final moderation = ''.obs;
  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>()
          ? Get.find<AdminAuthController>()
          : null;
  bool get canModerate => _auth?.can('ads.moderate') ?? false;

  @override
  Future<ApiResponse> fetch() => api.advertisements(
    page: page.value,
    search: search.value.isEmpty ? null : search.value,
    moderation: moderation.value.isEmpty ? null : moderation.value,
  );

  void setModeration(String value) {
    moderation.value = value;
    load(resetPage: true);
  }

  Future<bool> decide(String id, String decision, {String reason = ''}) =>
      mutate(
        () => api.moderateAdvertisement(id, decision, reason: reason),
        successTitle:
            decision == 'approved'
                ? 'Advertisement approved'
                : 'Advertisement rejected',
        failureTitle: 'Could not review advertisement',
      );
}
