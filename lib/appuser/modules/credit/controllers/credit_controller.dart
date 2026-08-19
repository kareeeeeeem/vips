import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/core/services/api_service.dart';

import 'package:vip/core/utils/safe_snackbar.dart';

class CreditController extends GetxController {
  // Controllers
  final vipsNumberController = TextEditingController();

  // Observables
  final RxString vipsNumber = ''.obs;
  // 'paymee' or 'paypal' — real gateways only, no saved-card concept (that
  // would need PCI-compliant card tokenization, out of scope; see
  // checkout_controller.dart for the same pattern used at checkout).
  final RxString selectedGateway = ''.obs;
  final RxBool isVipsNumberValid = false.obs;
  final RxList<Map<String, String>> availableGateways = <Map<String, String>>[].obs;
  final RxBool isExpanded = false.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxInt walletPoints = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;

  // Rates loaded from API
  final RxDouble vipsToTndRateObs = 0.1.obs;
  double get vipsToTndRate => vipsToTndRateObs.value;
  final int minVipsPurchase = 100;

  @override
  void onInit() {
    super.onInit();
    loadWalletAndGateways();

    vipsNumberController.addListener(() {
      vipsNumber.value = vipsNumberController.text;
      validateVipsNumber();
    });
  }

  Future<void> loadWalletAndGateways() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        ApiService().get('/user/wallet'),
        ApiService().get('/payment/methods'),
        ApiService().get('/config/rates'),
      ]);

      final walletRes = results[0];
      if (walletRes.success && walletRes.data != null) {
        walletBalance.value = ((walletRes.data['balance'] ?? 0) as num).toDouble();
        walletPoints.value = ((walletRes.data['points'] ?? 0) as num).toInt();
      }

      final methodsRes = results[1];
      if (methodsRes.success && methodsRes.data is Map) {
        final data = methodsRes.data as Map;
        final gateways = <Map<String, String>>[];
        if (data['paymee']?['configured'] == true) {
          gateways.add({'id': 'paymee', 'name': 'Paymee'});
        }
        if (data['paypal']?['configured'] == true) {
          gateways.add({'id': 'paypal', 'name': 'PayPal'});
        }
        availableGateways.value = gateways;
      }

      final ratesRes = results[2];
      if (ratesRes.success && ratesRes.data != null) {
        final rate = ratesRes.data['vipsToTnd'] ?? ratesRes.data['conversionRate'];
        if (rate != null) vipsToTndRateObs.value = (rate as num).toDouble();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  // Valider le nombre de VIPS
  void validateVipsNumber() {
    final vips = int.tryParse(vipsNumberController.text);
    isVipsNumberValid.value = vips != null && vips >= minVipsPurchase;
  }

  // Calculer le montant en TND
  double get amountInTnd {
    final vips = int.tryParse(vipsNumberController.text) ?? 0;
    return vips * vipsToTndRate;
  }

  void selectGateway(String gatewayId) {
    selectedGateway.value = gatewayId;
  }

  // Vérifier si le formulaire est valide
  bool get isFormValid =>
      isVipsNumberValid.value && selectedGateway.value.isNotEmpty;

  // Procéder au paiement
  void proceedToPayment() {
    if (!isFormValid) return;

    final vips = int.tryParse(vipsNumber.value) ?? 0;
    final tnd = amountInTnd;
    final gateway = availableGateways.firstWhereOrNull((g) => g['id'] == selectedGateway.value);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm Purchase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _confirmRow('VIPS Points', '$vips pts'),
            _confirmRow('Amount', '${tnd.toStringAsFixed(2)} TND'),
            if (gateway != null) _confirmRow('Pay with', gateway['name']!),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() => ElevatedButton(
                onPressed: isProcessing.value ? null : () => _confirmPurchase(vips),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isProcessing.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              )),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Same external-browser + poll pattern as CheckoutController's online
  // payment flow — both gateways host their own checkout page, there's no
  // in-app card form.
  Future<void> _confirmPurchase(int vipsAmount) async {
    isProcessing.value = true;
    try {
      final gateway = selectedGateway.value;
      final initiateResponse = await ApiService().post(
        gateway == 'paymee' ? '/payment/paymee/topup-initiate' : '/payment/paypal/topup-create',
        {'vipsAmount': vipsAmount},
      );

      if (!initiateResponse.success || initiateResponse.data == null) {
        Get.back();
        safeSnackbar('Payment Unavailable', initiateResponse.message,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final data = initiateResponse.data as Map;
      final url = gateway == 'paymee' ? data['paymentUrl'] : data['approveUrl'];
      final topupId = data['topupId']?.toString();
      if (url == null || topupId == null) {
        Get.back();
        safeSnackbar('Error', 'Payment link unavailable.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final launched = await launchUrl(Uri.parse(url.toString()), mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.back();
        safeSnackbar('Error', 'Could not open the payment page.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      Get.back(); // close confirm sheet
      _showAwaitingPaymentDialog(topupId, gateway, vipsAmount);
    } catch (e) {
      Get.back();
      safeSnackbar('Error', 'Purchase failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  void _showAwaitingPaymentDialog(String topupId, String gateway, int vipsAmount) {
    final isChecking = false.obs;
    Timer? pollTimer;

    Future<void> checkStatus({bool manual = false}) async {
      if (isChecking.value) return;
      isChecking.value = true;
      try {
        String? status;
        if (gateway == 'paypal') {
          final captureResponse = await ApiService().post('/payment/paypal/topup-capture', {'topupId': topupId});
          if (captureResponse.data is Map) status = captureResponse.data['status']?.toString();
        } else {
          final statusResponse = await ApiService().get('/payment/paymee/topup-status/$topupId');
          if (statusResponse.data is Map) status = statusResponse.data['status']?.toString();
        }
        if (status == 'paid') {
          pollTimer?.cancel();
          Get.back();
          walletPoints.value += vipsAmount;
          walletBalance.value += vipsAmount * vipsToTndRate;
          vipsNumberController.clear();
          selectedGateway.value = '';
          safeSnackbar('Success', '$vipsAmount VIPS added to your wallet!',
              backgroundColor: Colors.green, colorText: Colors.white);
        } else if (manual) {
          safeSnackbar('Not Confirmed Yet', "Payment hasn't completed yet. Finish it in the browser, then try again.",
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (_) {
      } finally {
        isChecking.value = false;
      }
    }

    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                const SizedBox(height: 16),
                const Text('Waiting for payment confirmation…',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Complete the payment in your browser, then come back here.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        pollTimer?.cancel();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => checkStatus(manual: true),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                      child: const Text("I've Paid", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    var elapsed = 0;
    pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      elapsed += 4;
      if (elapsed >= 120) {
        timer.cancel();
        return;
      }
      checkStatus();
    });
  }

  @override
  void onClose() {
    vipsNumberController.dispose();
    super.onClose();
  }
}
