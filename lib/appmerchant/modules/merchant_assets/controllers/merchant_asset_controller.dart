import 'package:get/get.dart';

class BusinessAsset {
  final String id;
  final String name;
  final String type; // 'Furniture', 'Machinery', 'Electronic'
  final double value;
  final DateTime purchaseDate;

  BusinessAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.purchaseDate,
  });
}

class MerchantAssetController extends GetxController {
  final assets = <BusinessAsset>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    assets.assignAll([
      BusinessAsset(id: '1', name: 'Pizza Oven', type: 'Machinery', value: 5000.0, purchaseDate: DateTime(2023, 1, 10)),
      BusinessAsset(id: '2', name: 'Tables & Chairs', type: 'Furniture', value: 2000.0, purchaseDate: DateTime(2023, 3, 5)),
      BusinessAsset(id: '3', name: 'POS Tablet', type: 'Electronic', value: 400.0, purchaseDate: DateTime(2024, 1, 20)),
    ]);
  }
}
