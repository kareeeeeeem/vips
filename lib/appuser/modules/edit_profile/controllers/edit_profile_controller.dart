import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../design_system/atoms/app_colors.dart';

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
      }
    } catch (e) {
      print('Error fetching profile: $e');
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
    if (formKey.currentState!.validate()) {
      try {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        final response = await ApiService().put('/auth/update-profile', {
          'fullName': nameController.text.trim(),
          'phone': phoneController.text.trim(),
        });
        Get.back(); // close loading dialog

        if (response.success) {
          Get.back(); // close the edit profile screen
          Get.snackbar(
            'Success',
            'Profile updated successfully!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.snackbar(
            'Error',
            response.message ?? 'Unknown error',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        if (Get.isDialogOpen == true) Get.back(); // close loading dialog
        await Future.delayed(const Duration(milliseconds: 100)); // wait for dialog to close
        Get.snackbar(
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
