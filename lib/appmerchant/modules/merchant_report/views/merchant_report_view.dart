import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/merchant_report_controller.dart';

/// The shop's position in one screen.
class MerchantReportView extends GetView<MerchantReportController> {
  const MerchantReportView({super.key});

  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF6B7280);
  static const _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Report',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.totalSales.value == 0) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _periodPicker(),
              SizedBox(height: 16.h),
              _section('Sales', [
                _tile('Total sales', MerchantReportController.money(controller.totalSales.value),
                    const Color(0xFFD1FAE5), const Color(0xFF065F46)),
                _tile('Purchases', MerchantReportController.money(controller.purchases.value),
                    const Color(0xFFE0E7FF), const Color(0xFF3730A3)),
              ]),
              SizedBox(height: 6.h),
              // Online and counter sales add to the total above; shown so a
              // merchant can see which half of the shop is moving.
              _subLine('Through the app', MerchantReportController.money(controller.onlineSales.value)),
              _subLine(
                'At the counter',
                '${MerchantReportController.money(controller.counterSales.value)}'
                ' · ${controller.counterInvoices.value} receipts',
              ),
              SizedBox(height: 18.h),
              _section('Owed', [
                _tile(
                  'Customers owe you',
                  MerchantReportController.money(controller.dueFromCustomers.value),
                  const Color(0xFFEDE9FE),
                  const Color(0xFF5B21B6),
                  note: '${controller.customerParties.value} accounts',
                ),
                _tile(
                  'You owe suppliers',
                  MerchantReportController.money(controller.dueToSuppliers.value),
                  const Color(0xFFFEE2E2),
                  const Color(0xFF991B1B),
                  note: '${controller.supplierParties.value} accounts',
                ),
              ]),
              SizedBox(height: 6.h),
              // The two above pull opposite ways, so the difference is the
              // only figure that says whether the shop is up or down on
              // credit — adding them would be meaningless.
              _subLine(
                'Net position',
                MerchantReportController.money(
                    controller.dueFromCustomers.value - controller.dueToSuppliers.value),
              ),
              SizedBox(height: 18.h),
              _section('Catalogue', [
                _tile('Items', '${controller.items.value}',
                    const Color(0xFFD1FAE5), const Color(0xFF065F46)),
                _tile('Categories', '${controller.categories.value}',
                    const Color(0xFFFEF3C7), const Color(0xFF92400E)),
              ]),
              SizedBox(height: 18.h),
              _section('Stock', [
                _tile('Stock value', MerchantReportController.money(controller.stockValue.value),
                    const Color(0xFFCCFBF1), const Color(0xFF115E59)),
                _tile('Units on hand', '${controller.stockUnits.value}',
                    const Color(0xFFCCFBF1), const Color(0xFF115E59),
                    note: '${controller.stockLines.value} lines'),
              ]),
              if (controller.error.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(controller.error.value,
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFFDC2626))),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _periodPicker() {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MerchantReportController.periods.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final key = MerchantReportController.periods[i];
          final selected = controller.period.value == key;
          return GestureDetector(
            onTap: () => controller.setPeriod(key),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF10B981) : Colors.white,
                borderRadius: BorderRadius.circular(17.r),
                border: Border.all(color: selected ? const Color(0xFF10B981) : _line),
              ),
              child: Text(
                MerchantReportController.periodLabel(key),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 15.sp, fontWeight: FontWeight.w700, color: _ink)),
        SizedBox(height: 10.h),
        Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: 10.w),
              Expanded(child: tiles[i]),
            ],
          ],
        ),
      ],
    );
  }

  Widget _tile(String label, String value, Color bg, Color fg, {String? note}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 17.sp, fontWeight: FontWeight.w800, color: fg)),
          SizedBox(height: 3.h),
          Text(label, style: TextStyle(fontSize: 11.5.sp, color: fg.withValues(alpha: 0.8))),
          if (note != null) ...[
            SizedBox(height: 2.h),
            Text(note, style: TextStyle(fontSize: 10.5.sp, color: fg.withValues(alpha: 0.6))),
          ],
        ],
      ),
    );
  }

  Widget _subLine(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp, color: _muted))),
          Text(value,
              style: TextStyle(
                  fontSize: 12.sp, fontWeight: FontWeight.w700, color: _ink)),
        ],
      ),
    );
  }
}
