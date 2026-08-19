import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class SettingsController extends GetxController {
  // Language settings
  final RxString selectedLanguage = 'English'.obs;
  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇹🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  // Theme settings
  final RxBool isDarkMode = false.obs;

  // Security settings
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isFaceIdEnabled = false.obs;
  final RxBool isTwoFactorEnabled = false.obs;

  // Notification settings
  final RxBool isPushNotificationsEnabled = true.obs;
  final RxBool isEmailNotificationsEnabled = true.obs;
  final RxBool isSmsNotificationsEnabled = false.obs;
  final RxBool isOrderUpdatesEnabled = true.obs;
  final RxBool isPromotionsEnabled = true.obs;

  // Privacy settings
  final RxBool isLocationEnabled = true.obs;
  final RxBool isDataSharingEnabled = false.obs;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    checkBiometricAvailability();
    _loadTwoFactorState();
  }

  // Real server-side state — this used to be a purely local SharedPreferences
  // flag that never actually affected login (POST /auth/login didn't check
  // anything client-side could set), so switching it "on" gave a false
  // sense of protection.
  Future<void> _loadTwoFactorState() async {
    final response = await ApiService().get('/auth/me');
    if (response.success && response.data != null) {
      final user = response.data['user'] ?? response.data;
      if (user is Map) {
        isTwoFactorEnabled.value = user['twoFactorEnabled'] == true;
      }
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('settings_dark_mode') ?? false;
    isBiometricEnabled.value = prefs.getBool('settings_biometric_enabled') ?? false;
    isPushNotificationsEnabled.value = prefs.getBool('settings_push_notifications') ?? true;
    isEmailNotificationsEnabled.value = prefs.getBool('settings_email_notifications') ?? true;
    isSmsNotificationsEnabled.value = prefs.getBool('settings_sms_notifications') ?? false;
    isOrderUpdatesEnabled.value = prefs.getBool('settings_order_updates') ?? true;
    isPromotionsEnabled.value = prefs.getBool('settings_promotions') ?? true;
    isLocationEnabled.value = prefs.getBool('settings_location_enabled') ?? true;
    isDataSharingEnabled.value = prefs.getBool('settings_data_sharing') ?? false;
    final langCode = prefs.getString('settings_language') ?? 'en';
    final lang = languages.firstWhere(
      (l) => l['code'] == langCode,
      orElse: () => languages.first,
    );
    selectedLanguage.value = lang['name']!;
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_dark_mode', isDarkMode.value);
    await prefs.setBool('settings_biometric_enabled', isBiometricEnabled.value);
    await prefs.setBool('settings_push_notifications', isPushNotificationsEnabled.value);
    await prefs.setBool('settings_email_notifications', isEmailNotificationsEnabled.value);
    await prefs.setBool('settings_sms_notifications', isSmsNotificationsEnabled.value);
    await prefs.setBool('settings_order_updates', isOrderUpdatesEnabled.value);
    await prefs.setBool('settings_promotions', isPromotionsEnabled.value);
    await prefs.setBool('settings_location_enabled', isLocationEnabled.value);
    await prefs.setBool('settings_data_sharing', isDataSharingEnabled.value);
    final lang = languages.firstWhere(
      (l) => l['name'] == selectedLanguage.value,
      orElse: () => languages.first,
    );
    await prefs.setString('settings_language', lang['code']!);
  }

  // Check if biometric authentication is available
  Future<void> checkBiometricAvailability() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        isBiometricEnabled.value = false;
      }
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
    }
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool value) async {
    if (value) {
      // Demander l'authentification avant d'activer
      try {
        final bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometric authentication',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated) {
          isBiometricEnabled.value = true;
          saveSettings();
          safeSnackbar(
            'Success',
            'Biometric authentication enabled',
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        debugPrint('Error enabling biometric: $e');
        safeSnackbar(
          'Error',
          'Could not enable biometric authentication',
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      isBiometricEnabled.value = false;
      saveSettings();
    }
  }

  // Change language
  void changeLanguage(String languageCode, String languageName) {
    selectedLanguage.value = languageName;

    // Update app locale
    Locale locale;
    switch (languageCode) {
      case 'fr':
        locale = const Locale('fr', 'FR');
        break;
      case 'ar':
        locale = const Locale('ar', 'TN');
        break;
      case 'es':
        locale = const Locale('es', 'ES');
        break;
      default:
        locale = const Locale('en', 'US');
    }

    Get.updateLocale(locale);
    saveSettings();

    Get.back(); // Close language selector
    safeSnackbar(
      'Language Changed',
      'Language changed to $languageName',
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Toggle theme
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    saveSettings();
  }

  // Toggle notifications
  void togglePushNotifications(bool value) {
    isPushNotificationsEnabled.value = value;
    saveSettings();
  }

  void toggleEmailNotifications(bool value) {
    isEmailNotificationsEnabled.value = value;
    saveSettings();
  }

  void toggleSmsNotifications(bool value) {
    isSmsNotificationsEnabled.value = value;
    saveSettings();
  }

  void toggleOrderUpdates(bool value) {
    isOrderUpdatesEnabled.value = value;
    saveSettings();
  }

  void togglePromotions(bool value) {
    isPromotionsEnabled.value = value;
    saveSettings();
  }

  // Toggle privacy
  void toggleLocation(bool value) {
    isLocationEnabled.value = value;
    saveSettings();
  }

  void toggleDataSharing(bool value) {
    isDataSharingEnabled.value = value;
    saveSettings();
  }

  final RxBool isTogglingTwoFactor = false.obs;

  // Real: enabling/disabling this now actually changes whether
  // POST /auth/login requires an emailed code before issuing a token.
  // Requires the current password both ways, same as Change Password —
  // an attacker with a stolen unlocked session shouldn't be able to
  // silently turn protection off (or force it on to lock the real owner
  // out via an email they don't control).
  void toggleTwoFactor(bool value) {
    final passwordController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text(value ? 'Enable Two-Factor Authentication' : 'Disable Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value
                ? 'A code will be emailed to you each time you sign in with your password.'
                : 'You will no longer be asked for an emailed code when signing in.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm your password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(
            () => TextButton(
              onPressed: isTogglingTwoFactor.value
                  ? null
                  : () async {
                      isTogglingTwoFactor.value = true;
                      final response = await ApiService().put('/auth/2fa', {
                        'enabled': value,
                        'currentPassword': passwordController.text,
                      });
                      isTogglingTwoFactor.value = false;
                      Get.back();
                      if (response.success) {
                        isTwoFactorEnabled.value = value;
                        safeSnackbar(
                          'Success',
                          value ? 'Two-factor authentication enabled.' : 'Two-factor authentication disabled.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
                      }
                    },
              child: isTogglingTwoFactor.value
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToChangePassword() {
    Get.toNamed('/change-password');
  }

  // vips.com/privacy and /terms are a parked domain that redirects every
  // path (including these) to a generic "/lander" page — there's no real
  // policy text there. Show the same real (if placeholder-legal-copy)
  // in-app text the Home drawer menu already uses instead of sending users
  // to a dead external link.
  void navigateToPrivacyPolicy() {
    _showLegalText('Privacy Policy', _privacyPolicyText);
  }

  void navigateToTermsOfService() {
    _showLegalText('Terms of Use', _termsOfUseText);
  }

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
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void navigateToAbout() {
    Get.dialog(AlertDialog(
      title: const Text('About VIPs'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VIPs App — Premium Loyalty Platform'),
          SizedBox(height: 8),
          Text('Version: 1.0.0'),
          SizedBox(height: 4),
          Text('© 2026 VIPs. All rights reserved.'),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Close')),
      ],
    ));
  }

  void navigateToHelp() {
    _launchUrl('mailto:support@vips.com?subject=VIPs Help');
  }

  void navigateToContactSupport() {
    _launchUrl('mailto:support@vips.com?subject=VIPs Support Request');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      safeSnackbar('Error', 'Could not open link', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              
              // Show loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              await ApiService().clearToken();
              
              Get.back(); // Close loading
              Get.offAllNamed('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Delete account
  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              
              // Show loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                final response = await ApiService().delete('/user/account');
                
                Get.back(); // Close loading
                
                if (response.success) {
                  await ApiService().clearToken();
                  Get.offAllNamed('/login');
                  safeSnackbar('Success', 'Account deleted successfully');
                } else {
                  safeSnackbar('Error', response.message);
                }
              } catch (e) {
                if (Get.isDialogOpen ?? false) Get.back(); // Close loading
                safeSnackbar('Error', 'An error occurred');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Clear cache
  void clearCache() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              final prefs = await SharedPreferences.getInstance();
              final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
              for (final key in keys) {
                await prefs.remove(key);
              }
              safeSnackbar(
                'Success',
                'Cache cleared successfully',
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                colorText: Colors.green,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
