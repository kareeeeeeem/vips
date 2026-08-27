import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_stock_controller.dart';

class StockListView extends GetView<MerchantStockController> {
  const StockListView({super.key});

  @override
  Widget build(BuildContext context) {
    final searchQuery = ''.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'My Stock / Inventory',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)),
            onPressed: () => _showAddStockDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Inventory Summary
          _buildSummaryCards(),
          
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Items',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                      ),
                      GestureDetector(
                        onTap: () => _showSearchDialog(context, searchQuery),
                        child: Obx(() => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20.r)),
                          child: Row(
                            children: [
                              Icon(searchQuery.value.isEmpty ? Icons.search : Icons.close, size: 16, color: const Color(0xFF6B7280)),
                              SizedBox(width: 4.w),
                              Text(
                                searchQuery.value.isEmpty ? 'Search' : searchQuery.value,
                                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Obx(() {
                      final query = searchQuery.value.trim().toLowerCase();
                      final items = query.isEmpty
                          ? controller.stockItems
                          : controller.stockItems
                              .where((i) => i.name.toLowerCase().contains(query) || i.category.toLowerCase().contains(query))
                              .toList();

                      if (controller.stockItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 56.sp, color: Colors.grey.shade300),
                              SizedBox(height: 16.h),
                              Text('No stock items',
                                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8.h),
                              Text('Tap the + button to add your first item',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }
                      if (items.isEmpty) {
                        return Center(
                          child: Text('No items match "$query"',
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                        );
                      }
                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildStockItem(item);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          _buildStatCard('Low Stock', controller.lowStockCount, const Color(0xFFFEE2E2), const Color(0xFFDC2626), Icons.warning_amber_rounded),
          SizedBox(width: 16.w),
          _buildStatCard('Total Value', controller.totalInventoryValue, const Color(0xFFD1FAE5), const Color(0xFF059669), Icons.inventory_2_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, RxInterface value, Color bg, Color text, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20.sp, color: text),
            SizedBox(height: 12.h),
            Text(title, style: TextStyle(fontSize: 11.sp, color: text, fontWeight: FontWeight.w600)),
            Obx(() => Text(
              value is RxDouble
                  ? 'D ${value.value.toStringAsFixed(2)}'
                  : '${(value as RxInt).value}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: text),
            )),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, RxString searchQuery) {
    final queryController = TextEditingController(text: searchQuery.value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Stock'),
        content: TextField(
          controller: queryController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Item name or category'),
          onSubmitted: (v) {
            searchQuery.value = v;
            Get.back();
          },
        ),
        actions: [
          if (searchQuery.value.isNotEmpty)
            TextButton(
              onPressed: () {
                searchQuery.value = '';
                Get.back();
              },
              child: const Text('Clear'),
            ),
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              searchQuery.value = queryController.text;
              Get.back();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    ).then((_) => queryController.dispose());
  }

  void _showAddStockDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final stockController = TextEditingController();
    final thresholdController = TextEditingController(text: '10');
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stock Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Current Stock'), keyboardType: TextInputType.number),
              TextField(controller: thresholdController, decoration: const InputDecoration(labelText: 'Low Stock Threshold'), keyboardType: TextInputType.number),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Unit Price'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final currentStock = int.tryParse(stockController.text) ?? 0;
              final threshold = int.tryParse(thresholdController.text) ?? 10;
              final price = double.tryParse(priceController.text) ?? 0;
              if (nameController.text.isNotEmpty) {
                controller.addStockItem(StockItem(
                  id: '',
                  name: nameController.text,
                  category: categoryController.text.isEmpty ? 'General' : categoryController.text,
                  currentStock: currentStock,
                  lowStockThreshold: threshold,
                  unitPrice: price,
                ));
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      categoryController.dispose();
      stockController.dispose();
      thresholdController.dispose();
      priceController.dispose();
    });
  }

  Widget _buildStockItem(StockItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: item.isLowStock ? Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                Text(item.category, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      'Qty: ${item.currentStock}',
                      style: TextStyle(
                        fontSize: 14.sp, 
                        fontWeight: FontWeight.w800, 
                        color: item.isLowStock ? const Color(0xFFDC2626) : const Color(0xFF1F2937)
                      ),
                    ),
                    SizedBox(width: 12.w),
                    if (item.isLowStock)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(4.r)),
                        child: Text('LOW', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => controller.adjustStock(item.id, 1),
                icon: const Icon(Icons.add_circle, color: Color(0xFF10B981)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(height: 8.h),
              IconButton(
                onPressed: item.currentStock <= 0
                    ? null
                    : () => controller.adjustStock(item.id, -1),
                icon: Icon(Icons.remove_circle,
                    color: item.currentStock <= 0
                        ? const Color(0xFFD1D5DB)
                        : const Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(height: 8.h),
              // DELETE /merchant/stock/:id existed with nothing calling it,
              // so a stock line could never be removed.
              IconButton(
                onPressed: () => Get.dialog(AlertDialog(
                  title: const Text('Delete stock item'),
                  content: Text('Remove "${item.name}" from your stock list?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteStockItem(item.id);
                      },
                      child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                    ),
                  ],
                )),
                icon: Icon(Icons.delete_outline,
                    size: 20.sp, color: const Color(0xFFEF4444)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
