import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/bill_inquiry_mob.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class MobilesController extends GetxController {
  final RxnInt selectedOperatorIndex = RxnInt();
  final RxInt selectedCreditOption = 0.obs;
  final RxInt creditQuantity = 1.obs;
  final RxBool isLoading = false.obs;
  final phoneController = TextEditingController();

  final List<Map<String, dynamic>> operators = [
    {
      'name': 'Orange',
      'logoUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Orange_logo.svg/200px-Orange_logo.svg.png',
      'color': Color(0xFFFF6600),
    },
    {
      'name': 'Ooredoo',
      'logoUrl':
          'https://e7.pngegg.com/pngimages/385/840/png-clipart-burma-ooredoo-kuwait-ooredoo-myanmar-telecommunication-business-text-people-thumbnail.png',
      'color': Color(0xFFE60000),
    },
    {
      'name': 'Tunisie Telecom',
      'logoUrl':
          'https://upload.wikimedia.org/wikipedia/fr/thumb/f/f9/LOGO_TT_.jpg/1200px-LOGO_TT_.jpg',
      'color': Color(0xFF0066CC),
    },
    {
      'name': 'Lycamobile',
      'logoUrl':
          'https://www.affinicia.com/forfait-mobile/wp-content/uploads/sites/3/2022/07/lyca-mobile-logo.png',
      'color': Color(0xFFFABE00),
    },
  ];

  final List<Map<String, dynamic>> creditOptions = [
    {'label': 'Crd 5 TND', 'value': 5, 'quantity': 1},
    {'label': 'Crd 2 TND', 'value': 2, 'quantity': 1},
    {'label': 'Crd 10 TND', 'value': 10, 'quantity': 1},
    {'label': 'Crd 20 TND', 'value': 20, 'quantity': 1},
  ];

  void updateQuantity(int optionIndex, int newQuantity) {
    if (newQuantity > 0) {
      creditOptions[optionIndex]['quantity'] = newQuantity;
      update();
    }
  }

  void selectOperator(int index) {
    selectedOperatorIndex.value = index;
  }

  void selectCreditOption(int index) {
    selectedCreditOption.value = index;
  }

  void incrementQuantity(int optionIndex) {
    creditOptions[optionIndex]['quantity']++;
    update();
  }

  void decrementQuantity(int optionIndex) {
    if (creditOptions[optionIndex]['quantity'] > 1) {
      creditOptions[optionIndex]['quantity']--;
      update();
    }
  }

  void proceed() {
    if (selectedOperatorIndex.value == null) {
      safeSnackbar('Error', 'Please select an operator', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.put(BillInquiryController());
    Get.to(() => BillInquiryView());
  }

  Future<void> recharge({required String phoneNumber}) async {
    if (selectedOperatorIndex.value == null) {
      safeSnackbar('Error', 'Please select an operator', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (phoneNumber.isEmpty) {
      safeSnackbar('Error', 'Please enter a phone number', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final operatorIndex = selectedOperatorIndex.value ?? 0;
    final operator = operators[operatorIndex]['name'] as String;
    final amount = (creditOptions[selectedCreditOption.value]['value'] as int).toDouble();

    isLoading.value = true;
    try {
      final response = await ApiService().post('/services/mobile-recharge', {
        'operator': operator,
        'amount': amount,
        'phoneNumber': phoneNumber,
      });

      if (response.success) {
        safeSnackbar(
          'Success',
          response.data['message'] ?? 'Recharge successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );
        Get.back();
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to process recharge', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
