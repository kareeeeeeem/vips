import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/reward_action_controller.dart';

/// Targeted offers (§6.2), laid out the way the merchant works: who is out
/// there, then what to send them, then what has gone out.
class RewardActionView extends GetView<RewardActionController> {
  const RewardActionView({super.key});

  static const _green = Color(0xFF10B981);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Reward Action',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.segments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _reach(),
              SizedBox(height: 18.h),
              Text('Who you can reach',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
              SizedBox(height: 4.h),
              Text(
                'Groups are worked out from what customers actually did, and '
                'change as they do.',
                style: TextStyle(fontSize: 11.5.sp, color: _muted, height: 1.45),
              ),
              SizedBox(height: 12.h),
              ...controller.segments.map(_segmentCard),
              SizedBox(height: 20.h),
              _history(),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  /// Customers reached, not offers created — an offer nobody received is not
  /// something to count.
  Widget _reach() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _reachItem('Today', controller.reachedToday.value),
          _reachDivider(),
          _reachItem('This week', controller.reachedWeek.value),
          _reachDivider(),
          _reachItem('This month', controller.reachedMonth.value),
        ],
      ),
    );
  }

  Widget _reachItem(String label, int value) => Expanded(
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
          ],
        ),
      );

  Widget _reachDivider() =>
      Container(width: 1, height: 30.h, color: Colors.white24);

  Widget _segmentCard(Map<String, dynamic> segment) {
    final key = '${segment['key']}';
    final count = (segment['customers'] as num?)?.toInt() ?? 0;
    final spend = (segment['spend'] as num?)?.toDouble() ?? 0;
    final empty = count == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${segment['label']}',
                      style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: empty
                        ? const Color(0xFFF3F4F6)
                        : _green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: empty ? _muted : _green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text('${segment['blurb']}',
                style: TextStyle(fontSize: 11.5.sp, color: _muted, height: 1.45)),
            if (!empty) ...[
              SizedBox(height: 4.h),
              Text('They have spent D ${spend.toStringAsFixed(3)} with you.',
                  style: TextStyle(fontSize: 11.sp, color: _muted)),
            ],
            SizedBox(height: 10.h),
            SizedBox(
              height: 38.h,
              width: double.infinity,
              child: OutlinedButton.icon(
                // Nothing to send to an empty group, and offering the button
                // anyway would only produce a refusal.
                onPressed: empty ? null : () => _composeSheet(key, segment),
                icon: Icon(Icons.campaign_outlined, size: 17.sp),
                label: Text(
                  empty ? 'Nobody here yet' : 'Write an offer for them',
                  style: TextStyle(fontSize: 12.5.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _history() {
    final items = controller.visibleActions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your offers',
            style: TextStyle(
                fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
        SizedBox(height: 10.h),
        if (items.isEmpty)
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: _line),
            ),
            child: Column(children: [
              Icon(Icons.campaign_outlined, size: 34.sp, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 8.h),
              Text('Nothing sent yet',
                  style: TextStyle(
                      fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: _ink)),
              SizedBox(height: 3.h),
              Text('Pick a group above and write them something.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5.sp, color: _muted)),
            ]),
          )
        else
          ...items.map(_actionCard),
      ],
    );
  }

  Widget _actionCard(Map<String, dynamic> action) {
    final sent = action['status'] == 'sent';
    final id = '${action['id'] ?? action['_id']}';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${action['segmentLabel'] ?? action['segment']} · '
                    '${RewardActionController.discountLabel(action)}',
                    style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: _ink),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: sent
                        ? _green.withValues(alpha: 0.12)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    sent ? 'Sent to ${action['reached'] ?? 0}' : 'Draft',
                    style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: sent ? _green : const Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text('${action['message'] ?? ''}',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 12.5.sp, color: _muted, height: 1.6)),
            if (sent && '${action['couponCode'] ?? ''}'.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text('Code ${action['couponCode']}',
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B82F6))),
            ],
            // A sent offer is in customers' hands and cannot be rewritten;
            // the controls say so by being absent rather than by failing.
            if (!sent) ...[
              SizedBox(height: 10.h),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editSheet(action),
                    child: Text('Edit', style: TextStyle(fontSize: 12.5.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: controller.isMutating.value
                            ? null
                            : () => _confirmSend(id, action),
                        child: Text('Send', style: TextStyle(fontSize: 12.5.sp)),
                      )),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmSend(String id, Map<String, dynamic> action) {
    final key = '${action['segment']}';
    final count = controller.customersIn(key);
    Get.dialog(
      AlertDialog(
        title: const Text('Send this offer?'),
        content: Text(
          'It goes to the $count customer(s) in this group right now, and '
          'stays open for ${action['availabilityDays'] ?? 7} days. '
          'Once sent it cannot be changed.',
          style: TextStyle(fontSize: 13.sp, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Not yet')),
          TextButton(
            onPressed: () async {
              Get.back<void>();
              await controller.sendAction(id);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _composeSheet(String segmentKey, Map<String, dynamic> segment) {
    final unit = 'percent'.obs;
    final value = TextEditingController(text: '15');
    final maxDiscount = TextEditingController();
    final days = TextEditingController(text: '7');
    final message = TextEditingController();

    Get.bottomSheet(
      _sheet(
        title: '${segment['label']}',
        blurb: '${segment['customers']} customer(s). Leave the message empty '
            'and one will be written for you.',
        children: [
          Obx(() => Row(children: [
                Expanded(child: _unitChip('percent', '%', unit)),
                SizedBox(width: 8.w),
                Expanded(child: _unitChip('tnd', 'Dinars', unit)),
              ])),
          SizedBox(height: 12.h),
          Obx(() => TextField(
                controller: value,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: unit.value == 'tnd' ? 'Amount off (TND)' : 'Discount (%)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              )),
          SizedBox(height: 12.h),
          Obx(() => unit.value == 'percent'
              ? TextField(
                  controller: maxDiscount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Most it can take off (TND, optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                )
              : const SizedBox.shrink()),
          SizedBox(height: 12.h),
          TextField(
            controller: days,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Open for (days)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: message,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'Message (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 16.h),
          _sheetButton('Save as draft', () async {
            final parsed = double.tryParse(value.text.trim()) ?? 0;
            if (await controller.createAction(
              segment: segmentKey,
              discountType: unit.value,
              discountValue: parsed,
              maxDiscountTnd: double.tryParse(maxDiscount.text.trim()),
              availabilityDays: int.tryParse(days.text.trim()) ?? 7,
              message: message.text,
            )) {
              Get.back<void>();
            }
          }),
        ],
      ),
    );
  }

  void _editSheet(Map<String, dynamic> action) {
    final id = '${action['id'] ?? action['_id']}';
    final value = TextEditingController(text: '${action['discountValue'] ?? ''}');
    final days = TextEditingController(text: '${action['availabilityDays'] ?? 7}');
    final message = TextEditingController(text: '${action['message'] ?? ''}');

    Get.bottomSheet(
      _sheet(
        title: 'Edit draft',
        blurb: 'Nothing has gone out yet, so this can still change.',
        children: [
          TextField(
            controller: value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: action['discountType'] == 'tnd'
                  ? 'Amount off (TND)'
                  : 'Discount (%)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: days,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Open for (days)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: message,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 16.h),
          _sheetButton('Save', () async {
            if (await controller.updateAction(id, {
              'discountValue': double.tryParse(value.text.trim()) ?? 0,
              'availabilityDays': int.tryParse(days.text.trim()) ?? 7,
              'message': message.text.trim(),
            })) {
              Get.back<void>();
            }
          }),
        ],
      ),
    );
  }

  Widget _unitChip(String key, String label, RxString selected) {
    final active = selected.value == key;
    return GestureDetector(
      onTap: () => selected.value = key,
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _green.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: active ? _green : _line),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: active ? _green : _muted)),
      ),
    );
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
                    width: 18.w,
                    height: 18.w,
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
      constraints: BoxConstraints(maxHeight: 640.h),
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
}
