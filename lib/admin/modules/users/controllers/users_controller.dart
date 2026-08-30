import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../services/admin_api_service.dart';

class AdminUsersController extends AdminListController {
  /// '' | 'active' | 'banned'
  final RxString statusFilter = ''.obs;

  /// '' (all non-admin roles handled by the backend default) | a role name
  final RxString roleFilter = 'customer'.obs;

  // Details sheet state — kept here so the sheet can rebuild reactively
  // while its fetch is in flight.
  final RxBool isLoadingDetails = false.obs;
  final Rxn<Map<String, dynamic>> details = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    // The dashboard's "banned accounts" alert deep-links here with a filter
    // already applied; read it before the first load so the screen does not
    // fetch the unfiltered list and then immediately refetch.
    final args = Get.arguments;
    if (args is Map) {
      if (args['status'] is String) statusFilter.value = args['status'] as String;
      if (args['role'] is String) roleFilter.value = args['role'] as String;
    }
    super.onInit();
  }

  @override
  Future<ApiResponse> fetch() => api.users(
        page: page.value,
        limit: 20,
        search: search.value,
        role: roleFilter.value,
        status: statusFilter.value,
      );

  void setStatusFilter(String value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    load(resetPage: true);
  }

  void setRoleFilter(String value) {
    if (roleFilter.value == value) return;
    roleFilter.value = value;
    load(resetPage: true);
  }

  Future<void> loadDetails(String id) async {
    isLoadingDetails.value = true;
    details.value = null;
    try {
      final response = await api.userDetails(id);
      if (response.success && response.data is Map) {
        details.value = Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('[ADMIN USERS] loadDetails failed: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<bool> setBanned(String id, bool banned) => mutate(
        () => api.banUser(id, banned),
        successTitle: banned ? 'User banned' : 'User reinstated',
      );

  Future<bool> changeRole(String id, String role) => mutate(
        () => api.changeUserRole(id, role),
        successTitle: 'Role updated',
      );

  Future<bool> deleteUser(String id) => mutate(
        () => api.deleteUser(id),
        successTitle: 'User deleted',
      );

  /// Whether a row is currently banned. `isActive` defaults to true on the
  /// model, so a missing field must read as active, not banned.
  bool isBanned(Map<String, dynamic> user) => adminBool(user['isActive'], true) == false;
}
