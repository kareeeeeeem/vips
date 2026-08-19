import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/gift_recap.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class GiftController extends GetxController {
  final TextEditingController offerIdController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  final RxBool isUserIdEnabled = true.obs;
  final RxBool isExpressSelected = false.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController amountController = TextEditingController(text: '');
  final RxDouble giftAmount = 0.0.obs;

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
    Get.toNamed('/q-r-scanner')?.then((result) {
      if (result != null && result is String) {
        offerIdController.text = result;
      }
    });
  }

  void scanUserQR() {
    Get.toNamed('/q-r-scanner')?.then((result) {
      if (result != null && result is String) {
        userIdController.text = result;
      }
    });
  }

  void openUserSelector() {
    Get.dialog(
      AlertDialog(
        title: const Text('Enter Recipient'),
        content: TextField(
          controller: userIdController,
          decoration: const InputDecoration(hintText: 'Phone number or user ID'),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> proceed() async {
    if (userIdController.text.isEmpty) {
      safeSnackbar('Error', 'Please enter a recipient ID/Phone');
      return;
    }
    final amount = double.tryParse(amountController.text.trim()) ?? giftAmount.value;
    if (amount <= 0) {
      safeSnackbar('Error', 'Please enter a valid gift amount');
      return;
    }
    isLoading.value = true;

    try {
      final response = await ApiService().post('/rewards/send-gift', {
        'recipientPhone': userIdController.text,
        'amount': amount,
        'message': 'Gift from VIPs App',
      });

      if (response.success) {
        Get.put(GiftRecapController());
        Get.to(
          () => const GiftRecapView(),
          arguments: {
            'transferTo': userIdController.text,
            'giftAmount': amount,
          },
        );
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to send gift: $e');
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
    amountController.dispose();
    super.onClose();
  }
}
