import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';

import 'package:vip/core/utils/safe_snackbar.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final childrenController = TextEditingController();
  final postalCodeController = TextEditingController();
  final professionalController = TextEditingController();

  final RxBool isMale = true.obs;
  final Rxn<String> selectedCity = Rxn<String>();
  final Rxn<String> selectedCivilStatus = Rxn<String>();
  final Rxn<String> profileImageUrl = Rxn<String>();
  final RxBool isUploadingImage = false.obs;

  final List<String> cities = ['Nabeul', 'Tunis', 'Gafsa', 'Sousse', 'Sfax'];
  final List<String> civilStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  @override
  void onInit() {
    super.onInit();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiService().get('/auth/me');
      if (response.success && response.data != null) {
        final user = response.data['user'] ?? response.data;
        nameController.text = user['fullName'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phone'] ?? '';
        final storedImage = user['profileImage']?.toString();
        profileImageUrl.value = storedImage?.replaceFirst('http://', 'https://');

        // These were previously left at their defaults on load — saving
        // the form without touching them would silently overwrite the
        // user's real saved values (e.g. gender always reset to male).
        final gender = user['gender']?.toString();
        if (gender != null) isMale.value = gender != 'female';
        final city = user['city']?.toString();
        if (city != null && cities.contains(city)) selectedCity.value = city;
        final civilStatus = user['civilStatus']?.toString();
        if (civilStatus != null && civilStatuses.contains(civilStatus)) {
          selectedCivilStatus.value = civilStatus;
        }
        final numberOfChildren = user['numberOfChildren'];
        if (numberOfChildren != null) {
          childrenController.text = numberOfChildren.toString();
        }
        postalCodeController.text = user['postalCode']?.toString() ?? '';
        professionalController.text = user['profession']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    isUploadingImage.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final dioClient = dio.Dio(
        dio.BaseOptions(
          baseUrl: ApiService.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          picked.path,
          filename: picked.name,
        ),
      });

      final res = await dioClient.post('/upload', data: formData);
      final body = res.data;

      if (body['success'] == true) {
        // The backend returns the upload URL as http:// even though the API
        // itself is served over https:// on the same host — iOS blocks
        // cleartext image loads by default (no ATS exception is configured),
        // so the picture would silently fail to display after every upload.
        final rawUrl = body['data']['url'] as String;
        final url = rawUrl.replaceFirst('http://', 'https://');
        profileImageUrl.value = url;
        await ApiService().put('/auth/update-profile', {'profileImage': url});
      } else {
        safeSnackbar(
          'Upload Failed',
          body['message'] ?? 'Could not upload image',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Upload image error: $e');
      safeSnackbar(
        'Upload Error',
        'Could not upload your image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  void saveProfile() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        final response = await ApiService().put('/auth/update-profile', {
          'fullName': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          if (profileImageUrl.value != null)
            'profileImage': profileImageUrl.value!,
          'gender': isMale.value ? 'male' : 'female',
          if (selectedCity.value != null) 'city': selectedCity.value!,
          if (selectedCivilStatus.value != null)
            'civilStatus': selectedCivilStatus.value!,
          'numberOfChildren': int.tryParse(childrenController.text.trim()) ?? 0,
          'postalCode': postalCodeController.text.trim(),
          'profession': professionalController.text.trim(),
        });
        Get.back();

        if (response.success) {
          Get.back();
          safeSnackbar(
            'Success',
            'Profile updated successfully!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          safeSnackbar(
            'Error',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        debugPrint('Update profile error: $e');
        if (Get.isDialogOpen == true) Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
        safeSnackbar(
          'Error',
          'Could not update your profile. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    childrenController.dispose();
    postalCodeController.dispose();
    professionalController.dispose();
    super.onClose();
  }
}
