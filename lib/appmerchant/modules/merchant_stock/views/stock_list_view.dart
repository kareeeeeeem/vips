import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_stock_controller.dart';

class StockListView extends GetView<MerchantStockController> {
  const StockListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20.r)),
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 16, color: Color(0xFF6B7280)),
                            SizedBox(width: 4.w),
                            Text('Search', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Obx(() => ListView.builder(
                      itemCount: controller.stockItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.stockItems[index];
                        return _buildStockItem(item);
                      },
                    )),
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
              value is RxDouble ? 'D ${value.value.toStringAsFixed(2)}' : '${value}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: text),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStockItem(StockItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.r),
        border: item.isLowStock ? Border.all(color: const Color(0xFFDC2626).withOpacity(0.3)) : null,
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
                onPressed: () => controller.adjustStock(item.id, -1),
                icon: const Icon(Icons.remove_circle, color: Color(0xFF6B7280)),
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
