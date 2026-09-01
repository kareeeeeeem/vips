import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/guarantees_controller.dart';

/// Merchant guarantees (§5.1, §5.2).
///
/// The money on this screen belongs to the merchants, not the platform. It is
/// refundable in full and §5.3 rules out earning anything on it, so it is
/// never shown beside or added into revenue.
class GuaranteesView extends GetView<GuaranteesController> {
  GuaranteesView({super.key});

  final TextEditingController _searchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Guarantees',
      route: AdminRoutes.GUARANTEES,
      onRefresh: controller.load,
      body: Obx(() {
        if (controller.isLoading.value && controller.merchants.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty && controller.merchants.isEmpty) {
          return AdminErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _totals(),
            SizedBox(height: 16.h),
            AdminSearchField(
              controller: _searchField,
              hint: 'Search merchants',
              onChanged: (v) => controller.search.value = v,
              onClear: () {
                _searchField.clear();
                controller.search.value = '';
              },
            ),
            SizedBox(height: 12.h),
            if (controller.visible.isEmpty)
              const AdminEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No merchants',
                message: 'Merchants appear here once they are on the platform.',
              )
            else
              ...controller.visible.map(_merchantCard),
          ],
        );
      }),
    );
  }

  Widget _totals() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Held on deposit',
                value: adminMoney(controller.totalHeldTnd.value),
                icon: Icons.savings_outlined,
                color: AdminColors.primary,
                // Said on the card itself: an operator reading a large number
                // should not have to be told separately that it is not income.
                sublabel: "Merchants' money, refundable in full",
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                label: 'Taken back out',
                value: adminMoney(controller.totalRefundedTnd.value),
                icon: Icons.undo_outlined,
                color: AdminColors.info,
                sublabel: 'Refunded to merchants to date',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'No guarantee yet',
                value: '${controller.withoutGuarantee.value}',
                icon: Icons.report_problem_outlined,
                color: controller.withoutGuarantee.value > 0
                    ? AdminColors.warning
                    : AdminColors.success,
                // The actionable half: these merchants cannot award a single
                // point until someone records a deposit for them.
                sublabel: 'Cannot award points until they deposit',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                label: 'Budget exhausted',
                value: '${controller.suspended.value}',
                icon: Icons.pause_circle_outline,
                color: controller.suspended.value > 0
                    ? AdminColors.danger
                    : AdminColors.success,
                sublabel: 'Stopped accepting points until topped up',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _merchantCard(Map<String, dynamic> m) {
    final budgets = Map<String, dynamic>.from(m['budgets'] as Map? ?? {});
    final held = adminDouble(m['heldTnd']);
    final suspended = m['suspended'] == true;
    final rate = m['earnRate'];

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${m['name'] ?? 'Unnamed merchant'}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ),
                AdminStatusPill(
                  label: suspended ? 'Suspended' : GuaranteesController
                      .planLabel('${m['plan'] ?? 'basic'}')
                      .split(' — ')
                      .first,
                  color: suspended ? AdminColors.danger : AdminColors.primary,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            AdminDetailRow(label: 'Held', value: adminMoney(held)),
            AdminDetailRow(
              label: 'Deposited to date',
              value: adminMoney(adminDouble(m['depositedTnd'])),
            ),
            AdminDetailRow(
              label: 'Points per dinar',
              // Null is not zero: a merchant who has not set a policy is a
              // different problem from one who set it to nothing.
              value: rate == null ? 'Not set' : '$rate',
            ),
            SizedBox(height: 8.h),
            _budgetBars(budgets),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    label: 'Record deposit',
                    icon: Icons.add_card_outlined,
                    onPressed: () => _depositSheet(m),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AdminButton(
                    label: 'Plan & rate',
                    icon: Icons.tune_outlined,
                    color: AdminColors.textSecondary,
                    onPressed: () => _planSheet(m),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetBars(Map<String, dynamic> budgets) {
    final entries = <MapEntry<String, String>>[
      const MapEntry('discount', 'Discount — funds cashback'),
      const MapEntry('packages', 'Packages'),
      const MapEntry('general', 'General — receives voucher spend'),
    ];
    final total = entries.fold<double>(
      0,
      (sum, e) => sum + adminDouble(budgets[e.key]),
    );

    return Column(
      children: entries.map((e) {
        final points = adminDouble(budgets[e.key]);
        return AdminBarRow(
          label: e.value,
          value: adminCount(points),
          // An empty budget reads as empty rather than as a hairline that
          // could be mistaken for a small balance.
          fraction: total <= 0 ? 0 : points / total,
          color: points <= 0 ? AdminColors.danger : AdminColors.primary,
        );
      }).toList(),
    );
  }

  void _depositSheet(Map<String, dynamic> m) {
    final amount = TextEditingController();
    final note = TextEditingController();

    Get.bottomSheet(
      _sheet(
        title: 'Record a guarantee deposit',
        // Says what the number means before it is typed: this is cash that
        // already arrived, not a credit being granted.
        blurb: 'Enter cash actually received from ${m['name']}. '
            'It converts at 100 points to the dinar and waits unallocated '
            'until the merchant splits it across their budgets.',
        children: [
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount received (TND)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: note,
            decoration: const InputDecoration(
              labelText: 'Reference (optional)',
              hintText: 'Bank transfer number, receipt…',
              prefixIcon: Icon(Icons.receipt_long_outlined),
            ),
          ),
          SizedBox(height: 18.h),
          Obx(() => AdminButton(
                label: 'Record deposit',
                isLoading: controller.isMutating.value,
                onPressed: controller.isMutating.value
                    ? null
                    : () async {
                        final value = double.tryParse(amount.text.trim()) ?? 0;
                        if (await controller.deposit(
                          '${m['merchantId']}',
                          value,
                          note: note.text.trim(),
                        )) {
                          Get.back<void>();
                        }
                      },
              )),
        ],
      ),
    );
  }

  void _planSheet(Map<String, dynamic> m) {
    final selected = RxString('${m['plan'] ?? 'basic'}');
    final rate = TextEditingController(
      text: m['earnRate'] == null ? '' : '${m['earnRate']}',
    );

    Get.bottomSheet(
      _sheet(
        title: '${m['name']}',
        blurb: 'The plan sets the commission the platform takes. '
            'The rate is how many points this merchant awards per dinar spent — '
            'those points come out of their own discount budget.',
        children: [
          Obx(() => Column(
                children: GuaranteesController.plans.map((p) {
                  return RadioListTile<String>(
                    value: p,
                    groupValue: selected.value,
                    onChanged: (v) => selected.value = v ?? p,
                    title: Text(
                      GuaranteesController.planLabel(p),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              )),
          SizedBox(height: 8.h),
          TextField(
            controller: rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Points per dinar',
              hintText: '6',
              prefixIcon: Icon(Icons.star_outline),
            ),
          ),
          SizedBox(height: 18.h),
          Obx(() => AdminButton(
                label: 'Save',
                isLoading: controller.isMutating.value,
                onPressed: controller.isMutating.value
                    ? null
                    : () async {
                        final parsed = double.tryParse(rate.text.trim());
                        if (await controller.setPlan(
                          '${m['merchantId']}',
                          plan: selected.value,
                          earnRate: parsed,
                        )) {
                          Get.back<void>();
                        }
                      },
              )),
        ],
      ),
    );
  }

  Widget _sheet({
    required String title,
    required String blurb,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              blurb,
              style: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
            ),
            SizedBox(height: 18.h),
            ...children,
          ],
        ),
      ),
    );
  }
}
