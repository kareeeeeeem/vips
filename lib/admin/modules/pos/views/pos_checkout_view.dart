import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../controllers/pos_controller.dart';

/// Take payment. Pops with the created invoice so the caller can show it.
class PosCheckoutView extends GetView<PosController> {
  const PosCheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final method = 'cash'.obs;
    final tendered = TextEditingController();
    final note = TextEditingController();

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
        title: Text('Payment',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary)),
      ),
      body: Obx(() {
        final total = controller.total;
        final paid = double.tryParse(tendered.text.trim()) ?? 0;
        final isCash = method.value == 'cash';
        final change = paid - total;

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            AdminCard(
              child: Column(
                children: [
                  Text('Amount due',
                      style: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary)),
                  SizedBox(height: 6.h),
                  Text(
                    adminMoney(total),
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${controller.itemCount} item(s)'
                    '${controller.customerName.value.isEmpty ? '' : ' · ${controller.customerName.value}'}',
                    style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AdminCard(
              title: 'How is it being paid?',
              child: AdminFilterChips(
                options: const [
                  AdminFilterOption('cash', 'Cash'),
                  AdminFilterOption('card', 'Card'),
                  AdminFilterOption('wallet', 'Wallet'),
                ],
                selected: method.value,
                onSelected: (value) => method.value = value,
              ),
            ),
            SizedBox(height: 14.h),
            if (isCash)
              AdminCard(
                title: 'Cash tendered',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: tendered,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      // Rebuild so the change line updates as they type.
                      onChanged: (_) => method.refresh(),
                      style: TextStyle(fontSize: 18.sp, color: AdminColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: adminMoney(total),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: AdminColors.border),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    // Quick denominations save the cashier typing the common
                    // cases; the exact-amount button is the most used of all.
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _quick(tendered, method, total, 'Exact'),
                        for (final note in [5, 10, 20, 50, 100])
                          if (note >= total) _quick(tendered, method, note, 'D $note'),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Text('Change due',
                            style: TextStyle(
                                fontSize: 13.sp, color: AdminColors.textSecondary)),
                        const Spacer(),
                        Text(
                          change >= 0 ? adminMoney(change) : 'Short ${adminMoney(-change)}',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: change >= 0 ? AdminColors.success : AdminColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 14.h),
            AdminCard(
              title: 'Note (optional)',
              child: TextField(
                controller: note,
                style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Anything to record on the receipt',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AdminColors.border),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            AdminButton(
              label: 'Complete sale',
              icon: Icons.check_circle_outline_rounded,
              isLoading: controller.isBusy.value,
              onPressed: () async {
                final amount = isCash ? paid : total;
                if (isCash && amount < total) {
                  return adminToast('Not enough cash',
                      'Tendered ${adminMoney(amount)} against ${adminMoney(total)}.',
                      isError: true);
                }
                final invoice = await controller.checkout(
                  paymentMethod: method.value,
                  amountPaid: amount,
                  note: note.text.trim(),
                );
                if (invoice != null) Get.back(result: invoice);
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _quick(TextEditingController field, RxString method, num value, String label) {
    return OutlinedButton(
      onPressed: () {
        field.text = value.toStringAsFixed(3);
        method.refresh();
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AdminColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12.sp, color: AdminColors.primary)),
    );
  }
}
