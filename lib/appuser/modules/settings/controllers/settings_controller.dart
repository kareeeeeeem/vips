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
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('settings_dark_mode') ?? false;
    isBiometricEnabled.value = prefs.getBool('settings_biometric_enabled') ?? false;
    isTwoFactorEnabled.value = prefs.getBool('settings_two_factor_enabled') ?? false;
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
    await prefs.setBool('settings_two_factor_enabled', isTwoFactorEnabled.value);
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

  void toggleTwoFactor(bool value) {
    isTwoFactorEnabled.value = value;
    saveSettings();
  }

  void navigateToChangePassword() {
    Get.toNamed('/forgot-password');
  }

  void navigateToPrivacyPolicy() {
    _launchUrl('https://vips.com/privacy');
  }

  void navigateToTermsOfService() {
    _launchUrl('https://vips.com/terms');
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
