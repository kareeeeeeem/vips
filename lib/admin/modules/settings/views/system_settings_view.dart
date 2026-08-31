import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/admin_settings_controller.dart';

/// What is actually live in the running backend.
///
/// Read-only on purpose. Every value here comes from an environment variable
/// on the server — an editable form would either write to a file the running
/// process has already read, or claim to change something it cannot. The
/// screen says where each one is set instead of pretending to own it.
class SystemSettingsView extends GetView<AdminSettingsController> {
  const SystemSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'System',
      route: AdminRoutes.SETTINGS_SYSTEM,
      onRefresh: controller.load,
      body: Obx(() {
        if (controller.isLoading.value && controller.integrations.isEmpty) {
          return const AdminLoading();
        }
        if (controller.errorMessage.isNotEmpty && controller.integrations.isEmpty) {
          return AdminErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntegrations(),
              SizedBox(height: 12.h),
              _buildEnvironment(),
              SizedBox(height: 12.h),
              _buildNote(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildIntegrations() {
    final entries = controller.integrations.entries.toList();
    return AdminCard(
      title: 'Integrations',
      subtitle: 'Whether this process can actually reach each service',
      child: Column(
        children: [
          for (final entry in entries) _buildIntegrationRow(entry.key, entry.value),
        ],
      ),
    );
  }

  Widget _buildIntegrationRow(String key, dynamic value) {
    final configured = adminBool(value);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        children: [
          Icon(
            configured ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 18.sp,
            color: configured ? AdminColors.success : AdminColors.textMuted,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _integrationLabel(key),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  configured
                      ? 'Configured'
                      // Names the consequence, not just the state: "not
                      // configured" alone does not say what stops working.
                      : _missingConsequence(key),
                  style: TextStyle(
                      fontSize: 10.5.sp, height: 1.3, color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          AdminStatusPill(
            label: configured ? 'Live' : 'Off',
            color: configured ? AdminColors.success : AdminColors.textSecondary,
            compact: true,
          ),
        ],
      ),
    );
  }

  String _integrationLabel(String key) => switch (key) {
        'firebaseAdmin' => 'Firebase Admin',
        'sendgrid' => 'SendGrid email',
        'paymee' => 'Paymee payments',
        'paypal' => 'PayPal payments',
        _ => adminLabel(key),
      };

  String _missingConsequence(String key) => switch (key) {
        'firebaseAdmin' => 'Social sign-in cannot verify tokens',
        'sendgrid' => 'Emails are written to the log, not sent',
        'paymee' => 'Paymee checkout is unavailable',
        'paypal' => 'PayPal checkout is unavailable',
        _ => 'Not configured',
      };

  Widget _buildEnvironment() {
    final env = controller.environment;
    final database = adminString(env['database'], 'unknown');
    return AdminCard(
      title: 'Environment',
      child: Column(
        children: [
          AdminDetailRow(
            label: 'Mode',
            value: adminString(env['nodeEnv'], 'development'),
          ),
          AdminDetailRow(
            label: 'Database',
            value: database == 'connected' ? 'Connected' : 'Disconnected',
          ),
          AdminDetailRow(
            label: 'Backend URL',
            value: adminString(env['backendUrl'], 'Not set'),
          ),
        ],
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AdminColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15.sp, color: AdminColors.info),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'These are read from the running process, not stored settings. '
              'Each is set by an environment variable on the server, so they '
              'are shown rather than edited — a form here would claim to '
              'change something the process has already read at startup.',
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
}
