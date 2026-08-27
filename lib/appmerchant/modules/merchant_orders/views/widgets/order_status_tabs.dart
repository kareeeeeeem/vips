import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_order_controller.dart';

class OrderStatusTabs extends GetView<MerchantOrderController> {
  const OrderStatusTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(controller.statusFilters.length, (index) {
              final status = controller.statusFilters[index];
              return _buildTab(
                MerchantOrderController.statusLabels[status] ??
                    status.toUpperCase(),
                index,
                status,
                controller.selectedTab.value,
              );
            }),
          ),
        );
      }),
    );
  }

  /// The status key now comes straight from `statusFilters` instead of being
  /// looked back up from the display label through a hardcoded map — that map
  /// only knew 7 of the enum's values, so any tab it didn't list fell through
  /// to `'all'` and showed every order regardless of which tab was tapped.
  Widget _buildTab(String label, int index, String statusKey, int selectedIndex) {
    final isSelected = selectedIndex == index;

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
