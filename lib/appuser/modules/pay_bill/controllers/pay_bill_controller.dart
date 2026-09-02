import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

/// Paying a shop's bill with VIPs points (§4.3).
///
/// The shop rings up the total and shows a code; this resolves it and shows
/// the customer exactly what they are agreeing to before anything moves.
class PayBillController extends GetxController {
  final codeController = TextEditingController();

  final isLoading = false.obs;
  final isPaying = false.obs;
  final error = ''.obs;

  /// The resolved bill. Null until a code has been looked up.
  final bill = Rxn<Map<String, dynamic>>();
  final receipt = Rxn<Map<String, dynamic>>();

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);
  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  String get merchantName => '${bill.value?['merchant']?['name'] ?? ''}';
  double get dueTnd => _num(bill.value?['dueTnd']);
  int get pointsNeeded => _int(bill.value?['pointsNeeded']);
  int get yourPoints => _int(bill.value?['yourPoints']);
  int get shortBy => _int(bill.value?['shortBy']);
  bool get canPay => bill.value?['canPay'] == true;

  @override
  void onInit() {
    super.onInit();
    // Arrives pre-filled when the camera read a code.
    final scanned = Get.arguments is Map ? '${(Get.arguments as Map)['code'] ?? ''}' : '';
    if (scanned.isNotEmpty) {
      codeController.text = scanned;
      lookup(scanned);
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  Future<void> lookup([String? raw]) async {
    final code = (raw ?? codeController.text).trim();
    if (code.isEmpty) {
      error.value = 'Scan the code the shop is showing, or type it.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    bill.value = null;
    try {
      final response =
          await ApiService().get('/pay/bill/${Uri.encodeComponent(code)}');
      if (response.success && response.data is Map) {
        bill.value = Map<String, dynamic>.from(response.data as Map);
      } else {
        // The server's wording is what the customer needs — an expired code
        // and an already-paid bill are different problems.
        error.value = response.message.isNotEmpty
            ? response.message
            : 'That code did not match a bill.';
      }
    } catch (e) {
      debugPrint('bill lookup failed: $e');
      error.value = 'Could not reach the server. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> pay() async {
    final code = '${bill.value?['payCode'] ?? ''}';
    if (code.isEmpty) return false;

    isPaying.value = true;
    error.value = '';
    try {
      final response = await ApiService().post('/pay/bill/$code', {});
      if (response.success && response.data is Map) {
        receipt.value = Map<String, dynamic>.from(response.data as Map);
        return true;
      }
      error.value = response.message;
      // The bill may have changed under us — a second phone paying it, or
      // the shop settling it in cash. Re-read so the screen tells the truth.
      await lookup(code);
      return false;
    } catch (e) {
      debugPrint('pay failed: $e');
      error.value = 'Could not reach the server. Try again.';
      return false;
    } finally {
      isPaying.value = false;
    }
  }
}
