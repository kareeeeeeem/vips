import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class VipsClubHistoryController extends GetxController {
  final RxInt convertibleDiamants = 0.obs;
  final RxBool isLoading = false.obs;

  final RxList<DiamantTransaction> transactions = <DiamantTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final walletRes = await ApiService().get('/user/wallet');
      if (walletRes.success && walletRes.data != null) {
        convertibleDiamants.value = (walletRes.data['points'] as num?)?.toInt() ?? 0;
      }

      final txRes = await ApiService().get('/user/transactions');
      if (txRes.success && txRes.data != null) {
        final List<dynamic> txList = txRes.data['transactions'] ?? [];
        transactions.value = txList.map((tx) {
          return DiamantTransaction(
            amount: (tx['amount'] as num).toInt(),
            type: tx['type'] ?? 'credit',
            description: tx['description'],
            date: tx['createdAt'] != null
                ? DateTime.parse(tx['createdAt'])
                : DateTime.now(),
            orderNumber: tx['reference'],
          );
        }).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onConvertNow() async {
    final points = convertibleDiamants.value;
    if (points < 100) {
      safeSnackbar('Insufficient Points', 'You need at least 100 points to convert', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      final response = await ApiService().post('/user/vips-club/convert', {'points': points});
      Get.back();
      if (response.success) {
        final earned = response.data['walletAmount'];
        safeSnackbar('Converted!', '$points points → $earned TND added to wallet', snackPosition: SnackPosition.BOTTOM);
        await loadHistory();
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      safeSnackbar('Error', 'Failed to convert points', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month ${date.year} $hour:$minute';
  }
}

class DiamantTransaction {
  final int amount;
  final String type;
  final String? description;
  final DateTime date;
  final String? orderNumber;

  DiamantTransaction({
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.orderNumber,
  });
}
