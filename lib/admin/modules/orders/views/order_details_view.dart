import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/orders_controller.dart';

/// A single order end to end: parties, itemised lines, the money breakdown,
/// the fulfilment timeline, and the status controls.
class OrderDetailsView extends GetView<AdminOrdersController> {
  const OrderDetailsView({super.key});

  /// The id comes from the `:id` path segment. Get.arguments is kept as a
  /// fallback so a caller that passes it as an argument still resolves.
  String get _orderId {
    final param = Get.parameters['id'];
    if (param != null && param.isNotEmpty) return param;
    final args = Get.arguments;
    return args is Map ? adminString(args['id']) : '';
  }

  @override
  Widget build(BuildContext context) {
    if (_orderId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: AdminEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'No order selected',
          message: 'This screen needs an order id. Open it from the Orders list.',
          action: AdminButton(label: 'Back', expand: false, onPressed: Get.back),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.details.value == null && !controller.isLoadingDetails.value) {
        controller.loadDetails(_orderId);
      }
    });

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
        title: Text(
          'Order',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadDetails(_orderId),
            icon: Icon(Icons.refresh_rounded, size: 20.sp, color: AdminColors.textSecondary),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetails.value) return const AdminLoading();

        final data = controller.details.value;
        final order = data != null && data['order'] is Map
            ? Map<String, dynamic>.from(data['order'] as Map)
            : null;

        if (order == null) {
          return AdminErrorState(
            message: 'Could not load this order.',
            onRetry: () => controller.loadDetails(_orderId),
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          children: [
            _buildHeader(order),
            SizedBox(height: 16.h),
            _buildPartiesCard(order),
            SizedBox(height: 16.h),
            _buildItemsCard(order),
            SizedBox(height: 16.h),
            _buildTotalsCard(order),
            SizedBox(height: 16.h),
            _buildDeliveryCard(order),
            SizedBox(height: 16.h),
            _buildTimelineCard(order),
            SizedBox(height: 16.h),
            _buildActionsCard(order),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(Map<String, dynamic> order) {
    final status = adminString(order['status']);
    final paymentStatus = adminString(order['paymentStatus'], 'pending');

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${adminString(order['orderNumber'], '—')}',
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              AdminStatusPill(
                label: adminLabel(status),
                color: AdminColors.orderStatus(status),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            adminDateTimeLabel(adminDate(order['createdAt'])),
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                adminMoney(adminDouble(order['totalAmount'])),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              AdminStatusPill(
                label: '${adminLabel(paymentStatus)} · '
                    '${adminLabel(adminString(order['paymentMethod'], 'cash'))}',
                color: paymentStatus == 'paid'
                    ? AdminColors.success
                    : paymentStatus == 'failed'
                        ? AdminColors.danger
                        : AdminColors.warning,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesCard(Map<String, dynamic> order) {
    // userId / merchantId arrive populated as objects, but stay bare ids if
    // the referenced account was deleted — handle both shapes.
    final customer = order['userId'] is Map
        ? Map<String, dynamic>.from(order['userId'] as Map)
        : <String, dynamic>{};
    final merchant = order['merchantId'] is Map
        ? Map<String, dynamic>.from(order['merchantId'] as Map)
        : <String, dynamic>{};

    return AdminCard(
      title: 'Parties',
      child: Column(
        children: [
          AdminDetailRow(
            label: 'Customer',
            value: adminString(customer['fullName'], 'Deleted or unknown'),
          ),
          AdminDetailRow(label: 'Email', value: adminString(customer['email'])),
          AdminDetailRow(label: 'Phone', value: adminString(customer['phone'])),
          const Divider(height: 20, color: AdminColors.divider),
          AdminDetailRow(
            label: 'Merchant',
            value: adminString(
              merchant['storeName'],
              adminString(merchant['fullName'], 'No merchant assigned'),
            ),
          ),
          AdminDetailRow(label: 'Merchant phone', value: adminString(merchant['phone'])),
          AdminDetailRow(label: 'Store address', value: adminString(merchant['storeAddress'])),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Map<String, dynamic> order) {
    // A non-List `items` would throw inside the builder and blank the whole
    // screen; guard the shape rather than trusting it.
    final raw = order['items'];
    final items = raw is List
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];

    return AdminCard(
      title: 'Items (${items.length})',
      child: items.isEmpty
          ? Text(
              'This order has no line items recorded.',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            )
          : Column(
              children: [
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AdminColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Text(
                            '${adminInt(item['quantity'], 1)}×',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.accent,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminString(item['item_name'], 'Unnamed item'),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              if (adminDouble(item['discount_on_item']) > 0)
                                Text(
                                  'Discount ${adminMoney(adminDouble(item['discount_on_item']))}',
                                  style: TextStyle(
                                      fontSize: 11.sp, color: AdminColors.success),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          adminMoney(
                            adminDouble(item['price']) * adminInt(item['quantity'], 1),
                          ),
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
    );
  }

  Widget _buildTotalsCard(Map<String, dynamic> order) {
    final discounts = adminDouble(order['couponDiscountAmount']) +
        adminDouble(order['storeDiscountAmount']) +
        adminDouble(order['walletDiscountAmount']);

    return AdminCard(
      title: 'Payment breakdown',
      child: Column(
        children: [
          AdminDetailRow(
            label: 'Total charged',
            value: adminMoney(adminDouble(order['totalAmount'])),
          ),
          if (discounts > 0)
            AdminDetailRow(
              label: 'Discounts',
              value: '− ${adminMoney(discounts)}',
              valueColor: AdminColors.success,
            ),
          if (adminString(order['couponDiscountTitle']).isNotEmpty)
            AdminDetailRow(
              label: 'Coupon',
              value: adminString(order['couponDiscountTitle']),
            ),
          if (adminInt(order['walletPointsRedeemed']) > 0)
            AdminDetailRow(
              label: 'Points redeemed',
              value: adminCount(adminInt(order['walletPointsRedeemed'])),
            ),
          AdminDetailRow(
            label: 'Tax',
            value: adminMoney(adminDouble(order['totalTaxAmount'])),
          ),
          AdminDetailRow(
            label: 'Delivery charge',
            value: adminMoney(adminDouble(order['deliveryCharge'])),
          ),
          AdminDetailRow(
            label: 'Payment method',
            value: adminLabel(adminString(order['paymentMethod'], 'cash')),
          ),
          AdminDetailRow(
            label: 'Payment status',
            valueWidget: AdminStatusPill(
              label: adminLabel(adminString(order['paymentStatus'], 'pending')),
              color: adminString(order['paymentStatus']) == 'paid'
                  ? AdminColors.success
                  : adminString(order['paymentStatus']) == 'failed'
                      ? AdminColors.danger
                      : AdminColors.warning,
              compact: true,
            ),
          ),
          AdminDetailRow(
            label: 'Reference',
            value: adminString(order['paymentReference']),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> order) {
    final address = order['deliveryAddress'] is Map
        ? Map<String, dynamic>.from(order['deliveryAddress'] as Map)
        : <String, dynamic>{};

    return AdminCard(
      title: 'Fulfilment',
      child: Column(
        children: [
          AdminDetailRow(
            label: 'Order type',
            value: adminLabel(adminString(order['orderType'], 'delivery')),
          ),
          AdminDetailRow(
            label: 'Recipient',
            value: adminString(address['contact_person_name']),
          ),
          AdminDetailRow(
            label: 'Contact',
            value: adminString(address['contact_person_number']),
          ),
          AdminDetailRow(label: 'Address', value: adminString(address['address'])),
          AdminDetailRow(
            label: 'Instructions',
            value: adminString(order['deliveryInstruction']),
          ),
          AdminDetailRow(label: 'Note', value: adminString(order['orderNote'])),
          if (adminString(order['cancellationReason']).isNotEmpty)
            AdminDetailRow(
              label: 'Cancellation reason',
              value: adminString(order['cancellationReason']),
              valueColor: AdminColors.danger,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> order) {
    // Each entry maps to the *At field the backend stamps on that transition.
    const steps = [
      ('pendingAt', 'Placed'),
      ('confirmedAt', 'Confirmed'),
      ('processingAt', 'Processing'),
      ('handoverAt', 'Handed over'),
      ('pickedUpAt', 'Picked up'),
      ('deliveredAt', 'Delivered'),
      ('canceledAt', 'Cancelled'),
      ('refundRequestedAt', 'Refund requested'),
      ('refundedAt', 'Refunded'),
    ];

    final reached = [
      for (final step in steps)
        if (adminDate(order[step.$1]) != null) (step.$2, adminDate(order[step.$1])!),
    ];

    return AdminCard(
      title: 'Timeline',
      child: reached.isEmpty
          ? Text(
              'No timeline events recorded for this order yet.',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            )
          : Column(
              children: [
                for (var i = 0; i < reached.length; i++)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              margin: EdgeInsets.only(top: 5.h),
                              decoration: const BoxDecoration(
                                color: AdminColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (i < reached.length - 1)
                              Expanded(
                                child: Container(
                                  width: 2.w,
                                  color: AdminColors.border,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reached[i].$1,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  adminDateTimeLabel(reached[i].$2),
                                  style: TextStyle(
                                      fontSize: 11.sp, color: AdminColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildActionsCard(Map<String, dynamic> order) {
    final id = adminString(order['_id']);
    final status = adminString(order['status']);
    final canCancel = !controller.isTerminal(status);

    return AdminCard(
      title: 'Manage',
      child: Obx(() {
        final busy = controller.isMutating.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Move to status',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final next in AdminOrdersController.statuses)
                  if (next != status)
                    OutlinedButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final confirmed = await adminConfirm(
                                title: 'Set to ${adminLabel(next)}?',
                                message: 'This updates the order for the '
                                    'customer and the merchant, and stamps the '
                                    'matching timeline entry.',
                                confirmLabel: 'Update',
                                confirmColor: AdminColors.primary,
                              );
                              if (!confirmed) return;
                              final ok = await controller.mutate(
                                () => controller.api.updateOrderStatus(id, next),
                                successTitle: 'Order updated',
                                reload: false,
                              );
                              if (ok) await controller.loadDetails(id);
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AdminColors.orderStatus(next).withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                      child: Text(
                        adminLabel(next),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.orderStatus(next),
                        ),
                      ),
                    ),
              ],
            ),
            SizedBox(height: 18.h),
            AdminButton(
              label: canCancel ? 'Cancel order' : 'Cannot cancel (${adminLabel(status)})',
              icon: Icons.cancel_outlined,
              color: AdminColors.danger,
              isLoading: busy,
              // A delivered or already-cancelled order is refused server
              // side, so the button is disabled rather than failing on tap.
              onPressed: !canCancel
                  ? null
                  : () async {
                      final reason = await adminPromptReason(
                        title: 'Cancel this order',
                        message: 'The reason is stored on the order and shown '
                            'to the customer.',
                        hint: 'e.g. Merchant out of stock',
                        confirmLabel: 'Cancel order',
                      );
                      if (reason == null) return;
                      final ok = await controller.mutate(
                        () => controller.api.cancelOrder(id, reason),
                        successTitle: 'Order cancelled',
                        failureTitle: 'Cannot cancel',
                        reload: false,
                      );
                      if (ok) await controller.loadDetails(id);
                    },
            ),
          ],
        );
      }),
    );
  }
}
