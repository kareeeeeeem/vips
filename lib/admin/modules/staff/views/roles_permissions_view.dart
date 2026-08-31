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
import 'staff_list_view.dart';

/// What each role can do, and the operator-defined roles on top.
class RolesPermissionsView extends GetView<StaffController> {
  const RolesPermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Roles & Permissions',
      route: AdminRoutes.STAFF,
      onRefresh: controller.loadCatalogue,
      actions: [
        Obx(() => IconButton(
              tooltip: controller.canWrite
                  ? 'New role'
                  : 'Creating roles needs the staff.write permission',
              onPressed: controller.canWrite ? () => _createRole(context) : null,
              icon: Icon(Icons.add_moderator_outlined,
                  size: 20.sp,
                  color: controller.canWrite
                      ? AdminColors.primary
                      : AdminColors.border),
            )),
      ],
      body: Obx(() {
        // A load still in flight is not a failure — checking emptiness alone
        // rendered "could not load" for the whole first second.
        if (controller.isLoadingCatalogue.value && controller.allPermissions.isEmpty) {
          return const AdminLoading();
        }
        if (controller.allPermissions.isEmpty) {
          return AdminErrorState(
            message: 'Could not load the permission catalogue.',
            onRetry: controller.loadCatalogue,
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            _buildUnenforcedNotice(),
            _buildMatrix(),
            SizedBox(height: 14.h),
            _buildBuiltIn(),
            SizedBox(height: 14.h),
            _buildCustom(),
          ],
        );
      }),
    );
  }

  /// Every permission against every role.
  ///
  /// A summarised "Read / Edit / Full" column stopped describing the model
  /// once actions became per-module — a role can approve merchants without
  /// deleting them, and that distinction is the whole point.
  Widget _buildMatrix() {
    final grouped = controller.permissionsByModule;

    return AdminCard(
      title: 'What each role can do',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A tick means the role grants it outright. Individual operators '
            'can be given more on top.',
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.45,
              color: AdminColors.textMuted,
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 42.h,
              dataRowMinHeight: 34.h,
              dataRowMaxHeight: 34.h,
              columnSpacing: 20.w,
              columns: [
                const DataColumn(label: Text('Permission')),
                for (final role in StaffController.builtInRoles)
                  DataColumn(
                    label: Text(
                      adminLabel(role),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: StaffListView.roleColor(role),
                      ),
                    ),
                  ),
              ],
              rows: [
                for (final entry in grouped.entries)
                  for (var i = 0; i < entry.value.length; i++)
                    DataRow(cells: [
                      DataCell(_permissionLabel(
                        entry.key,
                        entry.value[i],
                        isFirstOfModule: i == 0,
                      )),
                      for (final role in StaffController.builtInRoles)
                        DataCell(_tick(role, entry.value[i])),
                    ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionLabel(String module, String permission,
      {required bool isFirstOfModule}) {
    final action = permission.split('.').last;
    final enforced = controller.isEnforced(permission);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The module name is printed once per group so the rows below read as
        // belonging to it without repeating it on every line.
        SizedBox(
          width: 78.w,
          child: isFirstOfModule
              ? Text(
                  adminLabel(module),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Text(
          adminLabel(action),
          style: TextStyle(
            fontSize: 11.5.sp,
            color: enforced ? AdminColors.textSecondary : AdminColors.textMuted,
          ),
        ),
        if (!enforced) ...[
          SizedBox(width: 5.w),
          Tooltip(
            message: controller.enforcementReason(permission),
            child: Icon(Icons.info_outline_rounded,
                size: 12.sp, color: AdminColors.warning),
          ),
        ],
      ],
    );
  }

  Widget _tick(String role, String permission) {
    final granted = controller.roleGrants(role, permission);
    return Icon(
      granted ? Icons.check_circle_rounded : Icons.remove_rounded,
      size: 15.sp,
      color: granted ? StaffListView.roleColor(role) : AdminColors.border,
    );
  }

  /// Some permissions are declared for completeness but gate no route yet.
  /// Saying so beats letting someone grant one and expect a behaviour change.
  Widget _buildUnenforcedNotice() {
    final unenforced = controller.allPermissions
        .where((p) => !controller.isEnforced(p))
        .toList();
    if (unenforced.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16.sp, color: AdminColors.warning),
              SizedBox(width: 8.w),
              Text(
                '${unenforced.length} permission(s) gate nothing yet',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          for (final permission in unenforced)
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Text(
                '• $permission — ${controller.enforcementReason(permission)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.4,
                  color: AdminColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBuiltIn() {
    return AdminCard(
      title: 'Built-in roles',
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // They live in middleware/permissions.js because the gate reads
              // them, so they are not editable records.
              'These four ship with the console and cannot be edited or '
              'deleted — the permission gate is built on them.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: AdminColors.textMuted,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          for (final role in StaffController.builtInRoles)
            _roleRow(
              name: adminLabel(role),
              color: StaffListView.roleColor(role),
              permissions: controller.rolePermissions[role] ?? const [],
              locked: true,
            ),
        ],
      ),
    );
  }

  Widget _buildCustom() {
    final custom = controller.customRoles;
    return AdminCard(
      title: 'Custom roles (${custom.length})',
      child: custom.isEmpty
          ? Text(
              'None yet. Create one to bundle a specific set of permissions '
              'under a name of your own.',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            )
          : Column(
              children: [
                for (final role in custom)
                  _roleRow(
                    name: adminString(role['name'], 'Unnamed'),
                    color: AdminColors.accent,
                    permissions: role['permissions'] is List
                        ? (role['permissions'] as List).map((p) => p.toString()).toList()
                        : const [],
                    locked: false,
                    description: adminString(role['description']),
                    onDelete: controller.canDelete
                        ? () async {
                            final confirmed = await adminConfirm(
                              title: 'Delete ${adminString(role['name'])}?',
                              message: 'Operators already assigned this role keep '
                                  'the permissions they were given.',
                              confirmLabel: 'Delete',
                            );
                            if (confirmed) {
                              await controller.deleteRole(adminString(role['_id']));
                            }
                          }
                        : null,
                  ),
              ],
            ),
    );
  }

  Widget _roleRow({
    required String name,
    required Color color,
    required List<String> permissions,
    required bool locked,
    String description = '',
    VoidCallback? onDelete,
  }) {
    final summary = permissions.contains('*')
        ? 'Everything'
        : '${permissions.length} permission${permissions.length == 1 ? '' : 's'}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              locked ? Icons.shield_outlined : Icons.workspace_premium_outlined,
              size: 17.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Text(
                  description.isNotEmpty ? description : summary,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          AdminStatusPill(label: summary, color: color, compact: true),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete role',
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded,
                  size: 17.sp, color: AdminColors.danger),
            ),
        ],
      ),
    );
  }

  // ── Create ────────────────────────────────────────────────

  void _createRole(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final chosen = <String>{}.obs;

    adminSheet(
      title: 'New role',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
            decoration: _decoration('Role name', 'e.g. support_agent'),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: descriptionController,
            style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
            decoration: _decoration('Description', 'What is this role for?'),
          ),
          SizedBox(height: 16.h),
          Text(
            'Permissions',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AdminColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final entry in controller.permissionsByModule.entries) ...[
                    Text(
                      adminLabel(entry.key),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final permission in entry.value)
                          GestureDetector(
                            onTap: () => chosen.contains(permission)
                                ? chosen.remove(permission)
                                : chosen.add(permission),
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
                              decoration: BoxDecoration(
                                color: chosen.contains(permission)
                                    ? AdminColors.primary.withValues(alpha: 0.12)
                                    : AdminColors.surface,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: chosen.contains(permission)
                                      ? AdminColors.primary
                                      : AdminColors.border,
                                ),
                              ),
                              child: Text(
                                adminLabel(permission.split('.').last),
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: chosen.contains(permission)
                                      ? AdminColors.primary
                                      : AdminColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                ],
              )),
          SizedBox(height: 8.h),
          Obx(() => AdminButton(
                label: 'Create role',
                icon: Icons.add_moderator_outlined,
                isLoading: controller.isMutating.value,
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    return adminToast('Name required',
                        'Give the role a name.', isError: true);
                  }
                  // The server refuses a name that shadows a built-in; saying
                  // so here avoids a round trip for an obvious clash.
                  if (StaffController.builtInRoles.contains(name)) {
                    return adminToast('Name taken',
                        '"$name" is a built-in role name.', isError: true);
                  }
                  if (chosen.isEmpty) {
                    return adminToast('No permissions',
                        'A role with no permissions grants nothing.',
                        isError: true);
                  }
                  final ok = await controller.createRole(
                    name,
                    descriptionController.text.trim(),
                    chosen.toList(),
                  );
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    ).whenComplete(() {
      nameController.dispose();
      descriptionController.dispose();
    });
  }

  InputDecoration _decoration(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.primary),
        ),
      );
}
