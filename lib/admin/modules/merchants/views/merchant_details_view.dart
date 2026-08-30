import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/merchants_controller.dart';

/// The merchant's full record: store profile, the business registration they
/// submitted, sales performance, recent orders and their advertising spend.
class MerchantDetailsView extends GetView<AdminMerchantsController> {
  const MerchantDetailsView({super.key});

  /// The id comes from the `:id` path segment. Get.arguments is kept as a
  /// fallback so a caller that passes it as an argument still resolves.
  String get _merchantId {
    final param = Get.parameters['id'];
    if (param != null && param.isNotEmpty) return param;
    final args = Get.arguments;
    return args is Map ? adminString(args['id']) : '';
  }

  @override
  Widget build(BuildContext context) {
    if (_merchantId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Merchant')),
        body: AdminEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'No merchant selected',
          message: 'This screen needs a merchant id. Open it from the Merchants list.',
          action: AdminButton(label: 'Back', expand: false, onPressed: Get.back),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.details.value == null && !controller.isLoadingDetails.value) {
        controller.loadDetails(_merchantId);
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
          'Merchant',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadDetails(_merchantId),
            icon: Icon(Icons.refresh_rounded, size: 20.sp, color: AdminColors.textSecondary),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetails.value) return const AdminLoading();

        final data = controller.details.value;
        if (data == null) {
          return AdminErrorState(
            message: 'Could not load this merchant.',
            onRetry: () => controller.loadDetails(_merchantId),
          );
        }

        final merchant = data['merchant'] is Map
            ? Map<String, dynamic>.from(data['merchant'] as Map)
            : <String, dynamic>{};
        final registration = data['registration'] is Map
            ? Map<String, dynamic>.from(data['registration'] as Map)
            : null;
        final stats = data['stats'] is Map
            ? Map<String, dynamic>.from(data['stats'] as Map)
            : <String, dynamic>{};
        final approval = adminString(data['approvalStatus'], 'none');

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            _buildHeader(merchant, approval),
            SizedBox(height: 16.h),
            _buildStats(stats),
            SizedBox(height: 16.h),
            _buildStoreCard(merchant),
            SizedBox(height: 16.h),
            _buildRegistrationCard(registration, approval),
            SizedBox(height: 16.h),
            _buildOrdersCard(adminItems(data, 'recentOrders')),
            SizedBox(height: 16.h),
            _buildAdsCard(adminItems(data, 'ads')),
            SizedBox(height: 16.h),
            _buildActionsCard(merchant, approval),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(Map<String, dynamic> merchant, String approval) {
    final name = controller.displayName(merchant);
    final active = adminBool(merchant['isActive'], true);

    return AdminCard(
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: AdminColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.purple,
                ),
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
                  adminString(merchant['email'], 'No email'),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    AdminStatusPill(
                      label: approval == 'none' ? 'Not registered' : adminLabel(approval),
                      color: AdminColors.approvalStatus(approval),
                      compact: true,
                    ),
                    AdminStatusPill(
                      label: active ? 'Active' : 'Deactivated',
                      color: active ? AdminColors.success : AdminColors.textSecondary,
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

  Widget _buildStats(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: AdminStatCard(
            label: 'Revenue',
            value: adminMoney(adminDouble(stats['revenue'])),
            icon: Icons.payments_rounded,
            color: AdminColors.success,
          ),
        ),
        SizedBox(width: 10.w),
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
            label: 'Products',
            value: adminCount(adminInt(stats['products'])),
            icon: Icons.inventory_2_rounded,
            color: AdminColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> merchant) {
    return AdminCard(
      title: 'Store profile',
      child: Column(
        children: [
          AdminDetailRow(label: 'Owner', value: adminString(merchant['fullName'])),
          AdminDetailRow(label: 'Phone', value: adminString(merchant['phone'])),
          AdminDetailRow(
            label: 'Category',
            value: adminString(merchant['storeCategory'], 'Uncategorised'),
          ),
          // storeAddress / storeDescription, not address / description — the
          // latter are not User fields and mongoose drops them silently.
          AdminDetailRow(label: 'Address', value: adminString(merchant['storeAddress'])),
          AdminDetailRow(
            label: 'Description',
            value: adminString(merchant['storeDescription']),
          ),
          AdminDetailRow(
            label: 'Wallet',
            value: adminMoney(adminDouble(merchant['walletBalance'])),
          ),
          AdminDetailRow(label: 'Package', value: adminString(merchant['packageName'], 'Free')),
          AdminDetailRow(
            label: 'Trending',
            value: adminBool(merchant['isTrending']) ? 'Yes' : 'No',
          ),
          AdminDetailRow(
            label: 'Joined',
            value: adminDateTimeLabel(adminDate(merchant['createdAt'])),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationCard(Map<String, dynamic>? registration, String approval) {
    if (registration == null) {
      return AdminCard(
        title: 'Business registration',
        child: Row(
          children: [
            Icon(Icons.assignment_late_outlined, size: 18.sp, color: AdminColors.textMuted),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'This merchant has not submitted a business registration, so '
                'there is nothing to approve or reject yet.',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color: AdminColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final rejection = adminString(registration['rejectionReason']);

    return AdminCard(
      title: 'Business registration',
      trailing: AdminStatusPill(
        label: adminLabel(approval),
        color: AdminColors.approvalStatus(approval),
        compact: true,
      ),
      child: Column(
        children: [
          AdminDetailRow(label: 'Business', value: adminString(registration['businessName'])),
          AdminDetailRow(label: 'Type', value: adminString(registration['businessType'])),
          AdminDetailRow(label: 'Owner', value: adminString(registration['ownerName'])),
          AdminDetailRow(label: 'Job title', value: adminString(registration['jobTitle'])),
          AdminDetailRow(label: 'Email', value: adminString(registration['email'])),
          AdminDetailRow(label: 'Phone', value: adminString(registration['phone'])),
          AdminDetailRow(label: 'Address', value: adminString(registration['address'])),
          AdminDetailRow(label: 'City', value: adminString(registration['city'])),
          AdminDetailRow(label: 'Country', value: adminString(registration['country'])),
          AdminDetailRow(label: 'Tax ID', value: adminString(registration['taxId'])),
          AdminDetailRow(
            label: 'Licence expiry',
            value: adminDateLabel(adminDate(registration['licenseExpiry'])),
          ),
          AdminDetailRow(
            label: 'Loyalty type',
            value: adminLabel(adminString(registration['loyaltyType'], 'everywhere')),
          ),
          AdminDetailRow(
            label: 'Submitted',
            value: adminDateTimeLabel(adminDate(registration['createdAt'])),
          ),
          AdminDetailRow(
            label: 'Reviewed',
            value: adminDateTimeLabel(adminDate(registration['reviewedAt'])),
          ),
          if (rejection.isNotEmpty)
            AdminDetailRow(
              label: 'Rejection reason',
              value: rejection,
              valueColor: AdminColors.danger,
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersCard(List<Map<String, dynamic>> orders) {
    return AdminCard(
      title: 'Recent orders',
      trailing: TextButton(
        onPressed: () => Get.toNamed(
          AdminRoutes.ORDERS,
          arguments: {'merchantId': _merchantId},
        ),
        child: Text('View all', style: TextStyle(fontSize: 12.sp)),
      ),
      child: orders.isEmpty
          ? Text(
              'No orders yet.',
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
                          child: Text(
                            '#${adminString(order['orderNumber'], '—')} · '
                            '${adminDateLabel(adminDate(order['createdAt']))}',
                            style: TextStyle(
                                fontSize: 12.sp, color: AdminColors.textSecondary),
                          ),
                        ),
                        Text(
                          adminMoney(adminDouble(order['totalAmount'])),
                          style: TextStyle(
                            fontSize: 12.sp,
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

  Widget _buildAdsCard(List<Map<String, dynamic>> ads) {
    if (ads.isEmpty) return const SizedBox.shrink();

    return AdminCard(
      title: 'Advertising',
      child: Column(
        children: [
          for (final ad in ads)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 7.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminString(ad['title'], 'Untitled'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${adminCount(adminInt(ad['impressions']))} impressions · '
                          '${adminCount(adminInt(ad['clicks']))} clicks',
                          style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${adminMoney(adminDouble(ad['spentAmount']))} / '
                        '${adminMoney(adminDouble(ad['budget']))}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      AdminStatusPill(
                        label: adminLabel(adminString(ad['status'])),
                        color: adminString(ad['status']) == 'active'
                            ? AdminColors.success
                            : AdminColors.textSecondary,
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

  Widget _buildActionsCard(Map<String, dynamic> merchant, String approval) {
    final id = adminString(merchant['_id']);
    final name = controller.displayName(merchant);
    final active = adminBool(merchant['isActive'], true);
    final canDecide = approval != 'none';

    return AdminCard(
      title: 'Actions',
      child: Obx(() {
        final busy = controller.isMutating.value;
        return Column(
          children: [
            if (canDecide) ...[
              Row(
                children: [
                  Expanded(
                    child: AdminButton(
                      label: 'Approve',
                      icon: Icons.check_rounded,
                      color: AdminColors.success,
                      isLoading: busy,
                      onPressed: approval == 'approved'
                          ? null
                          : () async {
                              final confirmed = await adminConfirm(
                                title: 'Approve $name?',
                                message: 'Marks the registration approved and '
                                    'reactivates the account if it was disabled.',
                                confirmLabel: 'Approve',
                                confirmColor: AdminColors.success,
                              );
                              if (!confirmed) return;
                              final ok = await controller.mutate(
                                () => controller.api.approveMerchant(id, true),
                                successTitle: 'Merchant approved',
                                reload: false,
                              );
                              if (ok) await controller.loadDetails(id);
                            },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: AdminButton(
                      label: 'Reject',
                      icon: Icons.close_rounded,
                      color: AdminColors.danger,
                      isLoading: busy,
                      onPressed: approval == 'rejected'
                          ? null
                          : () async {
                              final reason = await adminPromptReason(
                                title: 'Reject $name',
                                message: 'The reason is stored on the registration.',
                                hint: 'e.g. Licence document unreadable',
                                confirmLabel: 'Reject',
                              );
                              if (reason == null) return;
                              final ok = await controller.mutate(
                                () => controller.api
                                    .approveMerchant(id, false, reason: reason),
                                successTitle: 'Merchant rejected',
                                reload: false,
                              );
                              if (ok) await controller.loadDetails(id);
                            },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
            AdminButton(
              label: active ? 'Deactivate merchant' : 'Activate merchant',
              icon: active ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: active ? AdminColors.warning : AdminColors.success,
              isLoading: busy,
              onPressed: () async {
                final confirmed = await adminConfirm(
                  title: active ? 'Deactivate $name?' : 'Activate $name?',
                  message: active
                      ? 'Their products are hidden from customers and they cannot sign in.'
                      : 'Their products become visible to customers again.',
                  confirmLabel: active ? 'Deactivate' : 'Activate',
                  confirmColor: active ? AdminColors.warning : AdminColors.success,
                );
                if (!confirmed) return;
                final ok = await controller.mutate(
                  () => controller.api.activateMerchant(id, !active),
                  successTitle: active ? 'Merchant deactivated' : 'Merchant activated',
                  reload: false,
                );
                if (ok) await controller.loadDetails(id);
              },
            ),
            SizedBox(height: 10.h),
            AdminButton(
              label: 'Delete merchant',
              icon: Icons.delete_outline_rounded,
              color: AdminColors.danger,
              isLoading: busy,
              onPressed: () async {
                final confirmed = await adminConfirm(
                  title: 'Delete $name?',
                  message: 'Removes the account with its products, stock and '
                      'registration. Refused while any order is still in progress.',
                  confirmLabel: 'Delete',
                );
                if (!confirmed) return;
                final ok = await controller.deleteMerchant(id);
                if (ok) Get.back();
              },
            ),
          ],
        );
      }),
    );
  }
}
