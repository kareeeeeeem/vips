import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class BusinessRegistrationController extends GetxController {
  final _api = ApiService();

  // Text Controllers for form fields
  final fullNameLatinCtrl  = TextEditingController();
  final fullNameArabicCtrl = TextEditingController();
  final emailCtrl          = TextEditingController();
  final phoneCtrl          = TextEditingController();
  final storeNameLatinCtrl  = TextEditingController();
  final storeNameArabicCtrl = TextEditingController();
  final addressCtrl        = TextEditingController();
  final descriptionCtrl    = TextEditingController();
  final tinCtrl            = TextEditingController();

  // Dropdown selections
  final jobTitle    = 'Choose'.obs;
  final businessType = 'Choose'.obs;
  final category    = 'Choose'.obs;
  final countryCode = '+02'.obs;

  // Loading state
  final isLoading = false.obs;

  // Section expand/collapse state
  final isAdditionalInfoExpanded = true.obs;
  final isTimeInfoExpanded        = true.obs;
  final isLocationExpanded        = true.obs;
  final isSocialMediaExpanded     = true.obs;
  final isIdentityExpanded        = true.obs;

  // Business hours schedule
  final schedule = <String, Map<String, dynamic>>{
    'Sunday':    {'enabled': true,  'open': '09:00', 'close': '23:00'},
    'Monday':    {'enabled': true,  'open': '09:00', 'close': '23:00'},
    'Tuesday':   {'enabled': true,  'open': '09:00', 'close': '23:00'},
    'Wednesday': {'enabled': true,  'open': '09:00', 'close': '23:00'},
    'Thursday':  {'enabled': true,  'open': '09:00', 'close': '23:00'},
    'Friday':    {'enabled': false, 'open': '14:00', 'close': '23:00'},
    'Saturday':  {'enabled': true,  'open': '09:00', 'close': '23:00'},
  }.obs;

  // Loyalty type
  final isPrivetLoyalty = false.obs;

  // Document URLs (filled after upload)
  final documentUrls = <String>[].obs;

  @override
  void onClose() {
    fullNameLatinCtrl.dispose();
    fullNameArabicCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    storeNameLatinCtrl.dispose();
    storeNameArabicCtrl.dispose();
    addressCtrl.dispose();
    descriptionCtrl.dispose();
    tinCtrl.dispose();
    super.onClose();
  }

  void toggleSection(String section) {
    switch (section) {
      case 'Additional Info':  isAdditionalInfoExpanded.value = !isAdditionalInfoExpanded.value; break;
      case 'Time Info':        isTimeInfoExpanded.value        = !isTimeInfoExpanded.value; break;
      case 'Location':         isLocationExpanded.value        = !isLocationExpanded.value; break;
      case 'Social Media':     isSocialMediaExpanded.value     = !isSocialMediaExpanded.value; break;
      case 'Upload Identity':  isIdentityExpanded.value        = !isIdentityExpanded.value; break;
    }
  }

  void toggleDay(String day, bool enabled) {
    final current = Map<String, dynamic>.from(schedule[day]!);
    current['enabled'] = enabled;
    schedule[day] = current;
    schedule.refresh();
  }

  void addDocument(String url) {
    if (url.isNotEmpty) documentUrls.add(url);
  }

  Future<void> saveProfile() async {
    if (jobTitle.value == 'Choose') {
      safeSnackbar('Incomplete', 'Please choose a job title', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (category.value == 'Choose') {
      safeSnackbar('Incomplete', 'Please choose a category', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final storeName = storeNameLatinCtrl.text.trim();
    final fullName  = fullNameLatinCtrl.text.trim();
    final phone     = phoneCtrl.text.trim();

    if (storeName.isEmpty || fullName.isEmpty) {
      safeSnackbar('Incomplete', 'Please fill in your name and store name', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      // 1 — Update merchant profile with store info
      await _api.put('/merchant/profile', {
        'storeName':     storeName,
        'storeCategory': category.value,
        if (phone.isNotEmpty) 'phone': phone,
        if (emailCtrl.text.isNotEmpty) 'email': emailCtrl.text.trim(),
        if (addressCtrl.text.isNotEmpty) 'address': addressCtrl.text.trim(),
        if (descriptionCtrl.text.isNotEmpty) 'description': descriptionCtrl.text.trim(),
      });

      // 2 — Submit partnership / business registration
      final response = await _api.post('/merchant/register', {
        'ownerName':      fullName,
        'ownerNameAr':    fullNameArabicCtrl.text.trim(),
        'storeName':      storeName,
        'storeNameAr':    storeNameArabicCtrl.text.trim(),
        'businessType':   businessType.value == 'Choose' ? 'retail' : businessType.value,
        'category':       category.value,
        'jobTitle':       jobTitle.value,
        'phone':          phone,
        'email':          emailCtrl.text.trim(),
        'address':        addressCtrl.text.trim(),
        'description':    descriptionCtrl.text.trim(),
        'schedule':       schedule,
        'loyaltyType':    isPrivetLoyalty.value ? 'private' : 'everywhere',
        'documents':      documentUrls,
        'tin':            tinCtrl.text.trim(),
      });

      if (response.success) {
        Get.toNamed(MerchantRoutes.QR_RECEIVE);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to save profile', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
