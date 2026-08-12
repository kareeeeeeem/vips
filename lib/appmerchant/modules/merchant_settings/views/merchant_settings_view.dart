import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/modules/merchant_home/controllers/merchant_home_controller.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MerchantSettingsView extends StatelessWidget {
  const MerchantSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: const Color(0xFF1F2937), fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          _buildProfileHeader(),
          SizedBox(height: 32.h),
          
          _buildSectionHeader('Store Management'),
          _buildListTile(Icons.store_outlined, 'Store Profile', 'View and edit details', () => Get.toNamed(MerchantRoutes.STORE_PROFILE)),
          _buildListTile(Icons.language_outlined, 'Language', 'English', () => _showLanguageDialog()),
          
          SizedBox(height: 24.h),
          _buildSectionHeader('Support & Legal'),
          _buildListTile(Icons.help_outline, 'Help & Support', 'Contact admin', () => _showHelpSheet()),
          _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', '', () => Get.toNamed(MerchantRoutes.PRIVACY)),
          _buildListTile(Icons.description_outlined, 'Terms of Service', '', () => Get.toNamed(MerchantRoutes.TERMS)),
          
          SizedBox(height: 48.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ElevatedButton.icon(
              onPressed: () async {
                await ApiService().clearToken();
                Get.offAllNamed(MerchantRoutes.LOGIN);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final homeCtrl = Get.find<MerchantHomeController>();
    return Obx(() => Container(
      padding: EdgeInsets.all(24.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: homeCtrl.storeImageUrl.value.isNotEmpty
                ? ClipOval(child: Image.network(homeCtrl.storeImageUrl.value, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.store_rounded, size: 36, color: Color(0xFF10B981))))
                : const Icon(Icons.store_rounded, size: 36, color: Color(0xFF10B981)),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeCtrl.storeName.value.isNotEmpty ? homeCtrl.storeName.value : 'My Store',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                ),
                SizedBox(height: 4.h),
                Text(
                  homeCtrl.merchantId.value.isNotEmpty ? 'ID: ${homeCtrl.merchantId.value.substring(0, 8)}...' : 'Merchant',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Text('Verified', style: TextStyle(color: const Color(0xFF10B981), fontSize: 11.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2_rounded, color: Color(0xFF1F2937), size: 28),
        ],
      ),
    ));
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF9CA3AF), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: const Color(0xFF4B5563)),
        ),
        title: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))) : null,
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        onTap: onTap,
      ),
    );
  }

  static const _langLocales = {
    'English': Locale('en', 'US'),
    'العربية': Locale('ar', 'SA'),
    'Français': Locale('fr', 'FR'),
  };

  Future<void> _showLanguageDialog() async {
    final languages = ['English', 'العربية', 'Français'];
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language') ?? 'English';
    final selected = saved.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Select Language', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => RadioListTile<String>(
            value: lang,
            groupValue: selected.value,
            onChanged: (v) => selected.value = v!,
            title: Text(lang, style: TextStyle(fontSize: 15.sp)),
            activeColor: const Color(0xFF10B981),
          )).toList(),
        )),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () async {
              Get.back();
              await prefs.setString('app_language', selected.value);
              final locale = _langLocales[selected.value];
              if (locale != null) Get.updateLocale(locale);
              safeSnackbar('Language Updated', '${selected.value} selected', snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            const Icon(Icons.support_agent_rounded, size: 48, color: Color(0xFF10B981)),
            SizedBox(height: 12.h),
            Text('Help & Support', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Contact our support team for assistance.', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)), textAlign: TextAlign.center),
            SizedBox(height: 24.h),
            _supportOption(Icons.email_outlined, 'Email Support', 'support@vips.tn'),
            _supportOption(Icons.phone_outlined, 'Phone Support', '+216 71 000 000'),
            _supportOption(Icons.chat_bubble_outline_rounded, 'Live Chat', 'Available 9am - 6pm'),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _supportOption(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, color: const Color(0xFF10B981)),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
    );
  }
}
