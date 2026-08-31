import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../modules/auth/controllers/admin_auth_controller.dart';
import '../routes/admin_routes.dart';
import '../theme/admin_theme.dart';
import 'admin_nav_entry.dart';

/// Full navigation for the console. Every entry points at a registered route.
class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({super.key, required this.currentRoute});

  static const List<AdminNavEntry> entries = [
    AdminNavEntry(AdminRoutes.DASHBOARD, 'Dashboard', Icons.dashboard_outlined,
        permission: 'dashboard.read'),
    // The five analytical boards, grouped rather than flattened into the
    // list: nine top-level entries would have become fourteen, and a drawer
    // you must scroll to reach Settings is a worse drawer. The group's own
    // route is the board it opens when tapped.
    AdminNavEntry(
      AdminRoutes.DASH_SALES,
      'Dashboards',
      Icons.insights_outlined,
      children: [
        AdminNavEntry(AdminRoutes.DASH_SALES, 'Sales',
            Icons.trending_up_rounded, permission: 'reports.read'),
        AdminNavEntry(AdminRoutes.DASH_OPERATIONS, 'Operations',
            Icons.local_shipping_outlined, permission: 'dashboard.read'),
        AdminNavEntry(AdminRoutes.DASH_FINANCE, 'Finance',
            Icons.account_balance_wallet_outlined, permission: 'reports.read'),
        AdminNavEntry(AdminRoutes.DASH_MARKETING, 'Marketing',
            Icons.campaign_outlined, permission: 'reports.read'),
        AdminNavEntry(AdminRoutes.DASH_MERCHANTS, 'Merchants',
            Icons.storefront_outlined, permission: 'reports.read'),
      ],
    ),
    AdminNavEntry(AdminRoutes.USERS, 'Users', Icons.people_alt_outlined,
        permission: 'users.read'),
    AdminNavEntry(AdminRoutes.MERCHANTS, 'Merchants', Icons.storefront_outlined,
        permission: 'merchants.read'),
    AdminNavEntry(AdminRoutes.ORDERS, 'Orders', Icons.receipt_long_outlined,
        permission: 'orders.read'),
    AdminNavEntry(AdminRoutes.PRODUCTS, 'Products', Icons.sell_outlined,
        permission: 'products.read'),
    AdminNavEntry(AdminRoutes.INVENTORY, 'Inventory', Icons.inventory_2_outlined,
        permission: 'inventory.read'),
    AdminNavEntry(AdminRoutes.POS, 'Point of Sale', Icons.point_of_sale_outlined,
        permission: 'pos.read'),
    AdminNavEntry(AdminRoutes.REPORTS, 'Reports', Icons.insert_chart_outlined,
        permission: 'reports.read'),
    AdminNavEntry(AdminRoutes.STAFF, 'Staff', Icons.badge_outlined,
        permission: 'staff.read'),
    AdminNavEntry(AdminRoutes.SETTINGS, 'Settings', Icons.settings_outlined,
        permission: 'settings.read'),
  ];

  /// Every destination the drawer can reach, with groups flattened into it.
  /// This is the list to check a route against; `entries` is only the shape
  /// the drawer draws.
  static List<AdminNavEntry> get allEntries =>
      entries.expand((e) => e.flattened).toList();

  /// Whether a route sits inside a group, and so should keep it open.
  static bool isInsideGroup(AdminNavEntry group, String route) =>
      group.children.any((c) => c.route == route);

  /// Whether the signed-in operator may open a destination.
  ///
  /// "Not yet known" counts as allowed: /admin/me may not have answered, and
  /// reading that as "denied" would strip the drawer to nothing on a refresh.
  /// This is presentation only — every screen behind these is gated
  /// server-side too — but a section that always answers 403 is not a section.
  /// Touches the reactive fields `isAllowed` reads, so an enclosing [Obx]
  /// subscribes to them even on the branch that returns early.
  static void watchPermissions() {
    if (!Get.isRegistered<AdminAuthController>()) return;
    final auth = Get.find<AdminAuthController>();
    auth.isIdentityLoaded.value;
    auth.permissions.length;
  }

  static bool isAllowed(AdminNavEntry entry) {
    if (entry.permission == null) return true;
    if (!Get.isRegistered<AdminAuthController>()) return true;
    final auth = Get.find<AdminAuthController>();
    if (!auth.isIdentityLoaded.value) return true;
    return auth.can(entry.permission!);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      backgroundColor: AdminColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            // Reactive, because /admin/me can answer after this is first
            // built — on a refresh the drawer would otherwise stay showing
            // whatever it decided before the permissions arrived.
            child: Obx(() {
              watchPermissions();
              return ListView(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                children: [
                  for (final entry in entries)
                    if (entry.isGroup)
                      _NavGroup(group: entry, currentRoute: currentRoute)
                    else if (isAllowed(entry))
                      _drawerItem(entry, isActive: entry.route == currentRoute),
                ],
              );
            }),
          ),
          const Divider(indent: 20, endIndent: 20, color: AdminColors.divider),
          _buildLogoutButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: AdminColors.primary,
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AdminColors.primary,
                  size: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIPs Admin',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                if (Get.isRegistered<AdminAuthController>())
                  Obx(() {
                    final email = Get.find<AdminAuthController>().adminEmail.value;
                    return Text(
                      email.isEmpty ? 'Platform console' : email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(AdminNavEntry entry, {required bool isActive}) =>
      _navItem(entry, isActive: isActive);
  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Get.back();
            if (Get.isRegistered<AdminAuthController>()) {
              Get.find<AdminAuthController>().confirmLogout();
            }
          },
          icon: Icon(Icons.logout_rounded, size: 18.sp, color: AdminColors.danger),
          label: Text(
            'Sign out',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AdminColors.danger,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            side: BorderSide(color: AdminColors.danger.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ),
    );
  }
}

