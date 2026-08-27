import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class DonationController extends GetxController {
  final RxnInt selectedOrganizationIndex = RxnInt();
  final TextEditingController amountController = TextEditingController();
  final RxBool isLoading = false.obs;

  // Seed list shown for the moment before /services/organizations answers.
  // Each entry used to carry a 'logo' path under assets/images/donation*.png —
  // six files that do not exist in the bundle, and which nothing ever
  // rendered (the screen shows organisation names only).
  final RxList<Map<String, String>> organizations = <Map<String, String>>[
    {'name': 'Red Cross'},
    {'name': 'UNICEF'},
    {'name': 'WHO'},
    {'name': 'Save Children'},
    {'name': 'Water Aid'},
    {'name': 'WWF'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    try {
      final response = await ApiService().get('/services/organizations');
      if (response.success && response.data != null) {
        final List<dynamic> orgs = response.data is List
            ? response.data
            : (response.data['organizations'] ?? []);
        if (orgs.isNotEmpty) {
          organizations.value = orgs.map((o) => {
            'name': (o['name'] ?? '').toString(),
            'logo': (o['logo'] ?? o['image'] ?? '').toString(),
            'id': (o['_id'] ?? o['id'] ?? '').toString(),
          }).toList();
        }
      }
    } catch (_) {}
  }

  void selectOrganization(int index) {
    selectedOrganizationIndex.value = index;
  }

  Future<void> proceed() async {
    // organizations can be replaced by a shorter real list from
    // /services/organizations after the user already tapped one of the
    // initial placeholder entries — re-validate the index is still in
    // bounds rather than indexing straight in (would throw RangeError).
    final index = selectedOrganizationIndex.value;
    if (index == null || index < 0 || index >= organizations.length) {
      safeSnackbar('Error', 'Please select an organization', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      safeSnackbar('Error', 'Please enter a valid amount', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final org = organizations[index]['name'] ?? '';
    isLoading.value = true;
    try {
      final response = await ApiService().post('/services/donate', {
        'organization': org,
        'amount': amount,
      });

      if (response.success) {
        safeSnackbar(
          'Thank You!',
          'Donation of ${amount.toStringAsFixed(2)} TND to $org was successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        amountController.clear();
        selectedOrganizationIndex.value = null;
        Get.back();
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to process donation', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
