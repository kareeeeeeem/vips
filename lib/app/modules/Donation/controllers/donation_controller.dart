import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DonationController extends GetxController {
  final RxnInt selectedOrganizationIndex = RxnInt();
  final TextEditingController amountController = TextEditingController();

  final List<Map<String, String>> organizations = [
    {'name': 'Red Cross', 'logo': 'assets/images/donation1.png'},
    {'name': 'UNICEF', 'logo': 'assets/images/donation2.png'},
    {'name': 'WHO', 'logo': 'assets/images/donation3.png'},
    {'name': 'Save Children', 'logo': 'assets/images/donation4.png'},
    {'name': 'Water Aid', 'logo': 'assets/images/donation5.png'},
    {'name': 'WWF', 'logo': 'assets/images/donation6.png'},
  ];

  void selectOrganization(int index) {
    selectedOrganizationIndex.value = index;
  }

  void proceed() {
    if (selectedOrganizationIndex.value == null) {
      return;
    }

    if (amountController.text.isEmpty) {
      return;
    }

    // TODO: Navigate to bill inquiry
    Get.toNamed(
      '/bill-inquiry-donation',
      arguments: {
        'organization': organizations[selectedOrganizationIndex.value!],
        'amount': amountController.text,
      },
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
