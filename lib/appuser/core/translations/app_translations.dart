// lib/app/translations/app_translations.dart
import 'dart:ui';

import 'package:get/get.dart';

import 'ar_SA.dart';
import 'en_US.dart';
import 'fr_FR.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fr_FR': frFR,
        'ar_SA': arSA,
      };
}

// Fonction pour initialiser les langues
void initializeLanguages() {
  // Obtenir la langue du système
  final String deviceLocale = Get.deviceLocale?.languageCode ?? 'en';

  // Vérifier si la langue du système est l'une des langues supportées
  String initialLocale;

  if (deviceLocale == 'fr') {
    initialLocale = 'fr_FR';
  } else if (deviceLocale == 'ar') {
    initialLocale = 'ar_SA';
  } else {
    // Par défaut en anglais
    initialLocale = 'en_US';
  }

  // Initialiser GetX avec la langue sélectionnée
  Get.updateLocale(Locale(initialLocale));
}
