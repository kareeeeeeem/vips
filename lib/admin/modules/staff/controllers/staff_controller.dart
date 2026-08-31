import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../core/admin_toast.dart';
import '../../../services/admin_api_service.dart';
import '../../auth/controllers/admin_auth_controller.dart';

/// Console operators — admin accounts with a role.
///
/// Distinct from the merchant-side `Staff` model (a shop's own employees with
/// salary and leave), which lives under /api/merchant/staff and belongs to
/// the merchant app.
class StaffController extends AdminListController {
  /// The four built-in roles, in ascending order of reach.
  static const List<String> builtInRoles = [
    'viewer',
    'manager',
    'admin',
    'super_admin',
  ];

  final RxString roleFilter = ''.obs;

  // ── Catalogue ──
  final RxList<String> allPermissions = <String>[].obs;
  final RxMap<String, List<String>> rolePermissions = <String, List<String>>{}.obs;
  final RxList<Map<String, dynamic>> customRoles = <Map<String, dynamic>>[].obs;

  // ── Details ──
  final RxBool isLoadingDetails = false.obs;
  final Rxn<Map<String, dynamic>> details = Rxn<Map<String, dynamic>>();

  AdminAuthController get _auth => Get.find<AdminAuthController>();

  @override
  void onInit() {
    super.onInit();
    loadCatalogue();
  }

  @override
  Future<ApiResponse> fetch() => api.staff(
        page: page.value,
        limit: 20,
        search: search.value,
        adminRole: roleFilter.value,
      );

  Future<void> loadCatalogue() async {
    try {
      final response = await api.permissionCatalogue();
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final perms = data['permissions'];
        if (perms is List) {
          allPermissions.value = perms.map((p) => p.toString()).toList();
        }
        final built = adminItems(data, 'builtInRoles');
        rolePermissions.value = {
          for (final role in built)
            adminString(role['name']): (role['permissions'] is List
                ? (role['permissions'] as List).map((p) => p.toString()).toList()
                : <String>[]),
        };
        customRoles.value = adminItems(data, 'customRoles');
      }
    } catch (e) {
      debugPrint('[ADMIN STAFF] loadCatalogue failed: $e');
    }
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
      final response = await api.staffMember(id);
      if (response.success && response.data is Map) {
        details.value = Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('[ADMIN STAFF] loadDetails failed: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  // ── Permission-aware UI state ─────────────────────────────
  // Every one of these is enforced server-side as well; disabling the control
  // just means the operator is told before the tap rather than after it.

  bool get canWrite => _auth.can('staff.write');
  bool get canDelete => _auth.can('staff.delete');

  /// Only a super admin may create or promote to super admin.
  bool canAssignRole(String role) =>
      role != 'super_admin' || _auth.isSuperAdmin;

  bool isSelf(Map<String, dynamic> staff) =>
      adminString(staff['_id']) == _auth.adminId.value;

  /// The server refuses to remove the last admin or your own account.
  String? deleteBlockedReason(Map<String, dynamic> staff) {
    if (isSelf(staff)) return 'You cannot remove your own account.';
    if (!canDelete) return 'Your role does not allow removing operators.';
    if (adminString(staff['adminRole']) == 'super_admin' && !_auth.isSuperAdmin) {
      return 'Only a super admin can remove another super admin.';
    }
    if (total.value <= 1) return 'The last admin cannot be removed.';
    return null;
  }

  // ── Writes ────────────────────────────────────────────────

  Future<bool> createStaff({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String adminRole,
    required List<String> permissions,
  }) =>
      mutate(
        () => api.createStaff(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
          adminRole: adminRole,
          permissions: permissions,
        ),
        successTitle: 'Operator added',
        failureTitle: 'Could not add operator',
      );

  Future<bool> updateStaff(String id, Map<String, dynamic> changes) async {
    if (changes.isEmpty) {
      adminToast('Nothing changed', 'No fields were edited.', isError: false);
      return false;
    }
    final ok = await mutate(
      () => api.updateStaff(id, changes),
      successTitle: 'Operator updated',
      failureTitle: 'Could not update operator',
      reload: false,
    );
    if (ok) await loadDetails(id);
    return ok;
  }

  Future<bool> deleteStaff(String id) => mutate(
        () => api.deleteStaff(id),
        successTitle: 'Operator removed',
        failureTitle: 'Could not remove operator',
      );

  Future<bool> setActive(String id, bool active) =>
      updateStaff(id, {'isActive': active});

  // ── Custom roles ──────────────────────────────────────────

  Future<bool> createRole(String name, String description, List<String> permissions) async {
    final ok = await mutate(
      () => api.createRole(name: name, description: description, permissions: permissions),
      successTitle: 'Role created',
      failureTitle: 'Could not create role',
      reload: false,
    );
    if (ok) await loadCatalogue();
    return ok;
  }

  Future<bool> deleteRole(String id) async {
    final ok = await mutate(
      () => api.deleteRole(id),
      successTitle: 'Role deleted',
      failureTitle: 'Could not delete role',
      reload: false,
    );
    if (ok) await loadCatalogue();
    return ok;
  }

  /// Permissions grouped by module, for a checklist that reads in sections
  /// rather than as one wall of 27 chips.
  Map<String, List<String>> get permissionsByModule {
    final grouped = <String, List<String>>{};
    for (final permission in allPermissions) {
      final module = permission.split('.').first;
      grouped.putIfAbsent(module, () => []).add(permission);
    }
    return grouped;
  }
}
