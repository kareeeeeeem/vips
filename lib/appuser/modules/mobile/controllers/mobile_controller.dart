import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/widgets/bill_inquiry_mob.dart';

class MobilesController extends GetxController {
  final RxnInt selectedOperatorIndex = RxnInt();
  final RxInt selectedCreditOption = 0.obs;
  final RxInt creditQuantity = 1.obs;

  // ✅ Opérateurs avec URLs des logos (Network Images)
  final List<Map<String, dynamic>> operators = [
    {
      'name': 'Orange',
      'logoUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Orange_logo.svg/200px-Orange_logo.svg.png',
      'color': Color(0xFFFF6600), // Orange
    },
    {
      'name': 'Ooredoo',
      'logoUrl':
          'https://e7.pngegg.com/pngimages/385/840/png-clipart-burma-ooredoo-kuwait-ooredoo-myanmar-telecommunication-business-text-people-thumbnail.png',
      'color': Color(0xFFE60000), // Rouge
    },
    {
      'name': 'Tunisie Telecom',
      'logoUrl':
          'https://upload.wikimedia.org/wikipedia/fr/thumb/f/f9/LOGO_TT_.jpg/1200px-LOGO_TT_.jpg',
      'color': Color(0xFF0066CC), // Bleu
    },
    {
      'name': 'Lycamobile',
      'logoUrl':
          'https://www.affinicia.com/forfait-mobile/wp-content/uploads/sites/3/2022/07/lyca-mobile-logo.png',
      'color': Color(0xFFFABE00), // Jaune
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
    Get.put(BillInquiryController());
    Get.to(() => BillInquiryView());
  }
}
