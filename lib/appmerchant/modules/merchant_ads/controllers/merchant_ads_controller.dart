import 'package:get/get.dart';

class MerchantAdsController extends GetxController {
  final isArabicSelected = false.obs;
  final showReview = false.obs;
  final showRating = false.obs;
  final selectedCategory = 'Auto Promotion'.obs;

  void toggleLanguage(bool isArabic) {
    isArabicSelected.value = isArabic;
  }
}
