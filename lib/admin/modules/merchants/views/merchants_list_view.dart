import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/merchants_controller.dart';

/// Every merchant on the platform, with the approval queue and the
/// activate/deactivate switch that controls whether their storefront is
/// visible to customers.
class MerchantsListView extends GetView<AdminMerchantsController> {
  const MerchantsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Merchants',
      route: AdminRoutes.MERCHANTS,
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
            controller.search.value;
            return AdminSearchField(
              controller: controller.searchController,
              hint: 'Search by store, owner, email or phone',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: const [
                  AdminFilterOption('', 'All'),
                  AdminFilterOption('pending', 'Pending'),
                  AdminFilterOption('under_review', 'In review'),
                  AdminFilterOption('approved', 'Approved'),
                  AdminFilterOption('rejected', 'Rejected'),
                  // Merchant accounts that never submitted a registration —
                  // invisible in the approval funnel but real accounts.
                  AdminFilterOption('none', 'Unregistered'),
                ],
                selected: controller.approvalFilter.value,
                onSelected: controller.setApprovalFilter,
              )),
          SizedBox(height: 8.h),
          Obx(() => AdminFilterChips(
                options: const [
                  AdminFilterOption('', 'Any status'),
                  AdminFilterOption('active', 'Active'),
                  AdminFilterOption('inactive', 'Deactivated'),
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
            controller.approvalFilter.value.isNotEmpty ||
            controller.statusFilter.value.isNotEmpty;
        return AdminEmptyState(
          icon: Icons.storefront_outlined,
          title: filtered ? 'No matching merchants' : 'No merchants yet',
          message: filtered
              ? 'No merchant matches these filters. Try widening the approval or status filter.'
              : 'Merchants appear here once they sign up in the VIPs Merchant app.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          for (final merchant in controller.items) _buildMerchantCard(merchant),
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

  Widget _buildMerchantCard(Map<String, dynamic> merchant) {
    final id = adminString(merchant['_id']);
    final name = controller.displayName(merchant);
    final approval = controller.approvalOf(merchant);
    final active = adminBool(merchant['isActive'], true);
    final logo = adminString(merchant['logo']);

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
              color: controller.isPending(merchant)
                  ? AdminColors.warning.withValues(alpha: 0.4)
                  : AdminColors.border,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildLogo(logo, name),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          adminString(merchant['storeCategory'], 'Uncategorised'),
                          style: TextStyle(fontSize: 11.5.sp, color: AdminColors.textSecondary),
                        ),
                        SizedBox(height: 6.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            AdminStatusPill(
                              label: approval == 'none'
                                  ? 'Not registered'
                                  : adminLabel(approval),
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
                  Obx(() => IconButton(
                        tooltip: 'Actions',
                        onPressed: controller.isMutating.value
                            ? null
                            : () => _showActions(merchant),
                        icon: Icon(Icons.more_vert_rounded,
                            size: 20.sp, color: AdminColors.textMuted),
                      )),
                ],
              ),
              // The approval queue is the whole point of this screen, so a
              // pending merchant gets its decision buttons inline rather
              // than buried two taps deep in the actions sheet.
              if (controller.isPending(merchant)) ...[
                SizedBox(height: 12.h),
                const Divider(height: 1, color: AdminColors.divider),
                SizedBox(height: 10.h),
                Obx(() {
                  final busy = controller.isMutating.value;
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: busy ? null : () => _reject(id, name),
                          icon: Icon(Icons.close_rounded,
                              size: 16.sp, color: AdminColors.danger),
                          label: Text(
                            'Reject',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.danger,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AdminColors.danger.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: busy ? null : () => _approve(id, name),
                          icon: const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white),
                          label: Text(
                            'Approve',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.success,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(String url, String name) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        color: AdminColors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? Center(
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.purple,
                ),
              ),
            )
          : Image.network(
              // The upload route returns http:// URLs from an https-only
              // host; iOS ATS silently drops those, so rewrite as the
              // consumer app's edit-profile screen already does.
              url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.storefront_rounded,
                    size: 20.sp, color: AdminColors.purple),
              ),
            ),
    );
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> _approve(String id, String name) async {
    final confirmed = await adminConfirm(
      title: 'Approve $name?',
      message: 'Their business registration is marked approved and the '
          'account is reactivated if it was disabled.',
      confirmLabel: 'Approve',
      confirmColor: AdminColors.success,
    );
    if (confirmed) await controller.approve(id);
  }

  Future<void> _reject(String id, String name) async {
    final reason = await adminPromptReason(
      title: 'Reject $name',
      message: 'The reason is stored on the registration so the merchant can '
          'be told what to fix.',
      hint: 'e.g. Tax ID missing from the uploaded licence',
      confirmLabel: 'Reject',
    );
    if (reason != null) await controller.reject(id, reason);
  }

  void _showActions(Map<String, dynamic> merchant) {
    final id = adminString(merchant['_id']);
    final name = controller.displayName(merchant);
    final active = adminBool(merchant['isActive'], true);
    final approval = controller.approvalOf(merchant);

    adminSheet(
      title: name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _actionTile(
            icon: Icons.storefront_outlined,
            label: 'View full details',
            color: AdminColors.info,
            onTap: () {
              Get.back();
              _openDetails(id);
            },
          ),
          if (approval != 'none') ...[
            _actionTile(
              icon: Icons.check_circle_outline_rounded,
              label: approval == 'approved' ? 'Already approved' : 'Approve registration',
              color: AdminColors.success,
              onTap: approval == 'approved'
                  ? null
                  : () {
                      Get.back();
                      _approve(id, name);
                    },
            ),
            _actionTile(
              icon: Icons.cancel_outlined,
              label: approval == 'rejected' ? 'Already rejected' : 'Reject registration',
              color: AdminColors.danger,
              onTap: approval == 'rejected'
                  ? null
                  : () {
                      Get.back();
                      _reject(id, name);
                    },
            ),
          ] else
            _actionTile(
              icon: Icons.assignment_late_outlined,
              label: 'No registration submitted yet',
              color: AdminColors.textMuted,
              onTap: null,
            ),
          _actionTile(
            icon: active ? Icons.pause_circle_outline : Icons.play_circle_outline,
            label: active ? 'Deactivate merchant' : 'Activate merchant',
            color: active ? AdminColors.warning : AdminColors.success,
            onTap: () async {
              Get.back();
              final confirmed = await adminConfirm(
                title: active ? 'Deactivate $name?' : 'Activate $name?',
                message: active
                    ? 'Their products are hidden from customers and they cannot sign in.'
                    : 'Their products become visible to customers again.',
                confirmLabel: active ? 'Deactivate' : 'Activate',
                confirmColor: active ? AdminColors.warning : AdminColors.success,
              );
              if (confirmed) await controller.setActive(id, !active);
            },
          ),
          _actionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete merchant',
            color: AdminColors.danger,
            onTap: () async {
              Get.back();
              final confirmed = await adminConfirm(
                title: 'Delete $name?',
                message: 'Removes the account along with its products, stock '
                    'and registration. Refused while any order is still in progress.',
                confirmLabel: 'Delete',
              );
              if (confirmed) await controller.deleteMerchant(id);
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

  Future<void> _openDetails(String id) async {
    await Get.toNamed(AdminRoutes.merchantDetails(id));
    await controller.load();
  }
}
