import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import '../../../core/admin_list_controller.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class AdminBroadcastsController extends AdminListController {
  AdminAuthController? get _auth =>
      Get.isRegistered<AdminAuthController>()
          ? Get.find<AdminAuthController>()
          : null;
  bool get canSend => _auth?.can('broadcasts.send') ?? false;

  @override
  Future<ApiResponse> fetch() => api.broadcasts(page: page.value);

  Future<bool> send({
    required String title,
    required String message,
    required String audience,
    required String type,
    String actionUrl = '',
  }) => mutate(
    () => api.sendBroadcast(
      title: title,
      message: message,
      audience: audience,
      type: type,
      actionUrl: actionUrl,
    ),
    successTitle: 'Broadcast sent',
    failureTitle: 'Could not send broadcast',
  );
}
