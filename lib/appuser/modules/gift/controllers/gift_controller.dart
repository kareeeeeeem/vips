import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/gift_recap.dart';

class GiftController extends GetxController {
  final TextEditingController offerIdController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  final RxBool isUserIdEnabled = true.obs;
  final RxBool isExpressSelected = false.obs;
  final RxBool isLoading = false.obs;

  void toggleUserIdInput() {
    isUserIdEnabled.value = !isUserIdEnabled.value;
    if (!isUserIdEnabled.value) {
      userIdController.clear();
    }
  }

  void toggleExpress() {
    isExpressSelected.value = !isExpressSelected.value;
  }

  void scanOfferQR() {
    // TODO: Implement QR scanner
  }

  void scanUserQR() {
    // TODO: Implement QR scanner
  }

  void openUserSelector() {
    // TODO: Open user selector dialog
  }

  Future<void> proceed() async {
    if (userIdController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a recipient ID/Phone');
      return;
    }
    isLoading.value = true;

    try {
      final response = await ApiService().post('/rewards/send-gift', {
        'recipientPhone': userIdController.text,
        'amount': 50, // Hardcoded for now based on the UI flow, can be dynamic
        'message': 'Gift from VIPs App',
      });

      if (response.success) {
        Get.put(GiftRecapController());
        Get.to(() => const GiftRecapView());
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send gift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    offerIdController.dispose();
    userIdController.dispose();
    super.onClose();
  }
}
