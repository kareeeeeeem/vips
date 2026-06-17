import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

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

  // Load settings from storage
  void loadSettings() {
    // TODO: Load from SharedPreferences or secure storage
    print('Loading settings...');
  }

  // Save settings to storage
  void saveSettings() {
    // TODO: Save to SharedPreferences or secure storage
    print('Saving settings...');
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
      print('Error checking biometric availability: $e');
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
          Get.snackbar(
            'Success',
            'Biometric authentication enabled',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print('Error enabling biometric: $e');
        Get.snackbar(
          'Error',
          'Could not enable biometric authentication',
          backgroundColor: Colors.red.withOpacity(0.1),
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
    Get.snackbar(
      'Language Changed',
      'Language changed to $languageName',
      backgroundColor: Colors.blue.withOpacity(0.1),
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

  // Navigation methods
  void navigateToChangePassword() {
    Get.toNamed('/change-password');
  }

  void navigateToPrivacyPolicy() {
    Get.toNamed('/privacy-policy');
  }

  void navigateToTermsOfService() {
    Get.toNamed('/terms-of-service');
  }

  void navigateToAbout() {
    Get.toNamed('/about');
  }

  void navigateToHelp() {
    Get.toNamed('/help');
  }

  void navigateToContactSupport() {
    Get.toNamed('/contact-support');
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
            onPressed: () {
              Get.back(); // Close dialog
              // TODO: Clear user data and navigate to login
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
            onPressed: () {
              Get.back(); // Close dialog
              // TODO: Delete account API call
              Get.offAllNamed('/login');
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
            onPressed: () {
              Get.back();
              // TODO: Clear cache
              Get.snackbar(
                'Success',
                'Cache cleared successfully',
                backgroundColor: Colors.green.withOpacity(0.1),
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
