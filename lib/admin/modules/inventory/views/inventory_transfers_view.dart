import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/inventory_transfers_controller.dart';
import '../widgets/inventory_tabs.dart';

/// Move units between warehouses. Both halves of the transfer land in the
/// stock ledger under one reference, which the panel below shows.
class InventoryTransfersView extends GetView<InventoryTransfersController> {
  const InventoryTransfersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Stock Transfers',
      route: AdminRoutes.INVENTORY,
      onRefresh: controller.load,
      body: Column(
        children: [
          const InventoryTabs(current: AdminRoutes.INVENTORY_TRANSFERS),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.sources.isEmpty) {
                return const AdminLoading();
              }
              if (controller.sources.isEmpty) {
                return AdminEmptyState(
                  icon: Icons.compare_arrows_rounded,
                  title: 'Nothing to transfer',
                  message: controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Stock lines appear here once merchants add them.',
                  action: AdminButton(
                    label: 'Reload',
                    expand: false,
                    onPressed: controller.load,
                  ),
                );
              }

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                children: [
                  _buildSourceCard(),
                  SizedBox(height: 14.h),
                  _buildDestinationCard(),
                  SizedBox(height: 14.h),
                  _buildQuantityCard(),
                  SizedBox(height: 14.h),
                  _buildSubmit(),
                  SizedBox(height: 20.h),
                  _buildRecent(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Source ────────────────────────────────────────────────

  Widget _buildSourceCard() {
    return Obx(() {
      final source = controller.selectedSource.value;
      return AdminCard(
        title: 'From',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickSource,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 18.sp, color: AdminColors.primary),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: source == null
                          ? Text(
                              'Choose a stock line',
                              style: TextStyle(
                                  fontSize: 14.sp, color: AdminColors.textMuted),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  adminString(source['name'], 'Unnamed'),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${adminString(source['merchantName'], 'Unknown store')} · '
                                  '${adminString(source['location'], 'Main')} · '
                                  '${adminCount(adminInt(source['currentStock']))} on hand',
                                  style: TextStyle(
                                      fontSize: 11.sp, color: AdminColors.textMuted),
                                ),
                              ],
                            ),
                    ),
                    Icon(Icons.expand_more_rounded,
                        size: 20.sp, color: AdminColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _pickSource() {
    adminSheet(
      title: 'Choose a stock line',
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final stock in controller.sources)
                InkWell(
                  onTap: () {
                    controller.selectSource(stock);
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminString(stock['name'], 'Unnamed'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${adminString(stock['merchantName'], 'Unknown store')} · '
                                '${adminString(stock['location'], 'Main')}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11.sp, color: AdminColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        AdminStatusPill(
                          label: '${adminCount(adminInt(stock['currentStock']))} on hand',
                          color: adminInt(stock['currentStock']) == 0
                              ? AdminColors.danger
                              : AdminColors.info,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  // ── Destination ───────────────────────────────────────────

  Widget _buildDestinationCard() {
    return Obx(() {
      final options = controller.destinationOptions;
      final disabled = controller.selectedSource.value == null;

      return AdminCard(
        title: 'To',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (disabled)
              Text(
                'Pick a source first — the destination has to be a different '
                'location from the one the units are leaving.',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color: AdminColors.textMuted,
                ),
              )
            else ...[
              if (options.isEmpty)
                Text(
                  'This merchant only uses one location so far. Type a name '
                  'below to open a new one.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: AdminColors.textMuted,
                  ),
                )
              else
                AdminFilterChips(
                  options: [
                    for (final location in options)
                      AdminFilterOption(location, location),
                  ],
                  selected: controller.selectedLocation.value,
                  onSelected: controller.selectLocation,
                ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.newLocationController,
                // Typing a new warehouse clears any chip selection, so the two
                // inputs can never disagree about the destination.
                onChanged: (value) {
                  if (value.trim().isNotEmpty) controller.selectedLocation.value = '';
                },
                style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Or open a new location',
                  hintText: 'e.g. Warehouse B',
                  labelStyle:
                      TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AdminColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AdminColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ── Quantity ──────────────────────────────────────────────

  Widget _buildQuantityCard() {
    return Obx(() {
      final available = controller.availableQuantity;
      return AdminCard(
        title: 'How many',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(fontSize: 15.sp, color: AdminColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Quantity',
                helperText: controller.selectedSource.value == null
                    ? 'Pick a source to see what is available'
                    : '$available unit(s) available at the source',
                labelStyle:
                    TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
                helperStyle:
                    TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AdminColors.primary),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller.reasonController,
              style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g. Restocking the branch',
                labelStyle:
                    TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AdminColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmit() {
    return Obx(() => AdminButton(
          label: 'Transfer stock',
          icon: Icons.compare_arrows_rounded,
          isLoading: controller.isSubmitting.value,
          onPressed: () async {
            final source = controller.selectedSource.value;
            if (source == null) {
              await controller.submit(); // surfaces the "pick a source" message
              return;
            }
            final confirmed = await adminConfirm(
              title: 'Transfer stock?',
              message: 'Move ${controller.quantityController.text.trim()} × '
                  '${adminString(source['name'], 'this item')} out of '
                  '${adminString(source['location'], 'Main')}. Both sides are '
                  'written to the stock ledger.',
              confirmLabel: 'Transfer',
              confirmColor: AdminColors.primary,
            );
            if (confirmed) await controller.submit();
          },
        ));
  }

  // ── Recent transfers ──────────────────────────────────────

  Widget _buildRecent() {
    return Obx(() {
      final transfers = controller.recentTransfers;
      return AdminCard(
        title: 'Recent transfers',
        trailing: TextButton(
          onPressed: () => Get.offNamed(
            AdminRoutes.INVENTORY_MOVEMENTS,
            arguments: {'type': 'transfer_out'},
          ),
          child: Text('View ledger', style: TextStyle(fontSize: 12.sp)),
        ),
        child: transfers.isEmpty
            ? Text(
                'No transfers recorded yet.',
                style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
              )
            : Column(
                children: [
                  for (final transfer in transfers)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  adminString(transfer['itemName'], 'Unnamed'),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'out of ${adminString(transfer['location'], 'Main')} · '
                                  '${adminRelative(adminDate(transfer['createdAt']))}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11.sp, color: AdminColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          AdminStatusPill(
                            label: '−${adminCount(adminInt(transfer['quantity']))}',
                            color: AdminColors.danger,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      );
    });
  }
}
