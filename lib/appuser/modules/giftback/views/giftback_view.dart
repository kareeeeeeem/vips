import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/giftback_controller.dart';

/// Giftback: change the customer chose to keep as points (§6.1).
class GiftbackView extends GetView<GiftbackController> {
  const GiftbackView({super.key});

  static const _navy = Color(0xFF00205C);
  static const _orange = Color(0xFFFA6B25);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Giftback',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.grants.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _explainer(),
              SizedBox(height: 14.h),
              if (controller.pendingPoints.value > 0) ...[
                _pending(),
                SizedBox(height: 14.h),
              ],
              _allowance(),
              SizedBox(height: 14.h),
              _history(),
            ],
          ),
        );
      }),
    );
  }

  Widget _explainer() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.savings_outlined, color: _orange, size: 20.sp),
            SizedBox(width: 8.w),
            Text('What Giftback is',
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          ]),
          SizedBox(height: 8.h),
          Text(
            'When your change is under ${controller.maxChangeTnd.value.toStringAsFixed(0)} dinars, '
            'the shop can ask if you would rather have it as points. It is always '
            'your choice, and the points arrive '
            '${controller.activationDelayHours.value} hours later.',
            style: TextStyle(fontSize: 13.sp, color: _muted, height: 1.6),
          ),
        ],
      ),
    );
  }

  /// Points already granted but not yet spendable. Shown as its own figure so
  /// it is never mistaken for balance the customer can use today.
  Widget _pending() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('On the way',
              style: TextStyle(fontSize: 12.5.sp, color: Colors.white70)),
          SizedBox(height: 4.h),
          Text('${controller.pendingPoints.value} points',
              style: TextStyle(
                  fontSize: 26.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          SizedBox(height: 4.h),
          Text(
            'Worth ${controller.pendingTnd.value.toStringAsFixed(3)} TND. '
            'Not in your balance yet.',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _allowance() {
    final full = controller.remainingTnd.value <= 0;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This month',
              style: TextStyle(
                  fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: LinearProgressIndicator(
              value: controller.usedFraction,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor:
                  AlwaysStoppedAnimation(full ? const Color(0xFFDC2626) : _orange),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            full
                ? 'You have used your full ${controller.capTnd.value.toStringAsFixed(0)} TND '
                    'for this month. It resets at the start of next month.'
                : '${controller.usedTnd.value.toStringAsFixed(3)} of '
                    '${controller.capTnd.value.toStringAsFixed(0)} TND used — '
                    '${controller.remainingTnd.value.toStringAsFixed(3)} TND left.',
            style: TextStyle(
                fontSize: 12.5.sp,
                color: full ? const Color(0xFF991B1B) : _muted,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    if (controller.grants.isEmpty) {
      return _card(
        child: Column(children: [
          Icon(Icons.savings_outlined, size: 40.sp, color: const Color(0xFFD1D5DB)),
          SizedBox(height: 10.h),
          Text('No Giftback yet',
              style: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 4.h),
          Text('Next time your change is small, the shop may offer it as points.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5.sp, color: _muted)),
        ]),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Giftback',
              style: TextStyle(
                  fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 8.h),
          ...controller.grants.map((g) {
            final pending = g['status'] == 'pending';
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(children: [
                Container(
                  width: 34.w, height: 34.w,
                  decoration: BoxDecoration(
                    color: pending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(
                    pending ? Icons.hourglass_top_rounded : Icons.check_rounded,
                    size: 17.sp,
                    color: pending ? const Color(0xFFD97706) : const Color(0xFF059669),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${g['changeTnd']} TND change',
                          style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: _ink)),
                      Text(
                        pending
                            ? 'Available ${controller.countdown(g).toLowerCase()}'
                            : 'In your balance',
                        style: TextStyle(fontSize: 11.5.sp, color: _muted),
                      ),
                    ],
                  ),
                ),
                Text('+${g['points']}',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: pending ? const Color(0xFFD97706) : const Color(0xFF059669))),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }
}
