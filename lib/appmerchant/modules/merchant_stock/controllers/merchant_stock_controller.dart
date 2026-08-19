import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class StockItem {
  final String id;
  final String name;
  final String category;
  final int currentStock;
  final int lowStockThreshold;
  final double unitPrice;

  bool get isLowStock => currentStock <= lowStockThreshold;

  StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.unitPrice,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? 'General',
        currentStock: (json['currentStock'] ?? 0).toInt(),
        lowStockThreshold: (json['lowStockThreshold'] ?? 10).toInt(),
        unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'currentStock': currentStock,
        'lowStockThreshold': lowStockThreshold,
        'unitPrice': unitPrice,
      };
}

class MerchantStockController extends GetxController {
  final stockItems = <StockItem>[].obs;
  final isLoading = false.obs;
  final totalInventoryValue = 0.0.obs;
  final lowStockCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStock();
  }

  Future<void> loadStock() async {
    isLoading.value = true;
    try {
      final res = await ApiService().get('/merchant/stock');
      if (res.success && res.data != null) {
        final List<dynamic> list = res.data is List ? res.data : [];
        stockItems.value = list.map((e) => StockItem.fromJson(e)).toList();
        _calculateStats();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    double total = 0;
    int low = 0;
    for (var item in stockItems) {
      total += item.currentStock * item.unitPrice;
      if (item.isLowStock) low++;
    }
    totalInventoryValue.value = total;
    lowStockCount.value = low;
  }

  Future<void> addStockItem(StockItem item) async {
    try {
      final res = await ApiService().post('/merchant/stock', item.toJson());
      if (res.success && res.data != null) {
        stockItems.insert(0, StockItem.fromJson(res.data));
        _calculateStats();
      } else {
        safeSnackbar('Error', 'Failed to add stock item', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to add stock item', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> adjustStock(String id, int adjustment) async {
    final index = stockItems.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final old = stockItems[index];
    final newStock = old.currentStock + adjustment;
    try {
      final res = await ApiService().put('/merchant/stock/$id', {'currentStock': newStock});
      if (res.success) {
        stockItems[index] = StockItem(
          id: old.id,
          name: old.name,
          category: old.category,
          currentStock: newStock,
          lowStockThreshold: old.lowStockThreshold,
          unitPrice: old.unitPrice,
        );
        _calculateStats();
      } else {
        safeSnackbar('Error', 'Failed to update stock', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to update stock', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
