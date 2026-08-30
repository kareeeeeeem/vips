import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/users_controller.dart';

/// The console's user directory.
///
/// Adapted from the consumer app's Profile screen in the sense that it shows
/// the same account fields — but inverted: Profile renders one signed-in
/// user read-only, this renders every user with the moderation actions the
/// backend actually supports (ban, role, delete).
class UsersListView extends GetView<AdminUsersController> {
  const UsersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Users',
      route: AdminRoutes.USERS,
      onRefresh: () => controller.load(),
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
            // Read `search` so the clear button appears as soon as there is
            // text — the field's own controller is not observable.
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
                options: const [
                  AdminFilterOption('customer', 'Customers'),
                  AdminFilterOption('merchant', 'Merchants'),
                  AdminFilterOption('agent', 'Agents'),
                  AdminFilterOption('admin', 'Admins'),
                ],
                selected: controller.roleFilter.value,
                onSelected: controller.setRoleFilter,
              )),
          SizedBox(height: 8.h),
          Obx(() => AdminFilterChips(
                options: const [
                  AdminFilterOption('', 'All'),
                  AdminFilterOption('active', 'Active'),
                  AdminFilterOption('banned', 'Banned'),
                ],
                selected: controller.statusFilter.value,
                onSelected: controller.setStatusFilter,
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
        final filtered = controller.search.value.isNotEmpty ||
            controller.statusFilter.value.isNotEmpty;
        return AdminEmptyState(
          icon: Icons.people_outline_rounded,
          title: filtered ? 'No matching users' : 'No users yet',
          message: filtered
              ? 'No account matches these filters. Try clearing the search or status filter.'
              : 'Accounts will appear here as people sign up.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          for (final user in controller.items) _buildUserCard(user),
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

  Widget _buildUserCard(Map<String, dynamic> user) {
    final id = adminString(user['_id']);
    final name = adminString(user['fullName'], 'Unnamed');
    final banned = controller.isBanned(user);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _openDetails(id),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: banned ? AdminColors.danger.withValues(alpha: 0.3) : AdminColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: banned
                    ? AdminColors.danger.withValues(alpha: 0.12)
                    : AdminColors.primary.withValues(alpha: 0.1),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: banned ? AdminColors.danger : AdminColors.primary,
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
                        SizedBox(width: 8.w),
                        if (banned)
                          const AdminStatusPill(
                            label: 'Banned',
                            color: AdminColors.danger,
                            compact: true,
                          )
                        else if (adminBool(user['isVerified']))
                          Icon(Icons.verified_rounded,
                              size: 14.sp, color: AdminColors.info),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      adminString(user['email'], 'No email'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5.sp, color: AdminColors.textSecondary),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        _miniStat(Icons.phone_outlined, adminString(user['phone'], '—')),
                        SizedBox(width: 12.w),
                        _miniStat(
                          Icons.stars_rounded,
                          '${adminCount(adminInt(user['walletPoints']))} pts',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Obx(() => IconButton(
                    tooltip: 'Actions',
                    onPressed: controller.isMutating.value
                        ? null
                        : () => _showActions(user),
                    icon: Icon(Icons.more_vert_rounded,
                        size: 20.sp, color: AdminColors.textMuted),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: AdminColors.textMuted),
        SizedBox(width: 4.w),
        Text(text, style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted)),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────

  void _showActions(Map<String, dynamic> user) {
    final id = adminString(user['_id']);
    final name = adminString(user['fullName'], 'this user');
    final banned = controller.isBanned(user);
    final role = adminString(user['role'], 'customer');

    adminSheet(
      title: name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _actionTile(
            icon: Icons.person_search_rounded,
            label: 'View full details',
            color: AdminColors.info,
            onTap: () {
              Get.back();
              _openDetails(id);
            },
          ),
          _actionTile(
            icon: banned ? Icons.lock_open_rounded : Icons.block_rounded,
            label: banned ? 'Reinstate account' : 'Ban account',
            color: banned ? AdminColors.success : AdminColors.warning,
            onTap: () async {
              Get.back();
              final confirmed = await adminConfirm(
                title: banned ? 'Reinstate $name?' : 'Ban $name?',
                message: banned
                    ? 'They will be able to sign in again immediately.'
                    : 'They will be signed out and blocked from signing in until reinstated.',
                confirmLabel: banned ? 'Reinstate' : 'Ban',
                confirmColor: banned ? AdminColors.success : AdminColors.warning,
              );
              if (confirmed) await controller.setBanned(id, !banned);
            },
          ),
          _actionTile(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Change role (currently ${adminLabel(role)})',
            color: AdminColors.purple,
            onTap: () {
              Get.back();
              _showRolePicker(id, name, role);
            },
          ),
          _actionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete account',
            color: AdminColors.danger,
            onTap: () async {
              Get.back();
              final confirmed = await adminConfirm(
                title: 'Delete $name?',
                message: 'This permanently removes the account. Their past orders '
                    'are kept as financial records.',
                confirmLabel: 'Delete',
              );
              if (confirmed) await controller.deleteUser(id);
            },
          ),
        ],
      ),
    );
  }

  void _showRolePicker(String id, String name, String currentRole) {
    const roles = ['customer', 'merchant', 'agent', 'admin'];
    adminSheet(
      title: 'Role for $name',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final role in roles)
            _actionTile(
              icon: role == currentRole
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              label: adminLabel(role),
              color: role == currentRole ? AdminColors.primary : AdminColors.textSecondary,
              onTap: role == currentRole
                  ? null
                  : () async {
                      Get.back();
                      final confirmed = await adminConfirm(
                        title: 'Change role?',
                        message: 'Set $name to ${adminLabel(role)}. '
                            '${role == 'admin' ? 'They will gain full console access.' : ''}',
                        confirmLabel: 'Change role',
                        confirmColor: AdminColors.primary,
                      );
                      if (confirmed) await controller.changeRole(id, role);
                    },
            ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
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

  // ── Details ───────────────────────────────────────────────

  /// The full record lives on its own route (`UserDetailsView`) rather than
  /// in a second sheet here — one implementation, so the two cannot drift.
  /// Refreshes the list on return, since the detail screen can ban or delete.
  Future<void> _openDetails(String id) async {
    await Get.toNamed(AdminRoutes.userDetails(id));
    await controller.load();
  }

}
