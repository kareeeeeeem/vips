import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/users_controller.dart';

/// Full account record: profile fields, lifetime order/spend summary, recent
/// orders and recent wallet transactions — everything `GET /admin/users/:id`
/// returns, with the moderation actions available inline.
class UserDetailsView extends GetView<AdminUsersController> {
  const UserDetailsView({super.key});

  /// The id comes from the `:id` path segment. Get.arguments is kept as a
  /// fallback so a caller that passes it as an argument still resolves.
  String get _userId {
    final param = Get.parameters['id'];
    if (param != null && param.isNotEmpty) return param;
    final args = Get.arguments;
    return args is Map ? adminString(args['id']) : '';
  }

  @override
  Widget build(BuildContext context) {
    // Arriving with no id is a routing bug, not something to paper over with
    // an empty screen — say so instead of showing a blank record.
    if (_userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('User')),
        body: AdminEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'No account selected',
          message: 'This screen needs a user id. Open it from the Users list.',
          action: AdminButton(
            label: 'Back to Users',
            expand: false,
            onPressed: Get.back,
          ),
        ),
      );
    }

    // Fetch after the first frame so a rebuild mid-build cannot fire it twice.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.details.value == null && !controller.isLoadingDetails.value) {
        controller.loadDetails(_userId);
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
        title: Text(
          'Account',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadDetails(_userId),
            icon: Icon(Icons.refresh_rounded, size: 20.sp, color: AdminColors.textSecondary),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetails.value) return const AdminLoading();

        final data = controller.details.value;
        if (data == null) {
          return AdminErrorState(
            message: 'Could not load this account.',
            onRetry: () => controller.loadDetails(_userId),
          );
        }

        final user = data['user'] is Map
            ? Map<String, dynamic>.from(data['user'] as Map)
            : <String, dynamic>{};
        final stats = data['stats'] is Map
            ? Map<String, dynamic>.from(data['stats'] as Map)
            : <String, dynamic>{};

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            _buildHeader(user),
            SizedBox(height: 16.h),
            _buildSummary(stats),
            SizedBox(height: 16.h),
            _buildProfileCard(user),
            SizedBox(height: 16.h),
            _buildOrdersCard(adminItems(data, 'recentOrders')),
            SizedBox(height: 16.h),
            _buildTransactionsCard(adminItems(data, 'recentTransactions')),
            SizedBox(height: 16.h),
            _buildActionsCard(user),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(Map<String, dynamic> user) {
    final name = adminString(user['fullName'], 'Unnamed');
    final active = adminBool(user['isActive'], true);

    return AdminCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: active
                ? AdminColors.primary.withValues(alpha: 0.1)
                : AdminColors.danger.withValues(alpha: 0.12),
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: active ? AdminColors.primary : AdminColors.danger,
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
                  adminString(user['email'], 'No email'),
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    AdminStatusPill(
                      label: active ? 'Active' : 'Banned',
                      color: active ? AdminColors.success : AdminColors.danger,
                      compact: true,
                    ),
                    SizedBox(width: 6.w),
                    AdminStatusPill(
                      label: adminLabel(adminString(user['role'], 'customer')),
                      color: AdminColors.purple,
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

  Widget _buildSummary(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: AdminStatCard(
            label: 'Orders',
            value: adminCount(adminInt(stats['orders'])),
            icon: Icons.receipt_long_rounded,
            color: AdminColors.info,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: AdminStatCard(
            label: 'Total spent',
            value: adminMoney(adminDouble(stats['totalSpent'])),
            icon: Icons.payments_rounded,
            color: AdminColors.success,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: AdminStatCard(
            label: 'Cancelled',
            value: adminCount(adminInt(stats['cancelledOrders'])),
            icon: Icons.cancel_outlined,
            color: AdminColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> user) {
    return AdminCard(
      title: 'Profile',
      child: Column(
        children: [
          AdminDetailRow(label: 'Phone', value: adminString(user['phone'])),
          AdminDetailRow(
            label: 'Verified',
            value: adminBool(user['isVerified']) ? 'Yes' : 'No',
          ),
          AdminDetailRow(
            label: 'Security PIN',
            value: adminBool(user['hasPin']) ? 'Set' : 'Not set',
          ),
          AdminDetailRow(
            label: 'Two-factor',
            value: adminBool(user['twoFactorEnabled']) ? 'Enabled' : 'Disabled',
          ),
          AdminDetailRow(
            label: 'Wallet balance',
            value: adminMoney(adminDouble(user['walletBalance'])),
          ),
          AdminDetailRow(
            label: 'Wallet points',
            value: adminCount(adminInt(user['walletPoints'])),
          ),
          AdminDetailRow(label: 'Package', value: adminString(user['packageName'], 'Free')),
          AdminDetailRow(label: 'City', value: adminString(user['city'])),
          AdminDetailRow(label: 'Profession', value: adminString(user['profession'])),
          AdminDetailRow(
            label: 'Referral code',
            value: adminString(user['referralCode']),
          ),
          AdminDetailRow(
            label: 'Joined',
            value: adminDateTimeLabel(adminDate(user['createdAt'])),
          ),
          AdminDetailRow(
            label: 'Last login',
            value: adminDateTimeLabel(adminDate(user['lastLogin'])),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersCard(List<Map<String, dynamic>> orders) {
    return AdminCard(
      title: 'Recent orders',
      child: orders.isEmpty
          ? Text(
              'No orders placed yet.',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            )
          : Column(
              children: [
                for (final order in orders)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${adminString(order['orderNumber'], '—')}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${adminLabel(adminString(order['orderType'], 'delivery'))} · '
                                '${adminDateLabel(adminDate(order['createdAt']))}',
                                style: TextStyle(
                                    fontSize: 11.sp, color: AdminColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          adminMoney(adminDouble(order['totalAmount'])),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        AdminStatusPill(
                          label: adminLabel(adminString(order['status'])),
                          color: AdminColors.orderStatus(adminString(order['status'])),
                          compact: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildTransactionsCard(List<Map<String, dynamic>> transactions) {
    return AdminCard(
      title: 'Recent wallet transactions',
      child: transactions.isEmpty
          ? Text(
              'No wallet transactions yet.',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            )
          : Column(
              children: [
                for (final tx in transactions)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminLabel(adminString(tx['type'])),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              Text(
                                adminDateTimeLabel(adminDate(tx['createdAt'])),
                                style: TextStyle(
                                    fontSize: 11.sp, color: AdminColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          adminMoney(adminDouble(tx['amount'])),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        AdminStatusPill(
                          label: adminLabel(adminString(tx['status'], 'completed')),
                          color: adminString(tx['status']) == 'failed' ||
                                  adminString(tx['status']) == 'cancelled'
                              ? AdminColors.danger
                              : adminString(tx['status']) == 'pending'
                                  ? AdminColors.warning
                                  : AdminColors.success,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildActionsCard(Map<String, dynamic> user) {
    final banned = adminBool(user['isActive'], true) == false;
    final id = adminString(user['_id']);
    final name = adminString(user['fullName'], 'this user');

    return AdminCard(
      title: 'Moderation',
      child: Obx(() {
        final busy = controller.isMutating.value;
        return Column(
          children: [
            AdminButton(
              label: banned ? 'Reinstate account' : 'Ban account',
              icon: banned ? Icons.lock_open_rounded : Icons.block_rounded,
              color: banned ? AdminColors.success : AdminColors.warning,
              isLoading: busy,
              onPressed: () async {
                final confirmed = await adminConfirm(
                  title: banned ? 'Reinstate $name?' : 'Ban $name?',
                  message: banned
                      ? 'They will be able to sign in again immediately.'
                      : 'They will be blocked from signing in until reinstated.',
                  confirmLabel: banned ? 'Reinstate' : 'Ban',
                  confirmColor: banned ? AdminColors.success : AdminColors.warning,
                );
                if (!confirmed) return;
                // reload:false — the list behind this screen is refreshed on
                // pop; re-fetch the record being viewed instead.
                final ok = await controller.mutate(
                  () => controller.api.banUser(id, !banned),
                  successTitle: banned ? 'User reinstated' : 'User banned',
                  reload: false,
                );
                if (ok) await controller.loadDetails(id);
              },
            ),
            SizedBox(height: 10.h),
            AdminButton(
              label: 'Delete account',
              icon: Icons.delete_outline_rounded,
              color: AdminColors.danger,
              isLoading: busy,
              onPressed: () async {
                final confirmed = await adminConfirm(
                  title: 'Delete $name?',
                  message: 'This permanently removes the account. Their past '
                      'orders are kept as financial records.',
                  confirmLabel: 'Delete',
                );
                if (!confirmed) return;
                final ok = await controller.deleteUser(id);
                if (ok) Get.back();
              },
            ),
          ],
        );
      }),
    );
  }
}
