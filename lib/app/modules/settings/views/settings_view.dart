import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // General Section
            _buildSectionHeader('General'),
            _buildSettingsCard([
              _buildLanguageTile(),
              _buildDivider(),
              _buildThemeTile(),
            ]),

            SizedBox(height: 24.h),

            // Security Section
            _buildSectionHeader('Security'),
            _buildSettingsCard([
              _buildBiometricTile(),
              _buildDivider(),
              _buildTwoFactorTile(),
              _buildDivider(),
              _buildChangePasswordTile(),
            ]),

            SizedBox(height: 24.h),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsCard([
              _buildPushNotificationsTile(),
              _buildDivider(),
              _buildEmailNotificationsTile(),
              _buildDivider(),
              _buildSmsNotificationsTile(),
              _buildDivider(),
              _buildOrderUpdatesTile(),
              _buildDivider(),
              _buildPromotionsTile(),
            ]),

            SizedBox(height: 24.h),

            // Privacy Section
            _buildSectionHeader('Privacy'),
            _buildSettingsCard([
              _buildLocationTile(),
              _buildDivider(),
              _buildDataSharingTile(),
            ]),

            SizedBox(height: 24.h),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingsCard([
              _buildHelpTile(),
              _buildDivider(),
              _buildPrivacyPolicyTile(),
              _buildDivider(),
              _buildTermsTile(),
              _buildDivider(),
              _buildAboutTile(),
            ]),

            SizedBox(height: 24.h),

            // Other Section
            _buildSectionHeader('Other'),
            _buildSettingsCard([_buildClearCacheTile()]),

            SizedBox(height: 24.h),

            // Danger Zone
            _buildSectionHeader('Danger Zone'),
            _buildSettingsCard([
              _buildLogoutTile(),
              _buildDivider(),
              _buildDeleteAccountTile(),
            ]),

            SizedBox(height: 40.h),

            // App Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  // Language Tile
  Widget _buildLanguageTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.language, color: Colors.blue, size: 24.sp),
        ),
        title: Text(
          'Language',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          controller.selectedLanguage.value,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey,
        ),
        onTap: _showLanguageSelector,
      ),
    );
  }

  // Theme Tile
  Widget _buildThemeTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            controller.isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
            color: Colors.purple,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isDarkMode.value,
          onChanged: controller.toggleTheme,
          activeColor: Colors.purple,
        ),
      ),
    );
  }

  // Biometric Tile
  Widget _buildBiometricTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.fingerprint, color: Colors.green, size: 24.sp),
        ),
        title: Text(
          'Biometric Authentication',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Use fingerprint or face ID',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        trailing: Switch(
          value: controller.isBiometricEnabled.value,
          onChanged: controller.toggleBiometric,
          activeColor: Colors.green,
        ),
      ),
    );
  }

  // Two Factor Tile
  Widget _buildTwoFactorTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.security, color: Colors.orange, size: 24.sp),
        ),
        title: Text(
          'Two-Factor Authentication',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Extra security for your account',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        trailing: Switch(
          value: controller.isTwoFactorEnabled.value,
          onChanged: controller.toggleTwoFactor,
          activeColor: Colors.orange,
        ),
      ),
    );
  }

  // Change Password Tile
  Widget _buildChangePasswordTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.lock_outline, color: Colors.red, size: 24.sp),
      ),
      title: Text(
        'Change Password',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.navigateToChangePassword,
    );
  }

  // Push Notifications Tile
  Widget _buildPushNotificationsTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.notifications_active,
            color: Colors.blue,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Push Notifications',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isPushNotificationsEnabled.value,
          onChanged: controller.togglePushNotifications,
          activeColor: Colors.blue,
        ),
      ),
    );
  }

  // Email Notifications Tile
  Widget _buildEmailNotificationsTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.email_outlined, color: Colors.teal, size: 24.sp),
        ),
        title: Text(
          'Email Notifications',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isEmailNotificationsEnabled.value,
          onChanged: controller.toggleEmailNotifications,
          activeColor: Colors.teal,
        ),
      ),
    );
  }

  // SMS Notifications Tile
  Widget _buildSmsNotificationsTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.sms_outlined, color: Colors.purple, size: 24.sp),
        ),
        title: Text(
          'SMS Notifications',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isSmsNotificationsEnabled.value,
          onChanged: controller.toggleSmsNotifications,
          activeColor: Colors.purple,
        ),
      ),
    );
  }

  // Order Updates Tile
  Widget _buildOrderUpdatesTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: Colors.green,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Order Updates',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isOrderUpdatesEnabled.value,
          onChanged: controller.toggleOrderUpdates,
          activeColor: Colors.green,
        ),
      ),
    );
  }

  // Promotions Tile
  Widget _buildPromotionsTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.local_offer_outlined,
            color: Colors.orange,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Promotions & Offers',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Switch(
          value: controller.isPromotionsEnabled.value,
          onChanged: controller.togglePromotions,
          activeColor: Colors.orange,
        ),
      ),
    );
  }

  // Location Tile
  Widget _buildLocationTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: Colors.red,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Location Services',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Allow app to access your location',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        trailing: Switch(
          value: controller.isLocationEnabled.value,
          onChanged: controller.toggleLocation,
          activeColor: Colors.red,
        ),
      ),
    );
  }

  // Data Sharing Tile
  Widget _buildDataSharingTile() {
    return Obx(
      () => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.share_outlined, color: Colors.indigo, size: 24.sp),
        ),
        title: Text(
          'Data Sharing',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Share data for analytics',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
        trailing: Switch(
          value: controller.isDataSharingEnabled.value,
          onChanged: controller.toggleDataSharing,
          activeColor: Colors.indigo,
        ),
      ),
    );
  }

  // Help Tile
  Widget _buildHelpTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.help_outline, color: Colors.blue, size: 24.sp),
      ),
      title: Text(
        'Help & Support',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.navigateToHelp,
    );
  }

  // Privacy Policy Tile
  Widget _buildPrivacyPolicyTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.privacy_tip_outlined,
          color: Colors.green,
          size: 24.sp,
        ),
      ),
      title: Text(
        'Privacy Policy',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.navigateToPrivacyPolicy,
    );
  }

  // Terms Tile
  Widget _buildTermsTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.description_outlined,
          color: Colors.orange,
          size: 24.sp,
        ),
      ),
      title: Text(
        'Terms of Service',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.navigateToTermsOfService,
    );
  }

  // About Tile
  Widget _buildAboutTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.info_outline, color: Colors.purple, size: 24.sp),
      ),
      title: Text(
        'About',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.navigateToAbout,
    );
  }

  // Clear Cache Tile
  Widget _buildClearCacheTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.cleaning_services_outlined,
          color: Colors.grey.shade700,
          size: 24.sp,
        ),
      ),
      title: Text(
        'Clear Cache',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        'Free up storage space',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.clearCache,
    );
  }

  // Logout Tile
  Widget _buildLogoutTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.logout, color: Colors.orange, size: 24.sp),
      ),
      title: Text(
        'Logout',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.logout,
    );
  }

  // Delete Account Tile
  Widget _buildDeleteAccountTile() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.delete_forever, color: Colors.red, size: 24.sp),
      ),
      title: Text(
        'Delete Account',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
      subtitle: Text(
        'Permanently delete your account',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: controller.deleteAccount,
    );
  }

  // Language Selector Bottom Sheet
  void _showLanguageSelector() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Select Language',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),
            ...controller.languages.map((lang) {
              return Obx(() {
                final isSelected =
                    controller.selectedLanguage.value == lang['name'];
                return ListTile(
                  leading: Text(
                    lang['flag']!,
                    style: TextStyle(fontSize: 32.sp),
                  ),
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 24.sp,
                          )
                          : null,
                  onTap:
                      () => controller.changeLanguage(
                        lang['code']!,
                        lang['name']!,
                      ),
                );
              });
            }).toList(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}
