import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class BusinessAsset {
  final String id;
  final String name;
  final String type;
  final double value;
  final DateTime purchaseDate;

  BusinessAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.purchaseDate,
  });

  factory BusinessAsset.fromJson(Map<String, dynamic> json) => BusinessAsset(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? 'Other',
        value: (json['value'] ?? 0).toDouble(),
        purchaseDate: json['purchaseDate'] != null
            ? DateTime.parse(json['purchaseDate'])
            : DateTime.now(),
      );
}

class MerchantAssetController extends GetxController {
  final assets = <BusinessAsset>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssets();
  }

  Future<void> loadAssets() async {
    isLoading.value = true;
    try {
      final res = await ApiService().get('/merchant/assets');
      if (res.success && res.data != null) {
        final rawData = res.data;
        final List<dynamic> list = rawData is List
            ? rawData
            : (rawData is Map ? (rawData['assets'] ?? rawData['data'] ?? []) : []);
        assets.value = list.map((e) => BusinessAsset.fromJson(e)).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAsset(Map<String, dynamic> body) async {
    try {
      final res = await ApiService().post('/merchant/assets', body);
      if (res.success && res.data != null) {
        final data = res.data;
        assets.insert(0, BusinessAsset.fromJson(data));
      } else {
        safeSnackbar('Error', 'Failed to add asset', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to add asset', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      final res = await ApiService().delete('/merchant/assets/$id');
      if (res.success) {
        assets.removeWhere((e) => e.id == id);
      } else {
        safeSnackbar('Error', 'Failed to delete asset', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to delete asset', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
