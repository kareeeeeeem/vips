import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class TaxRate {
  final String id;
  final String name;
  final double rate;
  final bool isActive;

  TaxRate({
    required this.id,
    required this.name,
    required this.rate,
    this.isActive = true,
  });

  factory TaxRate.fromJson(Map<String, dynamic> json) => TaxRate(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        rate: json['rate'] is num
            ? (json['rate'] as num).toDouble()
            : (double.tryParse('${json['rate'] ?? ''}') ?? 0),
        isActive: json['isActive'] ?? true,
      );
}

class MerchantTaxController extends GetxController {
  final taxRates = <TaxRate>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTaxRates();
  }

  Future<void> loadTaxRates() async {
    isLoading.value = true;
    try {
      final res = await ApiService().get('/merchant/tax-rates');
      if (res.success && res.data != null) {
        final rawData = res.data;
        final List<dynamic> list = rawData is List
            ? rawData
            : (rawData is Map ? (rawData['taxRates'] ?? rawData['data'] ?? []) : []);
        taxRates.value = list
            .whereType<Map>()
            .map((e) => TaxRate.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('loadTaxRates failed: $e');
      safeSnackbar('Error', 'Could not load your tax rates. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTaxRate(String name, double rate) async {
    if (name.trim().isEmpty) {
      safeSnackbar('Error', 'Enter a name for the tax rate',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // A tax rate outside 0-100% is never valid; nothing checked this before,
    // so a negative or 500% rate could be saved and then applied to bills.
    if (rate < 0 || rate > 100) {
      safeSnackbar('Error', 'Rate must be between 0 and 100 %',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final res = await ApiService()
          .post('/merchant/tax-rates', {'name': name.trim(), 'rate': rate});
      if (res.success && res.data is Map) {
        taxRates.add(TaxRate.fromJson(Map<String, dynamic>.from(res.data as Map)));
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to add tax rate',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('addTaxRate failed: $e');
      safeSnackbar('Error', 'Could not add that tax rate. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleTaxStatus(int index) async {
    final old = taxRates[index];
    try {
      final res = await ApiService().put('/merchant/tax-rates/${old.id}', {'isActive': !old.isActive});
      if (res.success) {
        taxRates[index] = TaxRate(
          id: old.id,
          name: old.name,
          rate: old.rate,
          isActive: !old.isActive,
        );
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to update tax rate',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('toggleTaxStatus failed: $e');
      safeSnackbar('Error', 'Could not update that tax rate. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTaxRate(String id) async {
    try {
      final res = await ApiService().delete('/merchant/tax-rates/$id');
      if (res.success) {
        taxRates.removeWhere((e) => e.id == id);
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to delete tax rate',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('deleteTaxRate failed: $e');
      safeSnackbar('Error', 'Could not delete that tax rate. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
