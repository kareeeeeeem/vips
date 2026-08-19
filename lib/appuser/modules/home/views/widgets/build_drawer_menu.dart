import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/routes/app_pages.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../design_system/atoms/app_colors.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {

  List<MenuSection> get menuSections => [
    MenuSection(
      title: 'Account',
      items: [
        MenuItem(
          icon: AppIcons.editProfile,
          title: 'Edit Profile',
          onTap: () => Get.toNamed(Routes.EDIT_PROFILE),
        ),
        MenuItem(
          icon: AppIcons.notificationProfile,
          title: 'Notifications',
          onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
        ),
        MenuItem(
          icon: AppIcons.paymentMethods,
          title: 'Payment Methods',
          onTap: () => Get.toNamed(Routes.CREDIT),
        ),
        MenuItem(
          icon: AppIcons.paymentMethods,
          title: 'Wallet',
          onTap: () => Get.toNamed(Routes.TRANSACTIONS_EXTRACT),
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
          onTap: () => Get.toNamed(Routes.V_I_PS_CLUB),
        ),
      ],
    ),
    MenuSection(
      title: 'Support',
      items: [
        MenuItem(
          icon: AppIcons.Settings,
          title: 'Settings',
          onTap: () => Get.toNamed(Routes.SETTINGS),
          useSystemIcon: true,
        ),
        MenuItem(
          icon: AppIcons.aboutVIPs,
          title: 'About VIPs',
          onTap: () => _showAbout(),
        ),
        MenuItem(
          icon: AppIcons.helpSupport,
          title: 'Help & Support',
          onTap: () => Get.toNamed(Routes.CONTACT),
        ),
      ],
    ),
    MenuSection(
      title: 'Legal',
      items: [
        MenuItem(
          icon: AppIcons.privacyPolicy,
          title: 'Privacy Policy',
          onTap: () => _showLegalText('Privacy Policy', _privacyPolicyText),
        ),
        MenuItem(
          icon: AppIcons.privacyPolicy,
          title: 'Terms of Use',
          onTap: () => _showLegalText('Terms of Use', _termsOfUseText),
        ),
      ],
    ),
  ];

  // NOTE: placeholder legal copy — generic text pending review by legal
  // counsel before real launch. Not final Privacy Policy / Terms of Use.
  static const String _privacyPolicyText =
      'Last updated: 2026\n\n'
      'VIPs ("we", "our", "us") operates a loyalty rewards and payments app for users in Tunisia and Egypt. This Privacy Policy explains what information we collect, how we use it, and your choices.\n\n'
      '1. Information We Collect\n'
      'Account information such as your name, phone number, email, and profile details (city, civil status, postal code, profession, gender, number of children) that you choose to provide. Transaction and wallet activity, including purchases, top-ups, coupons redeemed, and reward points earned. Device and usage information, such as app version, device type, and general usage analytics. Location information, only when a feature (such as finding nearby merchants) requires it and you have granted permission.\n\n'
      '2. How We Use Your Information\n'
      'To operate your account, process payments and top-ups, and award loyalty points. To personalize offers, coupons, and packages relevant to you. To communicate with you about your account, transactions, and customer support requests. To maintain the security and integrity of the app and detect fraudulent activity.\n\n'
      '3. Sharing of Information\n'
      'We do not sell your personal information. We may share limited information with payment processors, merchants you transact with, and service providers who help us operate the app, solely to provide the service.\n\n'
      '4. Data Retention & Security\n'
      'We retain your information for as long as your account is active or as needed to provide services and comply with legal obligations. We use reasonable technical and organizational measures to protect your data, though no system is completely secure.\n\n'
      '5. Your Choices\n'
      'You may review and update your profile information at any time from Edit Profile. You may request account deletion or data export by contacting us.\n\n'
      '6. Contact Us\n'
      'If you have questions about this Privacy Policy or how your data is handled, please contact us through Help & Support in the app.';

  static const String _termsOfUseText =
      'Last updated: 2026\n\n'
      'These Terms of Use govern your access to and use of the VIPs app, a loyalty rewards and payments platform available in Tunisia and Egypt. By creating an account or using the app, you agree to these terms.\n\n'
      '1. Eligibility & Account Responsibility\n'
      'You must provide accurate information when creating your account and keep your login credentials, PIN, and payment details confidential. You are responsible for all activity that occurs under your account. Notify us immediately if you suspect unauthorized use.\n\n'
      '2. Acceptable Use\n'
      'You agree not to misuse the app, including attempting to defraud merchants or other users, tampering with coupons, wallet balances, or reward points, reverse-engineering or interfering with the app\'s normal operation, or using the app for any unlawful purpose.\n\n'
      '3. Wallet, Points & Coupons\n'
      'Reward points, wallet balances, and coupons have no cash value unless explicitly stated and may be adjusted, expired, or revoked in cases of suspected fraud or abuse. Bill payments, top-ups, and transfers are processed on a best-effort basis and are subject to verification.\n\n'
      '4. Merchant Transactions\n'
      'VIPs facilitates transactions between users and participating merchants but is not responsible for the quality of goods or services provided by merchants.\n\n'
      '5. Limitation of Liability\n'
      'To the maximum extent permitted by law, VIPs is not liable for indirect, incidental, or consequential damages arising from your use of the app, including service interruptions, transaction delays, or third-party actions. Our total liability for any claim is limited to the amount of the disputed transaction, where applicable.\n\n'
      '6. Changes to the Service\n'
      'We may update, suspend, or discontinue features of the app at any time. We may also update these Terms of Use, and continued use of the app after changes constitutes acceptance.\n\n'
      '7. Contact Us\n'
      'Questions about these Terms of Use can be directed to us through Help & Support in the app.';

  void _showLegalText(String title, String body) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      body,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.AppPrimaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept & Close',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showAbout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.Logo,
                      width: 40.w,
                      height: 40.h,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'About VIPs',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'VIPs is your ultimate platform for managing your lifestyle, payments, and premium benefits seamlessly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );
  }

  void _showPartnership() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handshake_rounded,
                    color: Colors.orange,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Join VIPs Partnership',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Grow your business by joining our exclusive network of merchants and partners today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.toNamed(Routes.CONTACT);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.AppPrimaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Apply Now',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
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
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFEF4444),
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Are you sure you want to log out of your account? You will need to log back in to access your data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ApiService().clearToken();
                          Get.offAllNamed(Routes.LOGIN);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Yes, Log Out',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
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
            color: Colors.black.withValues(alpha: 0.03),
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
                  color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
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
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
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
                  color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
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
                            colorFilter: ColorFilter.mode(AppColors.AppPrimaryColor, BlendMode.srcIn),
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
              color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.03),
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
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
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
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
