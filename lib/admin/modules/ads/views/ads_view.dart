import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/ads_controller.dart';

class AdminAdsView extends GetView<AdminAdsController> {
  const AdminAdsView({super.key});

  @override
  Widget build(BuildContext context) => AdminScaffold(
    title: 'Advertisements',
    route: AdminRoutes.ADS,
    onRefresh: controller.load,
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Column(
            children: [
              AdminSearchField(
                controller: controller.searchController,
                hint: 'Search title, audience or merchant',
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),
              SizedBox(height: 8.h),
              Obx(
                () => AdminFilterChips(
                  options: const [
                    AdminFilterOption('', 'All'),
                    AdminFilterOption('pending', 'Pending'),
                    AdminFilterOption('approved', 'Approved'),
                    AdminFilterOption('rejected', 'Rejected'),
                  ],
                  selected: controller.moderation.value,
                  onSelected: controller.setModeration,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Obx(_content)),
      ],
    ),
  );

  Widget _content() {
    if (controller.isLoading.value && controller.items.isEmpty) {
      return const AdminLoading();
    }
    if (controller.errorMessage.isNotEmpty && controller.items.isEmpty) {
      return AdminErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.load,
      );
    }
    if (controller.items.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.campaign_outlined,
        title: 'No advertisements found',
        message: 'Campaigns submitted by merchants appear here for review.',
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        for (final ad in controller.items) _card(ad),
        AdminPaginator(
          page: controller.page.value,
          pages: controller.pages.value,
          total: controller.total.value,
          onPrevious: controller.previousPage,
          onNext: controller.nextPage,
        ),
      ],
    );
  }

  Widget _card(Map<String, dynamic> ad) {
    final moderation = adminString(ad['moderationStatus'], 'pending');
    final color =
        moderation == 'approved'
            ? AdminColors.success
            : moderation == 'rejected'
            ? AdminColors.danger
            : AdminColors.warning;
    return AdminCard(
      title: adminString(ad['title'], 'Untitled campaign'),
      subtitle:
          '${adminString(ad['merchantName'], 'Unknown store')} • ${adminLabel(adminString(ad['adType']))}',
      trailing: AdminStatusPill(label: adminLabel(moderation), color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(adminString(ad['description'], 'No description')),
          SizedBox(height: 8.h),
          Text(
            '${adminCount(adminInt(ad['impressions']))} impressions • ${adminCount(adminInt(ad['clicks']))} clicks',
          ),
          if (controller.canModerate)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _reject(ad),
                  child: const Text('Reject'),
                ),
                FilledButton(
                  onPressed:
                      () =>
                          controller.decide(adminString(ad['_id']), 'approved'),
                  child: const Text('Approve'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _reject(Map<String, dynamic> ad) {
    final reason = TextEditingController();
    adminSheet(
      title: 'Reject advertisement',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: reason,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason shown in the record',
            ),
          ),
          SizedBox(height: 16.h),
          AdminButton(
            label: 'Reject advertisement',
            icon: Icons.block_outlined,
            onPressed: () async {
              if (reason.text.trim().length < 3) {
                return adminToast(
                  'Reason required',
                  'Explain why the advertisement is rejected.',
                  isError: true,
                );
              }
              final ok = await controller.decide(
                adminString(ad['_id']),
                'rejected',
                reason: reason.text.trim(),
              );
              if (ok) Get.back<void>();
            },
          ),
        ],
      ),
    );
  }
}
