import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/merchant_order_controller.dart';

/// Cancellation dialog shared by the orders list card and the order detail
/// screen. Both used to cancel with the same hardcoded "Merchant canceled"
/// string, which the backend dropped on the floor anyway — the merchant now
/// picks one of the real reasons served by GET /merchant/orders?type=store,
/// and it is stored on the order.
void showCancelOrderDialog({
  required MerchantOrderController controller,
  required int orderId,
  VoidCallback? onCancelled,
}) {
  controller.loadCancelReasons();
  final selected = RxnString();

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: const Text('Cancel Order'),
      content: Obx(() {
        if (controller.isLoadingCancelReasons.value &&
            controller.cancelReasons.isEmpty) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final reasons = controller.cancelReasons;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why are you cancelling this order?',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 12.h),
            if (reasons.isEmpty)
              Text(
                'Could not load the reason list. The order will be cancelled '
                'without a recorded reason.',
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 240.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: reasons.map((r) {
                      final isSelected = selected.value == r;
                      return InkWell(
                        onTap: () => selected.value = r,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 18.sp,
                                color: isSelected
                                    ? Colors.red
                                    : const Color(0xFF9CA3AF),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(r, style: TextStyle(fontSize: 13.sp)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        );
      }),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('No'),
        ),
        Obx(() {
          final canConfirm =
              controller.cancelReasons.isEmpty || selected.value != null;
          return ElevatedButton(
            onPressed: !canConfirm
                ? null
                : () async {
                    Get.back();
                    final success = await controller.updateOrderStatus(
                      orderId,
                      'canceled',
                      reason: selected.value,
                    );
                    if (success) onCancelled?.call();
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          );
        }),
      ],
    ),
  );
}
