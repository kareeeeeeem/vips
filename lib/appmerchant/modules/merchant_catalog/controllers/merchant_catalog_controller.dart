import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MerchantCatalogController extends GetxController {
  // Common states
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final selectedCategory = 'Select'.obs;
  
  // Shipping states
  final isDelivery = true.obs;
  final isTakeaway = true.obs;
  final isDineIn = false.obs;
  final deliveryTime = '15 Min'.obs; // '15 Min', '30 Min', '45 Min', '+90 Min'

  // Item specific
  final isFeatureProduct = false.obs;
  final hasMultiVariants = false.obs;
  final hasPromotionalPrice = false.obs;

  // Coupon / Voucher specific
  final tags = <String>[].obs;
  final tagController = TextEditingController();

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
      tagController.clear();
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  @override
  void onClose() {
    tagController.dispose();
    super.onClose();
  }
}
