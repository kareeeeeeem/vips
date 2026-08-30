import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../services/admin_api_service.dart';
import '../routes/admin_routes.dart';
import '../theme/admin_theme.dart';
import 'admin_scaffold.dart';
import 'admin_widgets.dart';

/// Backs the top bar's notification bell and global search box.
///
/// Registered permanently in `main_admin.dart`: the bell count is shown on
/// every screen, so it must survive route changes rather than refetching on
/// each one.
class AdminTopBarController extends GetxController {
  final AdminApiService _api = AdminApiService();

  // ── Notifications ──
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxInt urgentCount = 0.obs;
  final RxBool isLoadingNotifications = false.obs;

  // ── Global search ──
  final TextEditingController searchController = TextEditingController();
  final RxString query = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> userResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> merchantResults = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> orderResults = <Map<String, dynamic>>[].obs;

  Timer? _debounce;

  int get badgeCount => notifications.length;

  @override
  void onInit() {
    super.onInit();
    // Load once at startup so the bell carries a real count from the first
    // screen. Without this the badge stays blank until someone taps it, which
    // reads as "nothing to do" when there may be a queue waiting.
    loadNotifications();
  }

  bool get hasResults =>
      userResults.isNotEmpty || merchantResults.isNotEmpty || orderResults.isNotEmpty;

