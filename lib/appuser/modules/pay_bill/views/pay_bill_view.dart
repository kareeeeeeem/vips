import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/pay_bill_controller.dart';

/// Paying with points: what the shop is charging, what it costs in points,
/// and one confirmation.
class PayBillView extends GetView<PayBillController> {
  const PayBillView({super.key});

  static const _navy = Color(0xFF00205C);
  static const _green = Color(0xFF10B981);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Pay with points',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.receipt.value != null) return _receipt();
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _codeEntry(),
            if (controller.error.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _errorBox(controller.error.value),
            ],
            if (controller.bill.value != null) ...[
              SizedBox(height: 16.h),
              _billCard(),
            ],
          ],
        );
      }),
    );
  }

  Widget _codeEntry() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The shop will show you a code',
              style: TextStyle(
                  fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 4.h),
          Text('Scan it, or type it here if the camera will not read it.',
              style: TextStyle(fontSize: 12.5.sp, color: _muted, height: 1.5)),
          SizedBox(height: 14.h),
          TextField(
            controller: controller.codeController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'VB-XXXXXXXX',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 46.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => controller.lookup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Look up the bill',
                      style:
                          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billCard() {
    final items = (controller.bill.value?['items'] as List?) ?? [];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(controller.merchantName,
              style: TextStyle(
                  fontSize: 17.sp, fontWeight: FontWeight.w800, color: _ink)),
          if ('${controller.bill.value?['merchant']?['category'] ?? ''}'.isNotEmpty)
            Text('${controller.bill.value?['merchant']['category']}',
                style: TextStyle(fontSize: 12.sp, color: _muted)),
          SizedBox(height: 14.h),
          ...items.map((raw) {
            final i = Map<String, dynamic>.from(raw as Map);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Row(children: [
                Expanded(
                  child: Text('${i['quantity']}× ${i['name']}',
                      style: TextStyle(fontSize: 13.sp, color: _muted)),
                ),
                Text('D ${i['total']}',
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ink)),
              ]),
            );
          }),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: _line),
          ),
          Row(children: [
            Expanded(
              child: Text('To pay',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
            ),
            Text('D ${controller.dueTnd.toStringAsFixed(3)}',
                style: TextStyle(
                    fontSize: 19.sp, fontWeight: FontWeight.w800, color: _ink)),
          ]),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(13.w),
            decoration: BoxDecoration(
              color: controller.canPay
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: Text('Costs you',
                      style: TextStyle(fontSize: 13.sp, color: _muted)),
                ),
                Text('${controller.pointsNeeded} points',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: controller.canPay
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B))),
              ]),
              SizedBox(height: 5.h),
              Row(children: [
                Expanded(
                  child: Text('You have',
                      style: TextStyle(fontSize: 13.sp, color: _muted)),
                ),
                Text('${controller.yourPoints} points',
                    style: TextStyle(fontSize: 13.sp, color: _ink)),
              ]),
              // Says how far short rather than just refusing, so the customer
              // knows whether to pay the difference in cash.
              if (!controller.canPay) ...[
                SizedBox(height: 7.h),
                Text(
                  'You are ${controller.shortBy} points short. '
                  'Pay this one another way and keep the points for next time.',
                  style: TextStyle(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF991B1B),
                      height: 1.5),
                ),
              ],
            ]),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 50.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !controller.canPay || controller.isPaying.value
                  ? null
                  : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r)),
              ),
              child: controller.isPaying.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Pay ${controller.pointsNeeded} points',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirm() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Pay with your points?'),
        content: Text(
          '${controller.pointsNeeded} points to settle '
          'D ${controller.dueTnd.toStringAsFixed(3)} at ${controller.merchantName}. '
          'This cannot be undone.',
          style: TextStyle(fontSize: 13.5.sp, height: 1.55),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back<void>();
              await controller.pay();
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  Widget _receipt() {
    final r = controller.receipt.value!;
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        SizedBox(height: 30.h),
        Icon(Icons.check_circle_rounded, size: 66.sp, color: _green),
        SizedBox(height: 14.h),
        Center(
          child: Text('Paid',
              style: TextStyle(
                  fontSize: 24.sp, fontWeight: FontWeight.w800, color: _ink)),
        ),
        SizedBox(height: 6.h),
        Center(
          child: Text('${r['pointsSpent']} points at ${r['merchant']}',
              style: TextStyle(fontSize: 13.5.sp, color: _muted)),
        ),
        SizedBox(height: 24.h),
        _card(
          child: Column(children: [
            _row('Bill', '${r['billNumber']}'),
            _row('Amount', 'D ${r['paidTnd']}'),
            _row('Points spent', '${r['pointsSpent']}'),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Divider(height: 1, color: _line),
            ),
            _row('Points left', '${r['remainingPoints']}'),
            _row('Worth', 'D ${r['remainingValueTnd']}'),
          ]),
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: () => Get.back<void>(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r)),
            ),
            child: Text('Done',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 13.sp, color: _muted))),
          Text(value,
              style: TextStyle(
                  fontSize: 13.sp, fontWeight: FontWeight.w700, color: _ink)),
        ]),
      );

  Widget _errorBox(String message) => Container(
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Text(message,
            style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF991B1B))),
      );

  Widget _card({required Widget child}) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _line),
        ),
        child: child,
      );
}
