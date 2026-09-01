import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/merchant_earn_controller.dart';

/// Recording a sale (§4.1).
///
/// Three steps in the order they happen at the counter: who the customer is,
/// what the invoice came to, and — only if there is change — whether they
/// want it as points.
class MerchantEarnView extends GetView<MerchantEarnController> {
  const MerchantEarnView({super.key});

  static const _green = Color(0xFF10B981);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Add points', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (!controller.rateLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            if ((controller.earnRate.value ?? 0) <= 0) _noRate(),
            if ((controller.earnRate.value ?? 0) > 0) ...[
              _budgetBanner(),
              SizedBox(height: 16.h),
              _customerStep(),
              SizedBox(height: 16.h),
              _invoiceStep(),
              SizedBox(height: 16.h),
              _giftbackStep(),
              SizedBox(height: 20.h),
              if (controller.error.isNotEmpty) ...[
                _errorBox(controller.error.value),
                SizedBox(height: 12.h),
              ],
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: controller.canSubmit ? () => controller.submit() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          width: 20.w, height: 20.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          controller.pointsPreview > 0
                              ? 'Add ${controller.pointsPreview} points'
                              : 'Add points',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  /// A merchant with no rate cannot award anything, so the screen says so
  /// instead of presenting a form that will always fail.
  Widget _noRate() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.percent_rounded, color: const Color(0xFFF59E0B), size: 20.sp),
            SizedBox(width: 8.w),
            Text('No points rate set',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          ]),
          SizedBox(height: 8.h),
          Text(
            'Decide how many points each dinar earns your customers, then come '
            'back. The platform team sets this with you — most shops start at 6 '
            'points per dinar, which gives the customer 6% back.',
            style: TextStyle(fontSize: 13.sp, color: _muted, height: 1.6),
          ),
        ],
      ),
    );
  }

  /// The budget these points come out of. Shown before the sale, because a
  /// customer told they earned points that were then refused is worse than a
  /// merchant told in advance.
  Widget _budgetBanner() {
    final short = controller.discountBudget.value < controller.pointsPreview;
    final empty = controller.discountBudget.value <= 0;
    if (!short && !empty) {
      return Row(children: [
        Icon(Icons.savings_outlined, size: 16.sp, color: _muted),
        SizedBox(width: 6.w),
        Text(
          '${controller.discountBudget.value} points left in your discount budget',
          style: TextStyle(fontSize: 12.sp, color: _muted),
        ),
      ]);
    }
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(children: [
        Icon(Icons.error_outline, color: const Color(0xFFDC2626), size: 20.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            empty
                ? 'Your discount budget is empty. Top up your guarantee or move '
                    'points from another budget before recording a sale.'
                : 'This sale needs ${controller.pointsPreview} points and your '
                    'discount budget holds ${controller.discountBudget.value}.',
            style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF991B1B), height: 1.5),
          ),
        ),
      ]),
    );
  }

  Widget _customerStep() {
    final found = controller.customerId.isNotEmpty;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('1', 'Who is the customer?'),
          SizedBox(height: 12.h),
          if (found)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(children: [
                Icon(Icons.check_circle, color: _green, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(controller.customerName.value,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w700, color: _ink)),
                ),
                TextButton(
                  onPressed: controller.reset,
                  child: Text('Change', style: TextStyle(fontSize: 12.sp)),
                ),
              ]),
            )
          else ...[
            TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone number',
                hintText: 'Or scan their VIPs QR code',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 44.h,
              child: OutlinedButton.icon(
                onPressed:
                    controller.isLookingUp.value ? null : () => controller.lookup(),
                icon: controller.isLookingUp.value
                    ? SizedBox(
                        width: 14.w, height: 14.w,
                        child: const CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.search, size: 18.sp),
                label: Text('Find customer', style: TextStyle(fontSize: 13.sp)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _invoiceStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('2', 'What did they pay?'),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.invoiceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Invoice total (TND)',
              prefixIcon: const Icon(Icons.receipt_long_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          if (controller.pointsPreview > 0) ...[
            SizedBox(height: 10.h),
            Text(
              'Earns ${controller.pointsPreview} points '
              'at ${controller.earnRate.value} per dinar',
              style: TextStyle(fontSize: 12.5.sp, color: _green, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _giftbackStep() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('3', 'Any change?'),
          SizedBox(height: 4.h),
          Text(
            'Optional. If the customer would rather have their change as '
            'points, ask them — it has to be their choice.',
            style: TextStyle(fontSize: 12.sp, color: _muted, height: 1.5),
          ),
          SwitchListTile(
            value: controller.offerGiftback.value,
            onChanged: (v) => controller.offerGiftback.value = v,
            activeThumbColor: _green,
            contentPadding: EdgeInsets.zero,
            title: Text('Offer Giftback',
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600)),
          ),
          if (controller.offerGiftback.value) ...[
            TextField(
              controller: controller.changeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Change (TND)',
                hintText: 'Under ${controller.maxChangeTnd.value}',
                prefixIcon: const Icon(Icons.savings_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            if (controller.allowanceKnown.value) ...[
              SizedBox(height: 8.h),
              Text(
                // Their allowance, not this shop's: it follows the customer
                // across every VIPs merchant they visit.
                '${controller.remainingAllowanceTnd.value.toStringAsFixed(3)} TND '
                'left of this customer\'s monthly allowance',
                style: TextStyle(fontSize: 11.5.sp, color: _muted),
              ),
            ],
            if (controller.giftbackPointsPreview > 0) ...[
              SizedBox(height: 6.h),
              Text(
                '${controller.giftbackPointsPreview} points, spendable in '
                '${controller.activationDelayHours.value} hours',
                style: TextStyle(fontSize: 12.sp, color: _green, fontWeight: FontWeight.w600),
              ),
            ],
            CheckboxListTile(
              value: controller.giftbackConsent.value,
              onChanged: (v) => controller.giftbackConsent.value = v ?? false,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: _green,
              title: Text(
                'The customer agreed to give up their change',
                style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepTitle(String number, String label) {
    return Row(children: [
      Container(
        width: 22.w, height: 22.w,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
        child: Text(number,
            style: TextStyle(
                fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
      SizedBox(width: 10.w),
      Text(label,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
    ]);
  }

  Widget _errorBox(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(message,
          style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF991B1B))),
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
