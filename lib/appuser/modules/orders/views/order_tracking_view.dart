import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vip/appuser/design_system/atoms/app_colors.dart';

import '../controllers/order_tracking_controller.dart';

/// Where an order has got to.
class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  static const Color _muted = Color(0xFF9CA3AF);
  static const Color _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black87),
          onPressed: Get.back,
        ),
        title: Obx(() => Text(
              controller.orderNumber.isEmpty
                  ? 'Track order'
                  : 'Order #${controller.orderNumber}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.data.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty && controller.data.isEmpty) {
          return _buildError();
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColors.AppPrimaryColor,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              if (controller.liveLocation != null) ...[
                _buildLocation(),
                SizedBox(height: 12.h),
              ],
              _buildTimeline(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 36.sp, color: _muted),
            SizedBox(height: 10.h),
            Text(controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: _muted)),
            SizedBox(height: 14.h),
            ElevatedButton(
              onPressed: controller.load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.AppPrimaryColor),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _line),
        ),
        child: child,
      );

  Widget _buildHeader() {
    final status = controller.status;
    final colour = _statusColour(status);
    final eta = controller.estimatedDeliveryAt;

    return _card(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              color: colour.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(status), size: 22.sp, color: colour),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrderTrackingController.label(status),
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w800, color: colour),
                ),
                SizedBox(height: 3.h),
                Text(
                  controller.merchantName.isEmpty
                      ? 'Your order'
                      : 'From ${controller.merchantName}',
                  style: TextStyle(fontSize: 11.5.sp, color: _muted),
                ),
                if (eta != null && !controller.isStopped) ...[
                  SizedBox(height: 5.h),
                  Text(
                    // The merchant's own estimate, not a guess. Shown only
                    // when they have actually given one.
                    'Expected ${DateFormat('d MMM, HH:mm').format(eta.toLocal())}',
                    style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    final location = controller.liveLocation!;
    final updated = DateTime.tryParse('${location['updatedAt'] ?? ''}');

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.near_me_outlined,
                  size: 17.sp, color: AppColors.AppPrimaryColor),
              SizedBox(width: 8.w),
              Text('Where it is now',
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${location['lat']}, ${location['lng']}',
            style: TextStyle(
                fontSize: 12.sp, fontFamily: 'monospace', color: Colors.black87),
          ),
          if (updated != null) ...[
            SizedBox(height: 3.h),
            Text('Reported ${DateFormat('HH:mm').format(updated.toLocal())}',
                style: TextStyle(fontSize: 10.5.sp, color: _muted)),
          ],
          SizedBox(height: 8.h),
          Text(
            // Said rather than implied by an empty grey rectangle: there is
            // no map here, and a placeholder shaped like one would suggest a
            // map that failed to load.
            'Shown as coordinates — this app has no map component yet.',
            style: TextStyle(fontSize: 10.5.sp, height: 1.35, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (!controller.historyRecorded) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress',
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text(
              // An empty timeline would read as nothing having happened to
              // the order, which is a different and worse claim.
              'This order was placed before step-by-step tracking was '
              'recorded, so only its current status is known.',
              style: TextStyle(fontSize: 11.5.sp, height: 1.45, color: _muted),
            ),
          ],
        ),
      );
    }

    if (controller.isStopped) return _buildStoppedTimeline();

    final flow = OrderTrackingController.flow;
    final reached = flow.indexWhere((s) => s == controller.status);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 14.h),
          for (var i = 0; i < flow.length; i++)
            _buildStep(
              stage: flow[i],
              done: reached >= 0 && i <= reached,
              current: i == reached,
              isLast: i == flow.length - 1,
            ),
        ],
      ),
    );
  }

  /// A cancelled or refunded order has left the normal flow, so the step list
  /// is meaningless — what happened is shown instead of what was supposed to.
  Widget _buildStoppedTimeline() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What happened',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 14.h),
          for (var i = 0; i < controller.history.length; i++)
            _buildRecordedStep(
              controller.history[i],
              isLast: i == controller.history.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String stage,
    required bool done,
    required bool current,
    required bool isLast,
  }) {
    final entry = controller.entryFor(stage);
    final at = DateTime.tryParse('${entry?['at'] ?? ''}');
    final note = '${entry?['note'] ?? ''}';
    final colour = done ? AppColors.AppPrimaryColor : _line;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? colour : Colors.white,
                  border: Border.all(color: done ? colour : _line, width: 2),
                ),
                child: done
                    ? Icon(Icons.check, size: 11.sp, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2.w, color: done ? colour : _line),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    OrderTrackingController.label(stage),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                      color: done ? Colors.black87 : _muted,
                    ),
                  ),
                  // A time only where one was actually recorded. A step that
                  // has not happened shows nothing rather than a placeholder
                  // that looks like a schedule.
                  if (at != null) ...[
                    SizedBox(height: 2.h),
                    Text(DateFormat('d MMM, HH:mm').format(at.toLocal()),
                        style: TextStyle(fontSize: 10.5.sp, color: _muted)),
                  ],
                  if (note.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(note,
                        style: TextStyle(
                            fontSize: 11.sp, height: 1.35, color: Colors.black54)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordedStep(Map<String, dynamic> entry, {required bool isLast}) {
    final status = '${entry['status'] ?? ''}';
    final at = DateTime.tryParse('${entry['at'] ?? ''}');
    final note = '${entry['note'] ?? ''}';
    final colour = _statusColour(status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                decoration: BoxDecoration(shape: BoxShape.circle, color: colour),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2.w, color: _line)),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(OrderTrackingController.label(status),
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  if (at != null) ...[
                    SizedBox(height: 2.h),
                    Text(DateFormat('d MMM, HH:mm').format(at.toLocal()),
                        style: TextStyle(fontSize: 10.5.sp, color: _muted)),
                  ],
                  if (note.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(note,
                        style: TextStyle(
                            fontSize: 11.sp, height: 1.35, color: Colors.black54)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColour(String status) => switch (status) {
        'delivered' || 'picked_up' => const Color(0xFF10B981),
        'canceled' || 'cancelled' => const Color(0xFFDC2626),
        'refunded' || 'refund_requested' => const Color(0xFFD97706),
        'pending' => const Color(0xFFD97706),
        _ => AppColors.AppPrimaryColor,
      };

  IconData _statusIcon(String status) => switch (status) {
        'pending' => Icons.schedule_rounded,
        'confirmed' => Icons.thumb_up_alt_outlined,
        'processing' => Icons.restaurant_outlined,
        'ready' => Icons.inventory_2_outlined,
        'handover' => Icons.delivery_dining_rounded,
        'delivered' || 'picked_up' => Icons.check_circle_rounded,
        'canceled' || 'cancelled' => Icons.cancel_outlined,
        'refunded' || 'refund_requested' => Icons.assignment_return_outlined,
        _ => Icons.help_outline,
      };
}
