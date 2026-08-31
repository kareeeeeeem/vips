import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/staff_controller.dart';
import 'staff_list_view.dart';

/// One console operator: profile, role, and exactly what they can do.
class StaffDetailsView extends GetView<StaffController> {
  const StaffDetailsView({super.key});

  String get _staffId {
    final param = Get.parameters['id'];
    if (param != null && param.isNotEmpty) return param;
    final args = Get.arguments;
    return args is Map ? adminString(args['id']) : '';
  }

  @override
  Widget build(BuildContext context) {
    if (_staffId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Operator')),
        body: AdminEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'No operator selected',
          message: 'Open this screen from the Staff list.',
          action: AdminButton(label: 'Back', expand: false, onPressed: Get.back),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.details.value == null && !controller.isLoadingDetails.value) {
        controller.loadDetails(_staffId);
      }
    });

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AdminColors.textPrimary),
          onPressed: Get.back,
        ),
        title: Text('Operator',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary)),
        actions: [
          Obx(() => IconButton(
                tooltip: controller.canWrite
                    ? 'Edit'
                    : 'Editing needs the staff.write permission',
                onPressed: controller.canWrite
                    ? () async {
                        await Get.toNamed(AdminRoutes.staffEdit(_staffId));
                        await controller.loadDetails(_staffId);
                      }
                    : null,
                icon: Icon(Icons.edit_outlined,
                    size: 20.sp,
                    color: controller.canWrite
                        ? AdminColors.primary
                        : AdminColors.border),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetails.value) return const AdminLoading();

        final data = controller.details.value;
        if (data == null) {
          return AdminErrorState(
            message: 'Could not load this operator.',
            onRetry: () => controller.loadDetails(_staffId),
          );
        }

        final staff = data['staff'] is Map
            ? Map<String, dynamic>.from(data['staff'] as Map)
            : <String, dynamic>{};
        final effective = data['effectivePermissions'] is List
            ? (data['effectivePermissions'] as List).map((p) => p.toString()).toList()
            : <String>[];
        final fromRole = data['rolePermissions'] is List
            ? (data['rolePermissions'] as List).map((p) => p.toString()).toSet()
            : <String>{};

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            _buildHeader(staff),
            SizedBox(height: 14.h),
            _buildProfile(staff),
            SizedBox(height: 14.h),
            _buildPermissions(staff, effective, fromRole),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(Map<String, dynamic> staff) {
    final name = adminString(staff['fullName'], 'Unnamed');
    final role = adminString(staff['adminRole'], 'viewer');
    final active = adminBool(staff['isActive'], true);

    return AdminCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: StaffListView.roleColor(role).withValues(alpha: 0.12),
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: StaffListView.roleColor(role),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  adminString(staff['email'], 'No email'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    AdminStatusPill(
                      label: adminLabel(role),
                      color: StaffListView.roleColor(role),
                      compact: true,
                    ),
                    AdminStatusPill(
                      label: active ? 'Active' : 'Disabled',
                      color: active ? AdminColors.success : AdminColors.danger,
                      compact: true,
                    ),
                    if (controller.isSelf(staff))
                      const AdminStatusPill(
                        label: 'You',
                        color: AdminColors.primary,
                        compact: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(Map<String, dynamic> staff) {
    return AdminCard(
      title: 'Account',
      child: Column(
        children: [
          AdminDetailRow(label: 'Phone', value: adminString(staff['phone'])),
          AdminDetailRow(
            label: 'Role',
            value: adminLabel(adminString(staff['adminRole'], 'viewer')),
          ),
          AdminDetailRow(
            label: 'Status',
            valueWidget: AdminStatusPill(
              label: adminBool(staff['isActive'], true) ? 'Active' : 'Disabled',
              color: adminBool(staff['isActive'], true)
                  ? AdminColors.success
                  : AdminColors.danger,
              compact: true,
            ),
          ),
          AdminDetailRow(
            label: 'Added',
            value: adminDateTimeLabel(adminDate(staff['createdAt'])),
          ),
          AdminDetailRow(
            label: 'Last sign-in',
            // Never signing in is worth seeing plainly — it usually means the
            // credentials never reached the person.
            value: staff['lastLogin'] == null
                ? 'Never signed in'
                : adminDateTimeLabel(adminDate(staff['lastLogin'])),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissions(
    Map<String, dynamic> staff,
    List<String> effective,
    Set<String> fromRole,
  ) {
    final role = adminString(staff['adminRole'], 'viewer');
    final hasAll = effective.contains('*');
    final extras = staff['permissions'] is List
        ? (staff['permissions'] as List).map((p) => p.toString()).toList()
        : <String>[];

    if (hasAll) {
      return AdminCard(
        title: 'Permissions',
        child: Row(
          children: [
            Icon(Icons.all_inclusive_rounded, size: 20.sp, color: AdminColors.purple),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Full access — the ${adminLabel(role)} role grants every '
                'permission in the console.',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.45,
                  color: AdminColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Grouped by module so the reader sees "what can they do to orders"
    // rather than scanning a flat list of 27 strings.
    final grouped = <String, List<String>>{};
    for (final permission in effective) {
      grouped.putIfAbsent(permission.split('.').first, () => []).add(permission);
    }

    return AdminCard(
      title: 'Permissions (${effective.length})',
      child: grouped.isEmpty
          ? Text(
              'This operator has no permissions and cannot open any section.',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (extras.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Text(
                      '${extras.length} granted on top of the ${adminLabel(role)} role, '
                      'shown in solid.',
                      style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                    ),
                  ),
                for (final entry in grouped.entries) ...[
                  Text(
                    adminLabel(entry.key),
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final permission in entry.value)
                        _chip(permission, fromRole.contains(permission)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                ],
              ],
            ),
    );
  }

  Widget _chip(String permission, bool fromRole) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
      decoration: BoxDecoration(
        // Solid means individually granted; outlined means it comes with the
        // role — so removing the extra would still leave the role's version.
        color: fromRole
            ? Colors.transparent
            : AdminColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: fromRole ? AdminColors.border : AdminColors.primary,
        ),
      ),
      child: Text(
        adminLabel(permission.split('.').last),
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: fromRole ? AdminColors.textSecondary : AdminColors.primary,
        ),
      ),
    );
  }
}
