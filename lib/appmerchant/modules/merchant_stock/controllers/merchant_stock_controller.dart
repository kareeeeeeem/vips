import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);
int _toInt(dynamic v, [int fallback = 0]) =>
    v is num ? v.toInt() : (int.tryParse('${v ?? ''}') ?? fallback);

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
        currentStock: _toInt(json['currentStock']),
        lowStockThreshold: _toInt(json['lowStockThreshold'], 10),
        unitPrice: _toDouble(json['unitPrice']),
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
        stockItems.value = list
            .whereType<Map>()
            .map((e) => StockItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _calculateStats();
      }
    } catch (e) {
      debugPrint('loadStock failed: $e');
      safeSnackbar('Error', 'Could not load your stock. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
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
      if (res.success && res.data is Map) {
        stockItems.insert(0, StockItem.fromJson(Map<String, dynamic>.from(res.data as Map)));
        _calculateStats();
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to add stock item',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('addStockItem failed: $e');
      safeSnackbar('Error', 'Could not add that item. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> adjustStock(String id, int adjustment) async {
    final index = stockItems.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final old = stockItems[index];
    final newStock = old.currentStock + adjustment;
    // The minus button had no floor, so stock could be driven negative —
    // which then also made the inventory-value total negative.
    if (newStock < 0) {
      safeSnackbar('Out of stock', '${old.name} is already at 0',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
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
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to update stock',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('adjustStock failed: $e');
      safeSnackbar('Error', 'Could not update that item. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// DELETE /merchant/stock/:id — the CRUD route has always existed with no
  /// way to reach it, so a stock line could never be removed.
  Future<void> deleteStockItem(String id) async {
    try {
      final res = await ApiService().delete('/merchant/stock/$id');
      if (res.success) {
        stockItems.removeWhere((e) => e.id == id);
        _calculateStats();
        safeSnackbar('Removed', 'Stock item deleted',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to delete item',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('deleteStockItem failed: $e');
      safeSnackbar('Error', 'Could not delete that item. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
