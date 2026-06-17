import 'package:get/get.dart';

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
}

class MerchantStockController extends GetxController {
  final stockItems = <StockItem>[].obs;
  
  final totalInventoryValue = 0.0.obs;
  final lowStockCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    _calculateStats();
  }

  void _loadMockData() {
    stockItems.assignAll([
      StockItem(
        id: '1',
        name: 'Classic Pizza Dough',
        category: 'Ingredients',
        currentStock: 15,
        lowStockThreshold: 20,
        unitPrice: 2.5,
      ),
      StockItem(
        id: '2',
        name: 'Mozzarella Cheese',
        category: 'Ingredients',
        currentStock: 45,
        lowStockThreshold: 10,
        unitPrice: 15.0,
      ),
      StockItem(
        id: '3',
        name: 'Tomato Sauce (Large)',
        category: 'Supplies',
        currentStock: 8,
        lowStockThreshold: 10,
        unitPrice: 12.0,
      ),
    ]);
  }

  void _calculateStats() {
    double total = 0;
    int low = 0;
    for (var item in stockItems) {
      total += (item.currentStock * item.unitPrice);
      if (item.isLowStock) low++;
    }
    totalInventoryValue.value = total;
    lowStockCount.value = low;
  }

  void adjustStock(String id, int adjustment) {
    int index = stockItems.indexWhere((element) => element.id == id);
    if (index != -1) {
      var old = stockItems[index];
      stockItems[index] = StockItem(
        id: old.id,
        name: old.name,
        category: old.category,
        currentStock: old.currentStock + adjustment,
        lowStockThreshold: old.lowStockThreshold,
        unitPrice: old.unitPrice,
      );
      _calculateStats();
    }
  }
}
