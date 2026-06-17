import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class BusinessRegistrationController extends GetxController {
  // General Info
  final fullNameLatinController = ''.obs;
  final fullNameArabicController = ''.obs;
  final jobTitle = 'Choose'.obs;
  final emailController = ''.obs;
  final phoneController = ''.obs;
  final countryCode = '+02'.obs;

  // Track Expanded State of Sections
  final isAdditionalInfoExpanded = true.obs;
  final isTimeInfoExpanded = true.obs;
  final isLocationExpanded = true.obs;
  final isSocialMediaExpanded = true.obs;
  final isIdentityExpanded = true.obs;

  // Additional Info
  final storeNameLatin = ''.obs;
  final storeNameArabic = ''.obs;
  final businessType = 'Choose'.obs;
  final category = 'Choose'.obs;
  
  // Time Info (Simplified logic for now)
  // Maps a day to its enabled state and time range
  final schedule = <String, Map<String, dynamic>>{
    'Sunday': {'enabled': true, 'time': '12:01 AM - 11:59 PM'},
    'Monday': {'enabled': false, 'time': '12:00 AM - 04:00 AM | 06:00 AM -'},
    'Tuesday': {'enabled': false, 'time': '12:00 AM - 05:00 AM | 06:00 AM -'},
    'Wednesday': {'enabled': false, 'time': '12:00 AM - 06:00 AM | 08:00 AM -'},
    'Thursday': {'enabled': false, 'time': '12:00 AM - 04:00 AM | 05:00 AM -'},
    'Friday': {'enabled': true, 'time': '12:00 AM - 11:59 PM'},
    'Saturday': {'enabled': true, 'time': '12:01 AM - 11:59 PM'},
  }.obs;

  // Loyalty Type
  final isPrivetLoyalty = false.obs; // false = Everywhere, true = Privet

  void toggleSection(String section) {
    if (section == 'Additional Info') {
      isAdditionalInfoExpanded.value = !isAdditionalInfoExpanded.value;
    } else if (section == 'Time Info') {
      isTimeInfoExpanded.value = !isTimeInfoExpanded.value;
    } else if (section == 'Location') {
      isLocationExpanded.value = !isLocationExpanded.value;
    } else if (section == 'Social Media') {
      isSocialMediaExpanded.value = !isSocialMediaExpanded.value;
    } else if (section == 'Upload Identity') {
      isIdentityExpanded.value = !isIdentityExpanded.value;
    }
  }

  void saveProfile() {
    if (jobTitle.value == 'Choose') {
      Get.snackbar('Incomplete profile', 'Please choose a job title', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (category.value == 'Choose') {
      Get.snackbar('Incomplete profile', 'Please choose a category', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.toNamed(MerchantRoutes.QR_RECEIVE);
  }
}
