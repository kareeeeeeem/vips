import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/broadcasts_controller.dart';

class AdminBroadcastsView extends GetView<AdminBroadcastsController> {
  const AdminBroadcastsView({super.key});

  @override
  Widget build(BuildContext context) => AdminScaffold(
    title: 'Broadcasts',
    route: AdminRoutes.BROADCASTS,
    onRefresh: controller.load,
    floatingActionButton:
        controller.canSend
            ? FloatingActionButton.extended(
              onPressed: _compose,
              icon: const Icon(Icons.send_outlined),
              label: const Text('New broadcast'),
            )
            : null,
    body: Obx(_content),
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
        icon: Icons.notifications_active_outlined,
        title: 'No broadcasts sent',
        message:
            'Messages sent to customers and merchants will be recorded here.',
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        for (final item in controller.items)
          AdminCard(
            title: adminString(item['title'], 'Untitled'),
            subtitle:
                '${adminLabel(adminString(item['audience']))} • ${adminDateLabel(adminDate(item['createdAt']))}',
            trailing: AdminStatusPill(
              label:
                  '${adminInt(item['customerCount']) + adminInt(item['merchantCount'])} sent',
              color: AdminColors.success,
            ),
            child: Text(adminString(item['message'])),
          ),
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

  void _compose() {
    final title = TextEditingController();
    final message = TextEditingController();
    final actionUrl = TextEditingController();
    final audience = 'customers'.obs;
    final type = 'system'.obs;
    adminSheet(
      title: 'Send broadcast',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: title,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: message,
            maxLength: 1000,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: audience.value,
              decoration: const InputDecoration(labelText: 'Audience'),
              items: const [
                DropdownMenuItem(value: 'customers', child: Text('Customers')),
                DropdownMenuItem(value: 'merchants', child: Text('Merchants')),
                DropdownMenuItem(value: 'all', child: Text('Everyone')),
              ],
              onChanged: (value) => audience.value = value ?? 'customers',
            ),
          ),
          SizedBox(height: 10.h),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: type.value,
              decoration: const InputDecoration(labelText: 'Message type'),
              items: const [
                DropdownMenuItem(value: 'system', child: Text('System')),
                DropdownMenuItem(value: 'promotion', child: Text('Promotion')),
                DropdownMenuItem(value: 'account', child: Text('Account')),
              ],
              onChanged: (value) => type.value = value ?? 'system',
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: actionUrl,
            decoration: const InputDecoration(
              labelText: 'Internal action path (optional)',
              hintText: '/wallet',
            ),
          ),
          SizedBox(height: 16.h),
          AdminButton(
            label: 'Send now',
            icon: Icons.send_outlined,
            onPressed: () async {
              if (title.text.trim().length < 3 ||
                  message.text.trim().length < 3) {
                return adminToast(
                  'Content required',
                  'Enter a title and message.',
                  isError: true,
                );
              }
              final ok = await controller.send(
                title: title.text.trim(),
                message: message.text.trim(),
                audience: audience.value,
                type: type.value,
                actionUrl: actionUrl.text.trim(),
              );
              if (ok) Get.back<void>();
            },
          ),
        ],
      ),
    );
  }
}