/// Bottom bar for the five sections an operator moves between constantly.
/// Reports and Settings live in the drawer only.

/// A collapsible section of the drawer.
///
/// Opens automatically when one of its children is the current route, so
/// arriving at a board from anywhere else does not leave the drawer looking
/// as though that section were closed and empty.
class _NavGroup extends StatefulWidget {
  final AdminNavEntry group;
  final String currentRoute;

  const _NavGroup({required this.group, required this.currentRoute});

  @override
  State<_NavGroup> createState() => _NavGroupState();
}

class _NavGroupState extends State<_NavGroup> {
  late bool _open = AdminDrawer.isInsideGroup(widget.group, widget.currentRoute);

  @override
  Widget build(BuildContext context) {
    // Children the signed-in operator cannot open are left out rather than
    // shown and then refused. Presentation only — every board is gated
    // server-side too — but an entry that always answers 403 is not an entry.
    final auth = Get.isRegistered<AdminAuthController>()
        ? Get.find<AdminAuthController>()
        : null;
    // Until /admin/me has answered, nothing is known about this caller, and
    // "unknown" must not be read as "denied" — on a browser refresh the group
    // would otherwise come up empty and hide itself.
    final unknown = auth == null || !auth.isIdentityLoaded.value;
    final visible = widget.group.children
        .where((c) => unknown || AdminDrawer.isAllowed(c))
        .toList();

    if (visible.isEmpty) return const SizedBox.shrink();

    final childActive = visible.any((c) => c.route == widget.currentRoute);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          child: Material(
            color: childActive
                ? AdminColors.primary.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                child: Row(
                  children: [
                    Icon(
                      widget.group.icon,
                      size: 20.sp,
                      color: childActive
                          ? AdminColors.primary
                          : AdminColors.textSecondary,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        widget.group.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              childActive ? FontWeight.w700 : FontWeight.w500,
                          color: childActive
                              ? AdminColors.primary
                              : AdminColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18.sp,
                      color: AdminColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_open)
          for (final child in visible)
            _navItem(
              child,
              isActive: child.route == widget.currentRoute,
              nested: true,
            ),
      ],
    );
  }
}

/// One tappable row in the drawer.
///
/// A plain function rather than a method, because the collapsible group below
/// draws its children with exactly the same row — two copies is how a nested
/// entry ends up highlighting differently from a top-level one.
Widget _navItem(
AdminNavEntry entry, {
required bool isActive,
bool nested = false,
}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(nested ? 28.w : 12.w, 2.h, 12.w, 2.h),
    child: Material(
      color: isActive ? AdminColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Get.back(); // close the drawer first
          if (isActive) return;
          // offNamed, not toNamed: the drawer is lateral navigation, so
          // hopping between sections must not build an unbounded back stack.
          Get.offNamed(entry.route);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(
                entry.icon,
                size: nested ? 17.sp : 20.sp,
                color: isActive ? AdminColors.primary : AdminColors.textSecondary,
              ),
              SizedBox(width: nested ? 12.w : 14.w),
              Text(
                entry.label,
                style: TextStyle(
                  fontSize: nested ? 13.sp : 14.sp,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AdminColors.primary : AdminColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
