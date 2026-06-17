import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_order_controller.dart';
import 'order_card.dart';

class OrderListWidget extends GetView<MerchantOrderController> {
  const OrderListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.filteredOrders.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.filteredOrders.length) {
            // Load more indicator
            return Obx(() {
              if (controller.isLoadingMore.value) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF10B981),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            });
          }

          final order = controller.filteredOrders[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: OrderCard(order: order),
          );
        },
      );
    });
  }
}