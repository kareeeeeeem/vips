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
        rate: (json['rate'] ?? 0).toDouble(),
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
        taxRates.value = list.map((e) => TaxRate.fromJson(e)).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTaxRate(String name, double rate) async {
    try {
      final res = await ApiService().post('/merchant/tax-rates', {'name': name, 'rate': rate});
      if (res.success && res.data != null) {
        final data = res.data;
        taxRates.add(TaxRate.fromJson(data));
      } else {
        safeSnackbar('Error', 'Failed to add tax rate', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to add tax rate', snackPosition: SnackPosition.BOTTOM);
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
        safeSnackbar('Error', 'Failed to update tax rate', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to update tax rate', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTaxRate(String id) async {
    try {
      final res = await ApiService().delete('/merchant/tax-rates/$id');
      if (res.success) {
        taxRates.removeWhere((e) => e.id == id);
      } else {
        safeSnackbar('Error', 'Failed to delete tax rate', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to delete tax rate', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
