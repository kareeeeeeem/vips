import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';

/// The finished receipt.
///
/// Renders whatever it is handed — either the invoice returned by checkout or
/// one fetched from history — so there is a single receipt layout rather than
/// two that could drift apart.
class PosInvoiceView extends StatelessWidget {
  const PosInvoiceView({super.key});

  Map<String, dynamic> get _invoice {
    final args = Get.arguments;
    if (args is Map && args['invoice'] is Map) {
      return Map<String, dynamic>.from(args['invoice'] as Map);
    }
    return const {};
  }

  @override
  Widget build(BuildContext context) {
    final invoice = _invoice;

    if (invoice.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt')),
        body: AdminEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No receipt to show',
          message: 'Open a receipt from the till or from the history list.',
          action: AdminButton(label: 'Back', expand: false, onPressed: Get.back),
        ),
      );
    }

    final refunded = adminString(invoice['status']) == 'refunded';
    final items = invoice['items'] is List
        ? (invoice['items'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AdminColors.textPrimary),
          onPressed: Get.back,
        ),
        title: Text('Receipt',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          AdminCard(
            child: Column(
              children: [
                Icon(
                  refunded ? Icons.assignment_return_rounded : Icons.check_circle_rounded,
                  size: 40.sp,
                  color: refunded ? AdminColors.danger : AdminColors.success,
                ),
                SizedBox(height: 10.h),
                Text(
                  adminString(invoice['invoiceNumber'], '—'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  adminDateTimeLabel(adminDate(invoice['createdAt'])),
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
                ),
                SizedBox(height: 10.h),
                AdminStatusPill(
                  label: adminLabel(adminString(invoice['status'], 'completed')),
                  color: refunded ? AdminColors.danger : AdminColors.success,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminCard(
            title: 'Items (${items.length})',
            child: Column(
              children: [
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 34.w,
                          child: Text(
                            '${adminInt(item['quantity'], 1)}×',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.accent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            adminString(item['name'], 'Unnamed'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13.sp, color: AdminColors.textPrimary),
                          ),
                        ),
                        Text(
                          adminMoney(adminDouble(item['lineTotal'])),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminCard(
            title: 'Payment',
            child: Column(
              children: [
                AdminDetailRow(
                    label: 'Subtotal', value: adminMoney(adminDouble(invoice['subtotal']))),
                if (adminDouble(invoice['discount']) > 0)
                  AdminDetailRow(
                    label: 'Discount',
                    value: '− ${adminMoney(adminDouble(invoice['discount']))}',
                    valueColor: AdminColors.success,
                  ),
                if (adminDouble(invoice['tax']) > 0)
                  AdminDetailRow(label: 'Tax', value: adminMoney(adminDouble(invoice['tax']))),
                AdminDetailRow(
                  label: 'Total',
                  value: adminMoney(adminDouble(invoice['total'])),
                  valueColor: AdminColors.primary,
                ),
                AdminDetailRow(
                  label: 'Method',
                  value: adminLabel(adminString(invoice['paymentMethod'], 'cash')),
                ),
                AdminDetailRow(
                    label: 'Tendered', value: adminMoney(adminDouble(invoice['amountPaid']))),
                if (adminDouble(invoice['changeDue']) > 0)
                  AdminDetailRow(
                      label: 'Change', value: adminMoney(adminDouble(invoice['changeDue']))),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          AdminCard(
            title: 'Details',
            child: Column(
              children: [
                AdminDetailRow(
                    label: 'Customer',
                    value: adminString(invoice['customerName'], 'Walk-in')),
                AdminDetailRow(
                    label: 'Phone', value: adminString(invoice['customerPhone'])),
                AdminDetailRow(
                    label: 'Store', value: adminString(invoice['merchantName'])),
                AdminDetailRow(
                    label: 'Cashier', value: adminString(invoice['cashierName'])),
                AdminDetailRow(label: 'Note', value: adminString(invoice['note'])),
                if (refunded) ...[
                  AdminDetailRow(
                    label: 'Refunded',
                    value: adminDateTimeLabel(adminDate(invoice['refundedAt'])),
                    valueColor: AdminColors.danger,
                  ),
                  AdminDetailRow(
                    label: 'Reason',
                    value: adminString(invoice['refundReason']),
                    valueColor: AdminColors.danger,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),
          AdminButton(label: 'Done', onPressed: Get.back),
        ],
      ),
    );
  }
}
