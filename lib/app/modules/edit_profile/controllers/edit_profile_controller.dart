import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  void saveProfile() {
    if (formKey.currentState!.validate()) {
      // TODO: Implémenter la logique de sauvegarde

      Get.back();
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
