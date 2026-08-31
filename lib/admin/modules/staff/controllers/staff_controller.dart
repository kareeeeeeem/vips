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
  /// The built-in roles, in ascending order of reach. Cashier sits beside
  /// viewer rather than above it: it can do more at the till and less
  /// everywhere else, so the two are not on one ladder.
  static const List<String> builtInRoles = [
    'viewer',
    'cashier',
    'manager',
    'admin',
    'super_admin',
  ];

  final RxString roleFilter = ''.obs;

  // ── Catalogue ──
  final RxList<String> allPermissions = <String>[].obs;
  final RxMap<String, List<String>> rolePermissions = <String, List<String>>{}.obs;
  final RxList<Map<String, dynamic>> customRoles = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCatalogue = false.obs;

  /// The descriptive catalogue: what each permission means and whether it
  /// gates anything yet. Keyed by permission string.
  final RxMap<String, Map<String, dynamic>> catalogue =
      <String, Map<String, dynamic>>{}.obs;

  /// Module order as the server declares it, so the console groups
  /// permissions the same way rather than alphabetically by accident.
  final RxList<String> moduleOrder = <String>[].obs;
  final RxMap<String, List<String>> moduleActions = <String, List<String>>{}.obs;

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
    isLoadingCatalogue.value = true;
    try {
      final response = await api.permissionCatalogue();
      if (response.success && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final perms = data['permissions'];
        if (perms is List) {
          allPermissions.value = perms.map((p) => p.toString()).toList();
        }
        for (final entry in adminItems(data, 'catalogue')) {
          catalogue[adminString(entry['key'])] = entry;
        }
        final modules = adminItems(data, 'modules');
        moduleOrder.value = modules.map((m) => adminString(m['name'])).toList();
        moduleActions.value = {
          for (final m in modules)
            adminString(m['name']): (m['actions'] is List
                ? (m['actions'] as List).map((a) => a.toString()).toList()
                : <String>[]),
        };
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
    } finally {
      isLoadingCatalogue.value = false;
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
    // Their name signs every receipt, till session and stock movement they
    // touched. Deleting the account does not remove those rows, it blanks who
    // is on them — so an operator with history is disabled, never deleted.
    final signed = adminInt(staff['signedRecords']);
    if (signed > 0) {
      return 'Recorded on $signed till and stock record(s) — disable instead';
    }
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

  /// Permissions grouped by module in the server's own order, for a checklist
  /// that reads in sections rather than as one wall of 47 chips.
  Map<String, List<String>> get permissionsByModule {
    if (moduleOrder.isNotEmpty) {
      return {
        for (final module in moduleOrder)
          module: (moduleActions[module] ?? const [])
              .map((action) => '$module.$action')
              .toList(),
      };
    }
    // Falls back to deriving the grouping if the catalogue never loaded.
    final grouped = <String, List<String>>{};
    for (final permission in allPermissions) {
      grouped.putIfAbsent(permission.split('.').first, () => []).add(permission);
    }
    return grouped;
  }

  /// What a permission does, for the label under each chip.
  String describe(String permission) =>
      adminString(catalogue[permission]?['label'], permission);

  /// False when a permission is declared but gates no route yet — granting it
  /// changes nothing, and the console says so instead of implying otherwise.
  bool isEnforced(String permission) =>
      catalogue[permission]?['enforced'] != false;

  String enforcementReason(String permission) =>
      adminString(catalogue[permission]?['reason']);

  /// Whether a role grants a specific permission, for the matrix.
  bool roleGrants(String role, String permission) {
    final grants = rolePermissions[role] ?? const <String>[];
    if (grants.contains('*')) return true;
    if (grants.contains(permission)) return true;
    final module = permission.split('.').first;
    return grants.contains('$module.*');
  }
}