  Future<void> loadNotifications() async {
    isLoadingNotifications.value = true;
    try {
      final response = await _api.notifications();
      if (response.success && response.data is Map) {
        notifications.value = adminItems(response.data);
        urgentCount.value = adminInt((response.data as Map)['urgent']);
      }
    } catch (e) {
      debugPrint('[ADMIN TOPBAR] loadNotifications failed: $e');
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  /// The backend ignores anything shorter than 2 characters, so don't spend a
  /// request on it — just clear the panel.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    final term = value.trim();
    query.value = term;
    if (term.length < 2) {
      _clearResults();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => search(term));
  }

  Future<void> search(String term) async {
    isSearching.value = true;
    try {
      final response = await _api.search(term);
      if (response.success && response.data is Map) {
        userResults.value = adminItems(response.data, 'users');
        merchantResults.value = adminItems(response.data, 'merchants');
        orderResults.value = adminItems(response.data, 'orders');
      }
    } catch (e) {
      debugPrint('[ADMIN TOPBAR] search failed: $e');
      _clearResults();
    } finally {
      isSearching.value = false;
    }
  }

  void _clearResults() {
    userResults.clear();
    merchantResults.clear();
    orderResults.clear();
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    query.value = '';
    _clearResults();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}

/// The notification bell. Its badge counts distinct backlogs, and every row
/// navigates to the filtered screen that resolves it — no dead entries.
class AdminNotificationBell extends StatelessWidget {
  const AdminNotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminTopBarController>()) return const SizedBox.shrink();
    final controller = Get.find<AdminTopBarController>();

    return Obx(() {
      final count = controller.badgeCount;
      final urgent = controller.urgentCount.value > 0;
      return IconButton(
        tooltip: count == 0 ? 'Nothing needs attention' : '$count need attention',
        onPressed: () => _openPanel(controller),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 21.sp, color: AdminColors.textSecondary),
            if (count > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  constraints: BoxConstraints(minWidth: 15.w),
                  decoration: BoxDecoration(
                    color: urgent ? AdminColors.danger : AdminColors.info,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _openPanel(AdminTopBarController controller) {
    controller.loadNotifications();
    adminSheet(
      title: 'Needs attention',
      child: Obx(() {
        if (controller.isLoadingNotifications.value && controller.notifications.isEmpty) {
          return const AdminLoading();
        }
        if (controller.notifications.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 20.sp, color: AdminColors.success),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Nothing needs your attention right now.',
                    style: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final item in controller.notifications) _row(item),
          ],
        );
      }),
    );
  }

  Widget _row(Map<String, dynamic> item) {
    final severity = adminString(item['severity'], 'info');
    final color = switch (severity) {
      'danger' => AdminColors.danger,
      'warning' => AdminColors.warning,
      'muted' => AdminColors.textSecondary,
      _ => AdminColors.info,
    };
    final route = adminString(item['route']);

    return InkWell(
      // A row with no destination (payout requests have no screen yet) is
      // shown as plain text rather than a button that would do nothing.
      onTap: route.isEmpty
          ? null
          : () {
              Get.back();
              final args = item['args'];
              Get.toNamed(
                route,
                arguments: args is Map ? Map<String, dynamic>.from(args) : null,
              );
            },
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                adminCount(adminInt(item['count'])),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                adminString(item['title']),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
            ),
            if (route.isNotEmpty)
              Icon(Icons.chevron_right, size: 18.sp, color: AdminColors.textMuted)
            else
              Text(
                'No screen yet',
                style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

/// Global search across users, merchants and orders — one box instead of
/// making the operator guess which section a name or order number lives in.
class AdminGlobalSearch extends StatelessWidget {
  const AdminGlobalSearch({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminTopBarController>()) return const SizedBox.shrink();
    final controller = Get.find<AdminTopBarController>();

    return IconButton(
      tooltip: 'Search everything',
      onPressed: () => _open(controller),
      icon: Icon(Icons.search_rounded, size: 21.sp, color: AdminColors.textSecondary),
    );
  }

  void _open(AdminTopBarController controller) {
    controller.clearSearch();
    adminSheet(
      title: 'Search',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            controller.query.value;
            return AdminSearchField(
              controller: controller.searchController,
              hint: 'Name, email, phone, store or order number',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 16.h),
          Obx(() {
            if (controller.query.value.length < 2) {
              return _hint('Type at least 2 characters to search.');
            }
            if (controller.isSearching.value && !controller.hasResults) {
              return const AdminLoading();
            }
            if (!controller.hasResults) {
              return _hint('Nothing matches "${controller.query.value}".');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.userResults.isNotEmpty) ...[
                  _heading('Users', controller.userResults.length),
                  for (final user in controller.userResults)
                    _result(
                      icon: Icons.person_outline_rounded,
                      color: AdminColors.info,
                      title: adminString(user['fullName'], 'Unnamed'),
                      subtitle: adminString(user['email']),
                      onTap: () => _go(AdminRoutes.userDetails(adminString(user['_id']))),
                    ),
                  SizedBox(height: 14.h),
                ],
                if (controller.merchantResults.isNotEmpty) ...[
                  _heading('Merchants', controller.merchantResults.length),
                  for (final merchant in controller.merchantResults)
                    _result(
                      icon: Icons.storefront_outlined,
                      color: AdminColors.purple,
                      title: adminString(
                        merchant['storeName'],
                        adminString(merchant['fullName'], 'Unnamed'),
                      ),
                      subtitle: adminString(merchant['email']),
                      onTap: () =>
                          _go(AdminRoutes.merchantDetails(adminString(merchant['_id']))),
                    ),
                  SizedBox(height: 14.h),
                ],
                if (controller.orderResults.isNotEmpty) ...[
                  _heading('Orders', controller.orderResults.length),
                  for (final order in controller.orderResults)
                    _result(
                      icon: Icons.receipt_long_outlined,
                      color: AdminColors.accent,
                      title: 'Order #${adminString(order['orderNumber'], '—')} · '
                          '${adminMoney(adminDouble(order['totalAmount']))}',
                      subtitle: '${adminString(order['customerName'], 'Unknown')} · '
                          '${adminLabel(adminString(order['status']))}',
                      onTap: () => _go(AdminRoutes.orderDetails(adminString(order['_id']))),
                    ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  void _go(String route) {
    Get.back();
    Get.toNamed(route);
  }

  Widget _heading(String label, int count) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.textSecondary,
              ),
            ),
            SizedBox(width: 6.w),
            Text('($count)',
                style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted)),
          ],
        ),
      );

  Widget _result({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16.sp, color: AdminColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
        ),
      );
}
