import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/gift_recap.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class GiftController extends GetxController {
  final TextEditingController userIdController = TextEditingController();

  final RxBool isUserIdEnabled = true.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController amountController = TextEditingController(text: '');
  final RxDouble giftAmount = 0.0.obs;

  // toggleUserIdInput() was never called and isUserIdEnabled is always true,
  // so the recipient field is simply always enabled.


  // The scanner (QRScannerController) always validates via
  // POST /rewards/validate-qr first and returns that response's `data`
  // map — never a raw String — so a scanned VIPs ID QR
  // ('VIPS_USER_<id>', see vips_id_view.dart) comes back as
  // {type: 'user', user: {id, fullName, phone}}. send-gift takes a phone
  // number, so that's what gets filled in here.
  void scanUserQR() {
    Get.toNamed('/q-r-scanner')?.then((result) {
      if (result is Map && result['type'] == 'user') {
        final phone = result['user']?['phone']?.toString();
        if (phone != null && phone.isNotEmpty) {
          userIdController.text = phone;
        } else {
          safeSnackbar('No Phone Number', 'This account has no phone number on file.');
        }
      } else if (result is Map) {
        safeSnackbar('Not a User QR', 'Scan a recipient\'s VIPs ID, not a coupon or merchant code.');
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
      debugPrint('Send gift error: $e');
      safeSnackbar('Error', 'Could not send gift. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    userIdController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
