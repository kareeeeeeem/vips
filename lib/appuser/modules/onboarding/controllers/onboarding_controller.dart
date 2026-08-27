import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_assets.dart';
import '../../../routes/app_pages.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

// Enum for page types
enum OnboardingPageType { welcome, standard, conditions }

// Model class for onboarding page data
class OnboardingPageData {
  final OnboardingPageType type;
  final String? image;
  final String title;
  final String subtitle;
  final String description;
  bool? isConditionsChecked;

  OnboardingPageData({
    required this.type,
    this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    this.isConditionsChecked = false,
  });
}

class OnboardingController extends GetxController {
  // Reactive current index
  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  // Selected language
  final RxString selectedLanguage = 'en'.obs;

  // Page Controller
  late PageController pageController;

  // Onboarding pages list
  final List<OnboardingPageData> pages = [
    // Page 1: Welcome
    OnboardingPageData(
      type: OnboardingPageType.welcome,
      title: 'Your\nFuture Starts Here',
      subtitle: 'Discovery',
      description:
          'We are delighted to welcome you. Let\'s start an exceptional experience together.',
    ),

    // Page 2-4: Standard Onboarding
    OnboardingPageData(
      type: OnboardingPageType.standard,
      image: AppImages.Onboarding1,
      title: 'Install App',
      subtitle: 'Quick & Easy Setup',
      description:
          'Get started in seconds with our streamlined installation process.',
    ),
    OnboardingPageData(
      type: OnboardingPageType.standard,
      image: AppImages.Onboarding2,
      title: 'Explore',
      subtitle: 'Discover Features',
      description: 'Navigate through powerful tools designed for your success.',
    ),
    OnboardingPageData(
      type: OnboardingPageType.standard,
      image: AppImages.Onboarding3,
      title: 'and Win',
      subtitle: 'Achieve Goals',
      description:
          'Unlock your potential and reach new heights with our platform.',
    ),

    // Final Page: Conditions
    OnboardingPageData(
      type: OnboardingPageType.conditions,
      title: 'Terms\nof Service',
      subtitle: 'Acceptance',
      description:
          'By clicking "I Accept", you confirm that you have read and agreed to our general terms of use.',
      isConditionsChecked: false,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadSavedLanguage();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language') ?? 'en';
    selectedLanguage.value = savedLang;

    Locale locale;
    switch (savedLang) {
      case 'fr':
        locale = const Locale('fr', 'FR');
        break;
      case 'ar':
        locale = const Locale('ar', 'TN');
        break;
      default:
        locale = const Locale('en', 'US');
    }
    Get.updateLocale(locale);
  }

  Future<void> changeLanguage(String languageCode) async {
    selectedLanguage.value = languageCode;

    // Update app locale
    Locale locale;
    switch (languageCode) {
      case 'fr':
        locale = const Locale('fr', 'FR');
        break;
      case 'ar':
        locale = const Locale('ar', 'TN');
        break;
      default:
        locale = const Locale('en', 'US');
    }

    Get.updateLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  // Method to go to the next page
  void nextPage() {
    if (currentIndex < pages.length - 1) {
      // Vérification spécifique pour la page de conditions
      if (pages[currentIndex].type == OnboardingPageType.conditions) {
        // Vérifier si les conditions ont été acceptées
        if (!(pages[currentIndex].isConditionsChecked ?? false)) {
          // Conditions non acceptées, ne pas naviguer
          safeSnackbar(
            'Required',
            'Please accept the terms and conditions to continue',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red,
          );
          return;
        }

        // Naviguer vers l'écran suivant
        completeOnboarding();
        return;
      }

      // Navigation normale pour les autres pages
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _currentIndex.value++;
    } else {
      // Dernière page
      completeOnboarding();
    }
  }

  // Method to go to the previous page
  void previousPage() {
    if (currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _currentIndex.value--;
    }
  }

  // Method to skip onboarding
  void skipOnboarding() {
    // Jump to conditions page
    pageController.jumpToPage(pages.length - 1);
    _currentIndex.value = pages.length - 1;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Get.offAllNamed(Routes.LOGIN);
  }

  // Method to update current index when page changes
  void onPageChanged(int index) {
    _currentIndex.value = index;
  }

  // Méthode pour accepter ou refuser les conditions
  void toggleConditionsAcceptance(bool? value) {
    if (currentIndex == pages.length - 1 &&
        pages[currentIndex].type == OnboardingPageType.conditions) {
      pages[currentIndex].isConditionsChecked = value ?? false;
      update(); // Mettre à jour l'état pour le bouton
    }
  }

  // areConditionsAccepted() duplicated the inline check nextPage() already does.

}

// Binding pour l'injection de dépendance
class OnboardingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
