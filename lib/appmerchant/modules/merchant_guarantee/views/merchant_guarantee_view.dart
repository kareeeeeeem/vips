import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/merchant_guarantee_controller.dart';

/// The merchant's guarantee, its three budgets, and taking money back out.
class MerchantGuaranteeView extends GetView<MerchantGuaranteeController> {
  const MerchantGuaranteeView({super.key});

  static const _green = Color(0xFF10B981);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('My guarantee',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.depositedTnd.value == 0) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              if (controller.suspended.value) ...[_suspendedBanner(), SizedBox(height: 14.h)],
              _headline(),
              SizedBox(height: 16.h),
              if (controller.unallocated.value > 0) ...[
                _unallocated(),
                SizedBox(height: 16.h),
              ],
              _topUp(),
              SizedBox(height: 16.h),
              _budgets(),
              SizedBox(height: 16.h),
              _refund(),
              SizedBox(height: 16.h),
              _ledger(),
            ],
          ),
        );
      }),
    );
  }

  Widget _suspendedBanner() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(children: [
        Icon(Icons.pause_circle_outline, color: const Color(0xFFDC2626), size: 22.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'One of your budgets has run out, so points are not being awarded '
            'from it. Move points between budgets, or add to your guarantee.',
            style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF991B1B), height: 1.5),
          ),
        ),
      ]),
    );
  }

  Widget _headline() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Held for you',
              style: TextStyle(fontSize: 12.5.sp, color: _muted)),
          SizedBox(height: 4.h),
          Text('${controller.totalTnd.value.toStringAsFixed(3)} TND',
              style: TextStyle(
                  fontSize: 28.sp, fontWeight: FontWeight.w800, color: _ink)),
          SizedBox(height: 6.h),
          Text(
            // Stated because it is the thing merchants most need to trust:
            // this is not a fee and not spent — it is theirs, and comes back.
            'This is your money. It funds the points your offers give out, and '
            'you can ask for it back every ${controller.cycleDays.value} days.',
            style: TextStyle(fontSize: 12.5.sp, color: _muted, height: 1.55),
          ),
          SizedBox(height: 14.h),
          Row(children: [
            Expanded(child: _mini('Paid in',
                '${controller.depositedTnd.value.toStringAsFixed(3)} TND')),
            Expanded(child: _mini('Taken back',
                '${controller.refundedTnd.value.toStringAsFixed(3)} TND')),
          ]),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.5.sp, color: _muted)),
        SizedBox(height: 2.h),
        Text(value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _ink)),
      ],
    );
  }

  Widget _unallocated() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.inbox_outlined, color: _green, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text('${controller.unallocated.value} points to split',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
            ),
          ]),
          SizedBox(height: 6.h),
          Text(
            'These are not funding anything yet. Put them into a budget to '
            'start giving points out.',
            style: TextStyle(fontSize: 12.5.sp, color: _muted, height: 1.5),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: MerchantGuaranteeController.budgets.map((b) {
              return OutlinedButton(
                onPressed: () => _allocateSheet(b),
                child: Text('To ${MerchantGuaranteeController.budgetLabel(b)}',
                    style: TextStyle(fontSize: 12.sp)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _budgets() {
    final total = controller.discount.value +
        controller.packages.value +
        controller.general.value;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your budgets',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 12.h),
          ...MerchantGuaranteeController.budgets.map((b) {
            final points = controller.budgetValue(b);
            final empty = points <= 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(MerchantGuaranteeController.budgetLabel(b),
                          style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: empty ? const Color(0xFFDC2626) : _ink)),
                    ),
                    Text('$points pts',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: empty ? const Color(0xFFDC2626) : _green)),
                  ]),
                  SizedBox(height: 3.h),
                  Text(MerchantGuaranteeController.budgetBlurb(b),
                      style: TextStyle(fontSize: 11.5.sp, color: _muted)),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: total <= 0 ? 0 : points / total,
                      minHeight: 6.h,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation(
                          empty ? const Color(0xFFDC2626) : _green),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(
            height: 42.h,
            child: OutlinedButton.icon(
              onPressed: _moveSheet,
              icon: Icon(Icons.swap_horiz, size: 18.sp),
              label: Text('Move points between budgets',
                  style: TextStyle(fontSize: 12.5.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _refund() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Take money back',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 6.h),
          Text(
            'Up to ${controller.refundableTnd.value.toStringAsFixed(3)} TND, '
            'once every ${controller.cycleDays.value} days, '
            '${controller.minimumTnd.value.toStringAsFixed(0)} TND minimum. '
            'Reviewed within ${controller.reviewWorkingDays.value} working days.',
            style: TextStyle(fontSize: 12.5.sp, color: _muted, height: 1.55),
          ),
          // When it cannot be requested, the reason is shown rather than the
          // button silently doing nothing.
          if (!controller.canRequestRefund.value &&
              controller.refundBlockers.isNotEmpty) ...[
            SizedBox(height: 10.h),
            ...controller.refundBlockers.map((r) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline, size: 14.sp, color: const Color(0xFFD97706)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(r,
                          style: TextStyle(
                              fontSize: 11.5.sp, color: const Color(0xFF92400E))),
                    ),
                  ]),
                )),
          ],
          SizedBox(height: 12.h),
          SizedBox(
            height: 44.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.canRequestRefund.value ? _refundSheet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('Request a refund',
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ledger() {
    if (controller.ledger.isEmpty) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Every movement',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 4.h),
          Text('So you can check the balance above line by line.',
              style: TextStyle(fontSize: 11.5.sp, color: _muted)),
          SizedBox(height: 10.h),
          ...controller.ledger.take(20).map((e) {
            final points = (e['points'] as num?)?.toInt() ?? 0;
            final positive = points >= 0;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_movementLabel('${e['type']}'),
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w600, color: _ink)),
                      if (e['budget'] != null)
                        Text(
                            MerchantGuaranteeController.budgetLabel('${e['budget']}'),
                            style: TextStyle(fontSize: 11.sp, color: _muted)),
                    ],
                  ),
                ),
                Text('${positive ? '+' : ''}$points',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: positive ? _green : const Color(0xFFDC2626))),
              ]),
            );
          }),
        ],
      ),
    );
  }

  String _movementLabel(String type) => switch (type) {
        'deposit' => 'Guarantee paid in',
        'allocate' => 'Moved into a budget',
        'reallocate' => 'Moved between budgets',
        'fund' => 'Points given to a customer',
        'redeem' => 'Voucher spent in your shop',
        'refund' => 'Refunded to you',
        _ => type,
      };

  /// §5.1's two ways to put points behind offers. Deliberately kept apart:
  /// one is free and instant, the other is real money that has to arrive
  /// before it counts. Presenting them as one "top up" button would hide
  /// that difference.
  Widget _topUp() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add points',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 12.h),

          // Source one: what customers already spent here.
          InkWell(
            onTap: controller.recoverablePoints.value > 0 ? _moveSheet : null,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(children: [
                Icon(Icons.autorenew_rounded, color: _green, size: 20.sp),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reuse points customers spent here',
                          style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      SizedBox(height: 2.h),
                      Text(
                        controller.recoverablePoints.value > 0
                            ? '${controller.recoverablePoints.value} points sitting in your general balance. '
                                'Costs nothing — move them to whichever budget needs them.'
                            : 'Nothing here yet. Points land back when customers '
                                'spend vouchers in your shop.',
                        style: TextStyle(fontSize: 11.5.sp, color: _muted, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(height: 10.h),

          // Source two: money.
          InkWell(
            onTap: _bankSheet,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(13.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _line),
              ),
              child: Row(children: [
                Icon(Icons.account_balance_rounded,
                    color: const Color(0xFF1B6DF9), size: 20.sp),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Send a bank transfer',
                          style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: _ink)),
                      SizedBox(height: 2.h),
                      Text(
                        '100 points for every dinar. Points appear once the '
                        'transfer is confirmed as received.',
                        style: TextStyle(fontSize: 11.5.sp, color: _muted, height: 1.45),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          // Transfers declared but not yet confirmed, so the merchant is not
          // left wondering whether it went through.
          if (controller.pendingBankDeposits.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ...controller.pendingBankDeposits.map((d) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(children: [
                    Icon(Icons.hourglass_top_rounded,
                        size: 14.sp, color: const Color(0xFFD97706)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        '${d['amountTnd']} TND awaiting confirmation'
                        '${(d['reference'] ?? '').toString().isEmpty ? '' : ' · ref ${d['reference']}'}',
                        style: TextStyle(
                            fontSize: 11.5.sp, color: const Color(0xFF92400E)),
                      ),
                    ),
                  ]),
                )),
          ],
        ],
      ),
    );
  }

  void _bankSheet() {
    final amount = TextEditingController();
    final reference = TextEditingController();
    final bank = TextEditingController();

    Get.bottomSheet(_sheet(
      title: 'Send a bank transfer',
      blurb: 'Tell us what you sent and we will add the points once it lands. '
          'Every dinar becomes 100 points.',
      children: [
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount transferred (TND)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: bank,
          decoration: InputDecoration(
            labelText: 'Bank (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: reference,
          decoration: InputDecoration(
            labelText: 'Transfer reference (optional)',
            hintText: 'Helps us match it faster',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 16.h),
        _sheetButton('Send', () async {
          if (await controller.declareBankTransfer(
            double.tryParse(amount.text.trim()) ?? 0,
            reference: reference.text.trim(),
            bankName: bank.text.trim(),
          )) {
            Get.back<void>();
          }
        }),
      ],
    ));
  }

  void _allocateSheet(String budget) {
    final amount = TextEditingController();
    Get.bottomSheet(_sheet(
      title: 'Into ${MerchantGuaranteeController.budgetLabel(budget)}',
      blurb: MerchantGuaranteeController.budgetBlurb(budget),
      children: [
        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Points',
            hintText: '${controller.unallocated.value} available',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 16.h),
        _sheetButton('Move', () async {
          if (await controller.allocate(
              budget, int.tryParse(amount.text.trim()) ?? 0)) {
            Get.back<void>();
          }
        }),
      ],
    ));
  }

  void _moveSheet() {
    final from = RxString('discount');
    final to = RxString('general');
    final amount = TextEditingController();

    Get.bottomSheet(_sheet(
      title: 'Move points',
      blurb: 'Shift budget from one offer type to another without paying in more.',
      children: [
        Obx(() => Row(children: [
              Expanded(child: _budgetPicker('From', from)),
              SizedBox(width: 10.w),
              Expanded(child: _budgetPicker('To', to)),
            ])),
        SizedBox(height: 12.h),
        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Points',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 16.h),
        _sheetButton('Move', () async {
          if (await controller.reallocate(
              from.value, to.value, int.tryParse(amount.text.trim()) ?? 0)) {
            Get.back<void>();
          }
        }),
      ],
    ));
  }

  Widget _budgetPicker(String label, RxString selected) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected.value,
          isExpanded: true,
          items: MerchantGuaranteeController.budgets
              .map((b) => DropdownMenuItem(
                    value: b,
                    child: Text(
                      '${MerchantGuaranteeController.budgetLabel(b)} '
                      '(${controller.budgetValue(b)})',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ))
              .toList(),
          onChanged: (v) => selected.value = v ?? selected.value,
        ),
      ),
    );
  }

  void _refundSheet() {
    final amount = TextEditingController();
    final note = TextEditingController();
    Get.bottomSheet(_sheet(
      title: 'Request a refund',
      blurb: 'Up to ${controller.refundableTnd.value.toStringAsFixed(3)} TND. '
          'The points are held as soon as you ask, and the transfer is '
          'reviewed within ${controller.reviewWorkingDays.value} working days.',
      children: [
        TextField(
          controller: amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount (TND)',
            hintText: 'Minimum ${controller.minimumTnd.value.toStringAsFixed(0)}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: note,
          decoration: InputDecoration(
            labelText: 'Note (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 16.h),
        _sheetButton('Request', () async {
          if (await controller.requestRefund(
              double.tryParse(amount.text.trim()) ?? 0,
              note: note.text.trim())) {
            Get.back<void>();
          }
        }),
      ],
    ));
  }

  Widget _sheetButton(String label, Future<void> Function() onTap) {
    return Obx(() => SizedBox(
          height: 46.h,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isMutating.value ? null : () => onTap(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: controller.isMutating.value
                ? SizedBox(
                    width: 18.w, height: 18.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(label,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ),
        ));
  }

  Widget _sheet({
    required String title,
    required String blurb,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 17.sp, fontWeight: FontWeight.w700, color: _ink)),
            SizedBox(height: 6.h),
            Text(blurb,
                style: TextStyle(fontSize: 12.5.sp, color: _muted, height: 1.5)),
            SizedBox(height: 18.h),
            ...children,
          ],
        ),
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
