import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  void proceed() {
    isLoading.value = true;

    Future.delayed(Duration(seconds: 1), () {
      isLoading.value = false;
      Get.put(GiftRecapController());
      Get.to(() => GiftRecapView());
    });
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
