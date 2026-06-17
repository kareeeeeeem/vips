import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_order_controller.dart';

class OrderStatusTabs extends GetView<MerchantOrderController> {
  const OrderStatusTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                controller.statusFilters.map((status) {
                  if (status == 'all') {
                    return _buildTab('All', 0, controller.selectedTab.value);
                  }
                  final index = controller.statusFilters.indexOf(status);
                  return _buildTab(
                    status.toUpperCase(),
                    index,
                    controller.selectedTab.value,
                  );
                }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildTab(String label, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    final statusMap = {
      'ALL': 'all',
      'PENDING': 'pending',
      'CONFIRMED': 'confirmed',
      'PROCESSING': 'processing',
      'READY': 'ready',
      'DELIVERED': 'delivered',
      'CANCELED': 'canceled',
    };
    final statusKey = statusMap[label] ?? 'all';

    return GestureDetector(
      onTap: () {
        controller.selectedTab.value = index;
        controller.updateStatusFilter(statusKey);
      },
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
