import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../design_system/atoms/app_colors.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<MenuSection> get menuSections => [
    MenuSection(
      title: 'Account',
      items: [
        MenuItem(
          icon: AppIcons.editProfile,
          title: 'Edit Profile',
          onTap: () => Navigator.pushNamed(context, 'EditProfile'),
        ),
        MenuItem(
          icon: AppIcons.notificationProfile,
          title: 'Notifications',
          onTap: () => Navigator.pushNamed(context, 'Notifications'),
        ),
        MenuItem(
          icon: AppIcons.paymentMethods,
          title: 'Payment Methods',
          onTap: () => Navigator.pushNamed(context, 'CompletePayment'),
        ),
        MenuItem(
          icon: AppIcons.paymentMethods,
          title: 'Wallet',
          onTap: () => Navigator.pushNamed(context, 'Wallet'),
        ),
      ],
    ),
    MenuSection(
      title: 'Business',
      items: [
        MenuItem(
          icon: AppIcons.partnership,
          title: 'Partnership',
          onTap: () => _showPartnership(),
        ),
        MenuItem(
          icon: AppIcons.shareNodes,
          title: 'Refer Friends & Earn',
          onTap: () => Navigator.pushNamed(context, 'ReferFriends'),
        ),
      ],
    ),
    MenuSection(
      title: 'Support',
      items: [
        MenuItem(
          icon: AppIcons.Settings,
          title: 'Settings',
          onTap: () => Navigator.pushNamed(context, 'Settings'),
          useSystemIcon: true,
        ),
        MenuItem(icon: AppIcons.aboutVIPs, title: 'About VIPs', onTap: () {}),
        MenuItem(
          icon: AppIcons.helpSupport,
          title: 'Help & Support',
          onTap: () => Navigator.pushNamed(context, 'HelpSupport'),
        ),
      ],
    ),
    MenuSection(
      title: 'Legal',
      items: [
        MenuItem(
          icon: AppIcons.privacyPolicy,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        MenuItem(
          icon: AppIcons.privacyPolicy,
          title: 'Terms of Use',
          onTap: () {},
        ),
      ],
    ),
  ];

  void _showPartnership() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
          ),
    );
  }

  void _showLogOut() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildMenuContent(),
              _buildLogoutSection(),
              _buildVersionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Image.asset(AppImages.Logo, width: 24.w, height: 22.h),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF6B7280),
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                        fontFamily: 'SF Pro Display',
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Manage your account and preferences',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent() {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: menuSections.length,
      itemBuilder: (context, sectionIndex) {
        final section = menuSections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionIndex > 0) SizedBox(height: 32.h),

            Text(
              section.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
                fontFamily: 'SF Pro Display',
              ),
            ),

            SizedBox(height: 12.h),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE8ECF4), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children:
                    section.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isLast = index == section.items.length - 1;

                      return _buildMenuItem(item, isLast);
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(MenuItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
          bottom: isLast ? Radius.circular(16.r) : Radius.zero,
        ),
        onTap: item.onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border:
                !isLast
                    ? Border(
                      bottom: BorderSide(
                        color: const Color(0xFFF1F5F9),
                        width: 1,
                      ),
                    )
                    : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child:
                      item.useSystemIcon
                          ? Icon(
                            Icons.settings_rounded,
                            color: AppColors.AppPrimaryColor,
                            size: 20.sp,
                          )
                          : SvgPicture.asset(
                            item.icon,
                            width: 20.w,
                            height: 20.h,
                            color: AppColors.AppPrimaryColor,
                          ),
                ),
              ),

              SizedBox(width: 16.w),

              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF9CA3AF),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.AppPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Image.asset(AppImages.Logo, width: 16.w, height: 14.h),
            ),
          ),

          SizedBox(width: 12.w),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VIP App',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: _showLogOut,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFEF4444),
                    size: 16.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuSection {
  final String title;
  final List<MenuItem> items;

  MenuSection({required this.title, required this.items});
}

class MenuItem {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool useSystemIcon;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.useSystemIcon = false,
  });
}
