import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../../staff/controllers/staff_controller.dart';
import '../../staff/views/staff_list_view.dart';

/// What each operator actually holds.
///
/// Deliberately a different question from the Roles screen. That one answers
/// "what does the manager role grant?"; this one answers "what can Nadia
/// actually do, and is any of it beyond what her role gives her?" — which is
/// the question an audit asks, and which neither the roles matrix nor the
/// staff list answers.
class StaffPermissionsView extends GetView<StaffController> {
  const StaffPermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Staff permissions',
      route: AdminRoutes.SETTINGS_STAFF_PERMISSIONS,
      onRefresh: () => controller.load(),
      actions: [
        IconButton(
          tooltip: 'What each role grants',
          onPressed: () => Get.toNamed(AdminRoutes.ROLES),
          icon: Icon(Icons.shield_outlined,
              size: 20.sp, color: AdminColors.textSecondary),
        ),
      ],
      body: Obx(() {
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
          return const AdminEmptyState(
            icon: Icons.shield_outlined,
            title: 'No console operators',
            message: 'Add an operator on the Staff screen to see what they hold.',
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: [
            _buildExtrasBanner(),
            for (final staff in controller.items) _buildOperator(staff),
          ],
        );
      }),
    );
  }

  /// Permissions granted to this operator on top of whatever their role
  /// already gives them. The interesting set: everything else is explained by
  /// the role and visible on the Roles screen.
  List<String> _extras(Map<String, dynamic> staff) {
    final role = adminString(staff['adminRole'], 'viewer');
    final effective = staff['effectivePermissions'];
    if (effective is! List) return const [];
    return effective
        .map((p) => p.toString())
        .where((p) => p != '*' && !controller.roleGrants(role, p))
        .toList()
      ..sort();
  }

  Widget _buildExtrasBanner() {
    final withExtras =
        controller.items.where((s) => _extras(s).isNotEmpty).length;
    if (withExtras == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AdminColors.info.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.info.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.key_outlined, size: 16.sp, color: AdminColors.info),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              '$withExtras operator(s) hold something their role does not '
              'grant. Those extras are listed first on each card — they are '
              'the permissions no role change would take away.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.4,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperator(Map<String, dynamic> staff) {
    final name = adminString(staff['fullName'], 'Unnamed');
    final role = adminString(staff['adminRole'], 'viewer');
    final active = adminBool(staff['isActive'], true);
    final effective = staff['effectivePermissions'];
    final isSuper = effective is List && effective.contains('*');
    final total = isSuper
        ? controller.allPermissions.length
        : (effective is List ? effective.length : 0);
    final extras = _extras(staff);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: active
                ? AdminColors.border
                : AdminColors.danger.withValues(alpha: 0.3),
          ),
        ),
        child: Theme(
          // The default divider draws a line across a card that already has a
          // border, which reads as two cards stacked.
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
            childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
            leading: CircleAvatar(
              radius: 18.r,
              backgroundColor:
                  StaffListView.roleColor(role).withValues(alpha: 0.12),
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: StaffListView.roleColor(role),
                ),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: [
                  AdminStatusPill(
                    label: adminLabel(role),
                    color: StaffListView.roleColor(role),
                    compact: true,
                  ),
                  AdminStatusPill(
                    label: isSuper ? 'Everything' : '$total permissions',
                    color: AdminColors.textSecondary,
                    compact: true,
                  ),
                  if (extras.isNotEmpty)
                    AdminStatusPill(
                      label: '+${extras.length} beyond the role',
                      color: AdminColors.info,
                      compact: true,
                    ),
                  if (!active)
                    const AdminStatusPill(
                      label: 'Disabled',
                      color: AdminColors.danger,
                      compact: true,
                    ),
                ],
              ),
            ),
            children: [
              if (isSuper)
                _buildNote(
                  'A super admin holds the wildcard, which covers every '
                  'permission the system has and every one added later.',
                )
              else ...[
                if (extras.isNotEmpty) ...[
                  _buildSectionLabel('Granted on top of the role'),
                  for (final permission in extras)
                    _buildPermissionRow(permission, isExtra: true),
                  SizedBox(height: 8.h),
                ],
                _buildSectionLabel('From the ${adminLabel(role)} role'),
                ..._buildRolePermissions(staff, role),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRolePermissions(Map<String, dynamic> staff, String role) {
    final effective = staff['effectivePermissions'];
    if (effective is! List) return const [];
    final fromRole = effective
        .map((p) => p.toString())
        .where((p) => controller.roleGrants(role, p))
        .toList()
      ..sort();

    if (fromRole.isEmpty) {
      return [_buildNote('This role grants nothing on its own.')];
    }
    return [for (final p in fromRole) _buildPermissionRow(p)];
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 4.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AdminColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String permission, {bool isExtra = false}) {
    final enforced = controller.isEnforced(permission);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isExtra ? Icons.add_circle_outline : Icons.check_circle_outline,
            size: 13.sp,
            color: isExtra ? AdminColors.info : AdminColors.success,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.describe(permission),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Text(
                  permission,
                  style: TextStyle(
                      fontSize: 9.5.sp,
                      fontFamily: 'monospace',
                      color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          // A permission that gates nothing yet is marked, so a reader does
          // not conclude somebody can do a thing the system never checks.
          if (!enforced)
            Padding(
              padding: EdgeInsets.only(left: 6.w, top: 1.h),
              child: Tooltip(
                message: controller.enforcementReason(permission),
                child: Icon(Icons.info_outline,
                    size: 12.sp, color: AdminColors.warning),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNote(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11.sp, height: 1.4, color: AdminColors.textSecondary),
      ),
    );
  }
}
