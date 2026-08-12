import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../design_system/atoms/app_colors.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  final expireDateController = TextEditingController();
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
        final user = response.data['user'];
        nameController.text = user['fullName'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phone'] ?? '';
        profileImageUrl.value = user['profileImage'];
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
        final url = body['data']['url'] as String;
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
      safeSnackbar(
        'Upload Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.AppPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      expireDateController.text =
          "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
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
        if (Get.isDialogOpen == true) Get.back();
        await Future.delayed(const Duration(milliseconds: 100));
        safeSnackbar(
          'Error',
          'Failed to update profile: $e',
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
    idController.dispose();
    expireDateController.dispose();
    childrenController.dispose();
    postalCodeController.dispose();
    professionalController.dispose();
    super.onClose();
  }
}
