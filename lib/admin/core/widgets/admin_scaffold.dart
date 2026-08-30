import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../modules/auth/controllers/admin_auth_controller.dart';
import '../routes/admin_routes.dart';
import '../theme/admin_theme.dart';
import 'admin_bottom_nav.dart';
import 'admin_drawer.dart';
import 'admin_top_bar.dart';
import 'admin_widgets.dart';

/// The console shell: a top bar, the navigation drawer, and a bottom bar for
/// the five most-used sections.
///
/// Every top-level screen wraps its body in this, so navigation is defined
/// once instead of being re-hand-rolled per screen (the failure mode that
/// left the merchant app with quick-action tiles pointing at the wrong
/// screens).
class AdminScaffold extends StatelessWidget {
  final String title;
  final String route;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.route,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final content = onRefresh == null
        ? body
        : RefreshIndicator(
            onRefresh: onRefresh!,
            color: AdminColors.primary,
            child: body,
          );

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        actions: [
          ...?actions,
          // Search and notifications sit on every screen, per the console
          // spec's top bar: admin avatar, notifications, search.
          const AdminGlobalSearch(),
          const AdminNotificationBell(),
          SizedBox(width: 4.w),
          const _AdminAvatar(),
          SizedBox(width: 12.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(height: 1.h, color: AdminColors.border),
        ),
      ),
      drawer: AdminDrawer(currentRoute: route),
      body: SafeArea(child: content),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: AdminBottomNav(currentRoute: route),
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  const _AdminAvatar();

  @override
  Widget build(BuildContext context) {
    // The auth controller is permanent, but a hot reload onto a detail route
    // can rebuild this before it is registered — fall back rather than throw.
    if (!Get.isRegistered<AdminAuthController>()) return const SizedBox.shrink();
    final auth = Get.find<AdminAuthController>();

    return Obx(() {
      final name = auth.adminName.value;
      final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
      return PopupMenuButton<String>(
        tooltip: 'Account',
        offset: Offset(0, 44.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        onSelected: (value) {
          if (value == 'settings') Get.toNamed(AdminRoutes.SETTINGS);
          if (value == 'logout') auth.confirmLogout();
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Administrator' : name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                Text(
                  auth.adminEmail.value,
                  style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_outlined, size: 18.sp, color: AdminColors.textSecondary),
                SizedBox(width: 10.w),
                Text('Settings', style: TextStyle(fontSize: 13.sp)),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 18.sp, color: AdminColors.danger),
                SizedBox(width: 10.w),
                Text(
                  'Sign out',
                  style: TextStyle(fontSize: 13.sp, color: AdminColors.danger),
                ),
              ],
            ),
          ),
        ],
        child: CircleAvatar(
          radius: 16.r,
          backgroundColor: AdminColors.primary,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }
}

/// Standard confirm dialog for a destructive console action.
/// Returns true only when the operator explicitly confirms.
Future<bool> adminConfirm({
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  Color confirmColor = AdminColors.danger,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AdminColors.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text('Cancel', style: TextStyle(color: AdminColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text(confirmLabel, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  return result == true;
}

/// Confirm dialog that also collects a required free-text reason
/// (merchant rejection, order cancellation). Returns null when cancelled.
Future<String?> adminPromptReason({
  required String title,
  required String message,
  required String hint,
  String confirmLabel = 'Submit',
}) async {
  final controller = TextEditingController();
  final error = RxnString();

  final result = await Get.dialog<String>(
    AlertDialog(
      backgroundColor: AdminColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
          color: AdminColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          Obx(() => TextField(
                controller: controller,
                maxLines: 3,
                minLines: 2,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(fontSize: 13.sp, color: AdminColors.textMuted),
                  errorText: error.value,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: Text('Cancel', style: TextStyle(color: AdminColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            final text = controller.text.trim();
            // The backend rejects an empty reason with a 400; catching it
            // here means the operator sees why without a round trip.
            if (text.isEmpty) {
              error.value = 'A reason is required.';
              return;
            }
            Get.back(result: text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text(confirmLabel, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  controller.dispose();
  return result;
}

/// Bottom sheet host used by every detail screen in the console.
Future<T?> adminSheet<T>({required String title, required Widget child}) {
  return Get.bottomSheet<T>(
    Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AdminColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 12.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, size: 20.sp, color: AdminColors.textSecondary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AdminColors.divider),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: child,
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

/// Shared loading placeholder so every screen looks the same while fetching.
class AdminLoading extends StatelessWidget {
  const AdminLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
        ),
      ),
    );
  }
}

/// Re-exported so screens import one file for the whole kit.
typedef AdminEmpty = AdminEmptyState;
