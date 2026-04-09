import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/widgets/add_card.dart';

class CreditController extends GetxController {
  // Controllers
  final vipsNumberController = TextEditingController();

  // Observables
  final RxString vipsNumber = ''.obs;
  final RxString selectedPaymentMethod = ''.obs;
  final RxBool isVipsNumberValid = false.obs;
  final RxList<BankCard> bankCards = <BankCard>[].obs;
  final RxBool isExpanded = false.obs;

  // Constantes
  final double vipsToTndRate = 0.1; // 100 VPS = 10 TND
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

  // Charger les cartes bancaires
  void loadBankCards() {
    bankCards.value = [
      BankCard(
        id: '1',
        bankName: 'Axis Bank',
        lastFourDigits: '8395',
        isDefault: true,
      ),
      BankCard(
        id: '2',
        bankName: 'HDFC Bank',
        lastFourDigits: '6246',
        isDefault: false,
      ),
    ];
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
    if (!isFormValid) {
      return;
    }

    Get.toNamed(
      '/bill-inquiry-credit',
      arguments: {
        'vipsNumber': vipsNumber.value,
        'amount': amountInTnd,
        'cardId': selectedPaymentMethod.value,
      },
    );
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
