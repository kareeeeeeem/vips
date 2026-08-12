import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/add_card.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class CreditController extends GetxController {
  // Controllers
  final vipsNumberController = TextEditingController();

  // Observables
  final RxString vipsNumber = ''.obs;
  final RxString selectedPaymentMethod = ''.obs;
  final RxBool isVipsNumberValid = false.obs;
  final RxList<BankCard> bankCards = <BankCard>[].obs;
  final RxBool isExpanded = false.obs;
  final RxDouble walletBalance = 0.0.obs;
  final RxInt walletPoints = 0.obs;
  final RxBool isLoading = false.obs;

  // Rates loaded from API
  final RxDouble vipsToTndRateObs = 0.1.obs;
  double get vipsToTndRate => vipsToTndRateObs.value;
  final int minVipsPurchase = 100;

  @override
  void onInit() {
    super.onInit();
    loadBankCards();

    vipsNumberController.addListener(() {
      vipsNumber.value = vipsNumberController.text;
      validateVipsNumber();
    });
  }

  Future<void> loadBankCards() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        ApiService().get('/user/wallet'),
        ApiService().get('/user/payment-methods'),
        ApiService().get('/config/rates'),
      ]);

      final walletRes = results[0];
      if (walletRes.success && walletRes.data != null) {
        walletBalance.value = ((walletRes.data['balance'] ?? 0) as num).toDouble();
        walletPoints.value = ((walletRes.data['points'] ?? 0) as num).toInt();
      }

      final cardsRes = results[1];
      if (cardsRes.success && cardsRes.data != null) {
        final List<dynamic> cards = cardsRes.data['cards'] ?? cardsRes.data ?? [];
        if (cards.isNotEmpty) {
          bankCards.value = cards.map((c) => BankCard(
            id: c['_id'] ?? c['id'] ?? '',
            bankName: c['bankName'] ?? c['name'] ?? 'Bank',
            lastFourDigits: c['lastFour'] ?? c['last4'] ?? '****',
            isDefault: c['isDefault'] ?? false,
          )).toList();
        }
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

  // Sélectionner une carte
  void selectCard(String cardId) {
    selectedPaymentMethod.value = cardId;
  }

  // Vérifier si le formulaire est valide
  bool get isFormValid =>
      isVipsNumberValid.value && selectedPaymentMethod.value.isNotEmpty;

  // Ouvrir le bottom sheet pour ajouter une carte
  void showAddCardSheet() {
    Get.bottomSheet(
      AddCardBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Procéder au paiement
  void proceedToPayment() {
    if (!isFormValid) return;

    final vips = int.tryParse(vipsNumber.value) ?? 0;
    final tnd = amountInTnd;
    final card = bankCards.firstWhereOrNull((c) => c.id == selectedPaymentMethod.value);

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
            if (card != null) _confirmRow('Card', card.maskedNumber),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(() => ElevatedButton(
                onPressed: isLoading.value ? null : () => _confirmPurchase(vips, card?.lastFourDigits ?? ''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading.value
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

  Future<void> _confirmPurchase(int vipsAmount, String cardLastFour) async {
    isLoading.value = true;
    try {
      final response = await ApiService().post('/user/wallet/topup', {
        'vipsAmount': vipsAmount,
        'cardId': cardLastFour,
      });
      Get.back();
      if (response.success) {
        walletPoints.value += vipsAmount;
        vipsNumberController.clear();
        selectedPaymentMethod.value = '';
        safeSnackbar('Success', '$vipsAmount VIPS added to your wallet!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        safeSnackbar('Error', response.message,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      safeSnackbar('Error', 'Purchase failed. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    vipsNumberController.dispose();
    super.onClose();
  }
}

// Modèle de carte bancaire
class BankCard {
  final String id;
  final String bankName;
  final String lastFourDigits;
  final bool isDefault;

  BankCard({
    required this.id,
    required this.bankName,
    required this.lastFourDigits,
    this.isDefault = false,
  });

  String get maskedNumber => '**** **** **** $lastFourDigits';
}
