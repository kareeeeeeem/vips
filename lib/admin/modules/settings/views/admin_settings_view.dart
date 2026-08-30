import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../../auth/controllers/admin_auth_controller.dart';
import '../controllers/admin_settings_controller.dart';

/// Adapted from the consumer app's Settings screen: the same grouped-section
/// layout and tile styling. What changed is the content — a customer's
/// language/theme/biometric toggles are replaced with what a platform
/// operator actually controls: the admin roster and the live status of the
/// backend's integrations.
class AdminSettingsView extends GetView<AdminSettingsController> {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Settings',
      route: AdminRoutes.SETTINGS,
      onRefresh: controller.load,
      body: Obx(() {
        if (controller.isLoading.value && controller.admins.isEmpty) {
          return const AdminLoading();
        }
        if (controller.errorMessage.isNotEmpty && controller.admins.isEmpty) {
          return AdminErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            _buildAccountCard(),
            SizedBox(height: 16.h),
            _buildAdminsCard(),
            SizedBox(height: 16.h),
            _buildIntegrationsCard(),
            SizedBox(height: 16.h),
            _buildEnvironmentCard(),
            SizedBox(height: 16.h),
            _buildSignOutCard(),
          ],
        );
      }),
    );
  }

  // ── Signed-in admin ───────────────────────────────────────

  Widget _buildAccountCard() {
    final auth = Get.find<AdminAuthController>();
    return AdminCard(
      title: 'Signed in as',
      child: Obx(() => Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AdminColors.primary.withValues(alpha: 0.1),
                child: Text(
                  auth.adminName.value.isEmpty
                      ? 'A'
                      : auth.adminName.value[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.adminName.value.isEmpty
                          ? 'Administrator'
                          : auth.adminName.value,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    Text(
                      auth.adminEmail.value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  // ── Admin roster ──────────────────────────────────────────

  Widget _buildAdminsCard() {
    final currentId = Get.find<AdminAuthController>().adminId.value;

    return Obx(() => AdminCard(
          title: 'Administrators (${controller.admins.length})',
          trailing: TextButton.icon(
            onPressed: controller.isSaving.value ? null : _showCreateAdminSheet,
            icon: Icon(Icons.person_add_alt_rounded, size: 16.sp),
            label: Text('Add', style: TextStyle(fontSize: 12.sp)),
          ),
          child: Column(
            children: [
              for (final admin in controller.admins)
                _buildAdminRow(admin, isSelf: adminString(admin['_id']) == currentId),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 15.sp, color: AdminColors.textMuted),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'The last remaining admin cannot be removed or demoted, '
                        'and you cannot remove your own account.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.4,
                          color: AdminColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildAdminRow(Map<String, dynamic> admin, {required bool isSelf}) {
    final id = adminString(admin['_id']);
    final name = adminString(admin['fullName'], 'Unnamed');
    // Removing yourself or the last admin is refused server side, so the
    // button is disabled rather than failing after the tap.
    final canRemove = !isSelf && controller.admins.length > 1;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AdminColors.purple.withValues(alpha: 0.12),
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.purple,
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
                          fontSize: 13.sp,
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
                Text(
                  adminString(admin['email']),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                ),
                Text(
                  'Last login ${adminRelative(adminDate(admin['lastLogin']))}',
                  style: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: canRemove
                ? 'Remove admin'
                : (isSelf ? 'You cannot remove yourself' : 'The last admin cannot be removed'),
            onPressed: !canRemove || controller.isSaving.value
                ? null
                : () async {
                    final confirmed = await adminConfirm(
                      title: 'Remove $name?',
                      message: 'They lose console access immediately. Their '
                          'account is deleted, not just demoted.',
                      confirmLabel: 'Remove',
                    );
                    if (confirmed) await controller.removeAdmin(id);
                  },
            icon: Icon(
              Icons.person_remove_outlined,
              size: 18.sp,
              color: canRemove ? AdminColors.danger : AdminColors.border,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAdminSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    adminSheet(
      title: 'Add administrator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The new admin signs in with this email and password. There is no '
            'invitation email — pass the credentials on yourself and have them '
            'change the password after first sign-in.',
            style: TextStyle(fontSize: 12.sp, height: 1.45, color: AdminColors.textSecondary),
          ),
          SizedBox(height: 18.h),
          _field(nameCtrl, 'Full name'),
          SizedBox(height: 12.h),
          _field(emailCtrl, 'Email', keyboard: TextInputType.emailAddress),
          SizedBox(height: 12.h),
          _field(phoneCtrl, 'Phone', keyboard: TextInputType.phone),
          SizedBox(height: 12.h),
          _field(passwordCtrl, 'Password (min 6 characters)', obscure: true),
          SizedBox(height: 20.h),
          Obx(() => AdminButton(
                label: 'Create administrator',
                icon: Icons.person_add_alt_rounded,
                isLoading: controller.isSaving.value,
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();
                  final password = passwordCtrl.text;

                  // Same rules the backend enforces, checked here so the
                  // operator sees which field is wrong without a round trip.
                  if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
                    return adminToast('Missing details',
                        'Name, email, phone and password are all required.',
                        isError: true);
                  }
                  if (!email.contains('@') || !email.contains('.')) {
                    return adminToast(
                        'Check the email', 'That does not look like an email address.',
                        isError: true);
                  }
                  if (password.length < 6) {
                    return adminToast('Password too short',
                        'Use at least 6 characters.', isError: true);
                  }

                  final ok = await controller.createAdmin(
                    fullName: name,
                    email: email,
                    phone: phone,
                    password: password,
                  );
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      emailCtrl.dispose();
      phoneCtrl.dispose();
      passwordCtrl.dispose();
    });
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
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
      ),
    );
  }

  // ── Integrations ──────────────────────────────────────────

  Widget _buildIntegrationsCard() {
    const rows = [
      ('firebaseAdmin', 'Firebase Admin', 'Verifies Google / Facebook / Apple / phone sign-in tokens'),
      ('sendgrid', 'SendGrid mail', 'Password-reset and verification emails'),
      ('paymee', 'Paymee', 'Card payments in Tunisian dinar'),
      ('paypal', 'PayPal', 'International card payments'),
    ];

    return Obx(() => AdminCard(
          title: 'Backend integrations',
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  'Read live from the running backend process — this is what is '
                  'actually configured on the server, not a saved preference.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.4,
                    color: AdminColors.textMuted,
                  ),
                ),
              ),
              for (final row in rows)
                _integrationRow(
                  label: row.$2,
                  description: row.$3,
                  enabled: controller.integrationEnabled(row.$1),
                ),
            ],
          ),
        ));
  }

  Widget _integrationRow({
    required String label,
    required String description,
    required bool enabled,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18.sp,
            color: enabled ? AdminColors.success : AdminColors.textMuted,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.35,
                    color: AdminColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          AdminStatusPill(
            label: enabled ? 'Configured' : 'Not set',
            color: enabled ? AdminColors.success : AdminColors.warning,
            compact: true,
          ),
        ],
      ),
    );
  }

  // ── Environment ───────────────────────────────────────────

  Widget _buildEnvironmentCard() {
    return Obx(() {
      final database = adminString(controller.environment['database'], 'unknown');
      return AdminCard(
        title: 'Environment',
        child: Column(
          children: [
            AdminDetailRow(
              label: 'API base URL',
              value: ApiService.baseUrl,
            ),
            AdminDetailRow(
              label: 'Node environment',
              value: adminString(controller.environment['nodeEnv'], 'unknown'),
            ),
            AdminDetailRow(
              label: 'Backend URL',
              value: adminString(controller.environment['backendUrl']),
            ),
            AdminDetailRow(
              label: 'Database',
              valueWidget: AdminStatusPill(
                label: adminLabel(database),
                color: database == 'connected' ? AdminColors.success : AdminColors.danger,
                compact: true,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSignOutCard() {
    return AdminCard(
      child: AdminButton(
        label: 'Sign out',
        icon: Icons.logout_rounded,
        color: AdminColors.danger,
        onPressed: () => Get.find<AdminAuthController>().confirmLogout(),
      ),
    );
  }
}
