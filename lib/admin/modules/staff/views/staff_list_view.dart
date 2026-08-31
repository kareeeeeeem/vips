import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/staff_controller.dart';

/// Console operators and what each of them can do.
class StaffListView extends GetView<StaffController> {
  const StaffListView({super.key});

  /// Colour per role, ordered by reach so the hierarchy reads at a glance.
  static Color roleColor(String role) {
    switch (role) {
      case 'super_admin':
        return AdminColors.purple;
      case 'admin':
        return AdminColors.primary;
      case 'manager':
        return AdminColors.info;
      default:
        return AdminColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Staff',
      route: AdminRoutes.STAFF,
      onRefresh: () => controller.load(),
      actions: [
        IconButton(
          tooltip: 'Roles and permissions',
          onPressed: () => Get.toNamed(AdminRoutes.ROLES),
          icon: Icon(Icons.shield_outlined,
              size: 20.sp, color: AdminColors.textSecondary),
        ),
        Obx(() => IconButton(
              tooltip: controller.canWrite
                  ? 'Add an operator'
                  : 'Your role does not allow adding operators',
              // Disabled rather than failing after the tap — the server
              // refuses it either way.
              onPressed: controller.canWrite
                  ? () => Get.toNamed(AdminRoutes.STAFF_NEW)
                  : null,
              icon: Icon(Icons.person_add_alt_rounded,
                  size: 20.sp,
                  color: controller.canWrite
                      ? AdminColors.primary
                      : AdminColors.border),
            )),
      ],
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: AdminColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        children: [
          Obx(() {
            controller.search.value;
            return AdminSearchField(
              controller: controller.searchController,
              hint: 'Search by name, email or phone',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'All roles'),
                  for (final role in StaffController.builtInRoles)
                    AdminFilterOption(role, adminLabel(role)),
                ],
                selected: controller.roleFilter.value,
                onSelected: controller.setRoleFilter,
              )),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const AdminLoading();
      }
      if (controller.errorMessage.isNotEmpty && controller.items.isEmpty) {
        return AdminErrorState(
          message: controller.errorMessage.value,
          onRetry: () => controller.load(),
        );
      }
      if (controller.items.isEmpty) {
        final filtered =
            controller.search.value.isNotEmpty || controller.roleFilter.value.isNotEmpty;
        return AdminEmptyState(
          icon: Icons.badge_outlined,
          title: filtered ? 'No matching operators' : 'No console operators',
          message: filtered
              ? 'No operator matches these filters.'
              : 'Add an operator to give someone access to this console.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          for (final staff in controller.items) _buildCard(staff),
          AdminPaginator(
            page: controller.page.value,
            pages: controller.pages.value,
            total: controller.total.value,
            onPrevious: controller.previousPage,
            onNext: controller.nextPage,
          ),
        ],
      );
    });
  }

  Widget _buildCard(Map<String, dynamic> staff) {
    final id = adminString(staff['_id']);
    final name = adminString(staff['fullName'], 'Unnamed');
    final role = adminString(staff['adminRole'], 'viewer');
    final active = adminBool(staff['isActive'], true);
    final isSelf = controller.isSelf(staff);
    final effective = staff['effectivePermissions'];
    final permissionCount = effective is List
        ? (effective.contains('*') ? controller.allPermissions.length : effective.length)
        : 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _open(id),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: active
                  ? AdminColors.border
                  : AdminColors.danger.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: roleColor(role).withValues(alpha: 0.12),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: roleColor(role),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelf) ...[
                          SizedBox(width: 6.w),
                          const AdminStatusPill(
                            label: 'You',
                            color: AdminColors.primary,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      adminString(staff['email'], 'No email'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5.sp, color: AdminColors.textSecondary),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        AdminStatusPill(
                          label: adminLabel(role),
                          color: roleColor(role),
                          compact: true,
                        ),
                        AdminStatusPill(
                          label: active ? 'Active' : 'Disabled',
                          color: active ? AdminColors.success : AdminColors.danger,
                          compact: true,
                        ),
                        AdminStatusPill(
                          label: '$permissionCount permissions',
                          color: AdminColors.textSecondary,
                          compact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Obx(() => IconButton(
                    tooltip: 'Actions',
                    onPressed:
                        controller.isMutating.value ? null : () => _showActions(staff),
                    icon: Icon(Icons.more_vert_rounded,
                        size: 20.sp, color: AdminColors.textMuted),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────

  void _showActions(Map<String, dynamic> staff) {
    final id = adminString(staff['_id']);
    final name = adminString(staff['fullName'], 'this operator');
    final active = adminBool(staff['isActive'], true);
    final isSelf = controller.isSelf(staff);
    final deleteBlocked = controller.deleteBlockedReason(staff);

    adminSheet(
      title: name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tile(
            icon: Icons.badge_outlined,
            label: 'View details and permissions',
            color: AdminColors.info,
            onTap: () {
              Get.back();
              _open(id);
            },
          ),
          _tile(
            icon: Icons.edit_outlined,
            label: controller.canWrite
                ? 'Edit role and permissions'
                : 'Editing needs the staff.write permission',
            color: AdminColors.primary,
            onTap: controller.canWrite
                ? () {
                    Get.back();
                    Get.toNamed(AdminRoutes.staffEdit(id));
                  }
                : null,
          ),
          _tile(
            icon: active ? Icons.block_rounded : Icons.lock_open_rounded,
            label: isSelf
                ? 'You cannot disable your own account'
                : active
                    ? 'Disable this account'
                    : 'Re-enable this account',
            color: active ? AdminColors.warning : AdminColors.success,
            // Disabling yourself locks you out of the console mid-session,
            // so the server refuses it and so does the button.
            onTap: (isSelf || !controller.canWrite)
                ? null
                : () async {
                    Get.back();
                    final confirmed = await adminConfirm(
                      title: active ? 'Disable $name?' : 'Re-enable $name?',
                      message: active
                          ? 'They will be signed out and blocked from the console until re-enabled.'
                          : 'They will be able to sign in again immediately.',
                      confirmLabel: active ? 'Disable' : 'Enable',
                      confirmColor:
                          active ? AdminColors.warning : AdminColors.success,
                    );
                    if (confirmed) await controller.setActive(id, !active);
                  },
          ),
          _tile(
            icon: Icons.person_remove_outlined,
            label: deleteBlocked ?? 'Remove from the console',
            color: AdminColors.danger,
            onTap: deleteBlocked != null
                ? null
                : () async {
                    Get.back();
                    final confirmed = await adminConfirm(
                      title: 'Remove $name?',
                      message: 'Their account is deleted and console access ends '
                          'immediately. This cannot be undone.',
                      confirmLabel: 'Remove',
                    );
                    if (confirmed) await controller.deleteStaff(id);
                  },
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 4.w),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: color),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(String id) async {
    await Get.toNamed(AdminRoutes.staffDetails(id));
    await controller.load();
  }
}

/// Shown when a control is disabled because of the caller's own role.
void staffPermissionToast() => adminToast(
      'Not allowed',
      'Your role does not permit this action.',
      isError: true,
    );
