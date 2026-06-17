import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'field_validator.dart';

class DesignConstants {
  static const String defaultAppFont = 'packages/design_system/Transgourmet';
  static const String helveticaNeueFont =
      'packages/design_system/HelveticaNeue';

  static const String asteriskFormField = ' *';

  static const String dayFormatStringDatePicker = 'ccccc';

  static const int textFieldPriceProblemMaxQuantity = 10000;
  static const int textFieldMinQuantity = 0;
  static const int textFieldMaxQuantity = 99999;

  static int dematEmailCcListSize = 10;

  static const int onTapMillisecondTimer = 1000;
  static const int defaultCountToActionDebugMode = 5;
  static const int compagnonCountToAction = 3;
  static const int maxCommentLength = 2000;

  static int commentLineMaxLength = 60;

  static const int searchMillisecondTimer = 500;

  static const int minLengthPassword = 8;

  static const String yesValue = 'O';
  static const String noValue = 'N';

  static const String claimCommentPlaceholder = 'Litige déclaré sur appli';

  static const String smartCuisineFilterParam =
      'LIST_SEARCH_FEAT=ASSMT_9000,ASSMT_9005,ASSMT_9007';
  static const String smartCuisineTakeAwayFilterParam =
      'LIST_SEARCH_FEAT=ASSMT_9005';
  static const String smartCuisineReheatFilterParam =
      'LIST_SEARCH_FEAT=ASSMT_9007';

  static const String smartCuisineTitle = 'Smart Cuisine';
  static const String smartCuisineTakeAwayTitle = 'Smart Cuisine Take Away';
  static const String smartCuisineReheatTitle = 'Smart Cuisine Reheat';

  //labelEgalim
  static const String bioLabel = 'BIO';
  static const String redLabel = 'LRG';
  static const String aocLabel = 'AOC';
  static const String aopLabel = 'AOP';
  static const String igpLabel = 'IGP';
  static const String hveLabel = 'HVE';
  static const String stgLabel = 'STG';
  static const String verLabel = 'VER';
  static const String origineFrance = 'France';

  static const String technicalMailSubject =
      kIsWeb
          ? 'Signaler un problème sur le portail client'
          : 'Signaler un problème sur l’application Transgourmet';

  static List<TextInputFormatter> get inputFormattersSearchOrderReference =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(TgRegex.reference.value)),
      ];

  static List<TextInputFormatter> get inputFormattersHasDigits =>
      <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(TgRegex.hasDigits.value)),
      ];
}
