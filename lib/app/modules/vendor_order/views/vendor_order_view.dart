import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/vendor_order/views/widgets/order_details_page.dart';

import '../controllers/vendor_order_controller.dart';

class VendorOrderView extends StatelessWidget {
  const VendorOrderView({super.key});

  static const Color vendorGreen = Color(0xFF16A34A);
  static const Color vendorGreenLight = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VendorOrderController>(
      init: VendorOrderController(),
      builder: (controller) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: () => controller.loadOrders(),
            child: _buildBody(context, controller),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.receipt_long, size: 30, color: vendorGreen),
      ),
      titleSpacing: 0,
      elevation: 2,
      title: const Text(
        'Order History',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBody(BuildContext context, VendorOrderController controller) {
    return Obx(() {
      if (controller.isLoading && controller.getFilteredOrders().isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: vendorGreen),
        );
      }

      List<Map<String, dynamic>> filteredOrders =
          controller.getFilteredOrders();

      return CustomScrollView(
        slivers: [
          // Stats cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildStatsCards(context, controller),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Sticky Status Filter
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                height: 45.0,
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _buildStatusTabs(context, controller),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Orders list
          SliverToBoxAdapter(
            child:
                filteredOrders.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 100),
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredOrders.length,
                      separatorBuilder:
                          (context, index) =>
                              const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(context, controller, order);
                      },
                    ),
          ),
        ],
      );
    });
  }

  Widget _buildStatsCards(
    BuildContext context,
    VendorOrderController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [vendorGreen, vendorGreenLight]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatCard(context, 'Today', controller.todayOrderCount),
          _buildStatCard(context, 'This Week', controller.thisWeekOrderCount),
          _buildStatCard(context, 'This Month', controller.thisMonthOrderCount),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int count) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabs(
    BuildContext context,
    VendorOrderController controller,
  ) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GetBuilder(
        init: controller,
        builder: (context) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.orderStatuses.length,
            itemBuilder: (context, index) {
              bool isSelected = controller.selectedStatusIndex == index;
              String status = controller.orderStatuses[index];

              // Get count for this status
              int count = controller.getCountForStatus(status);

              return InkWell(
                onTap: () => controller.setStatusIndex(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: isSelected ? vendorGreen : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.25)
                                  : vendorGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : vendorGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    VendorOrderController controller,
    Map<String, dynamic> order,
  ) {
    Color statusColor = Color(
      int.parse(controller.getStatusColor(order['status'])),
    );

    return InkWell(
      onTap: () {
        controller.selectOrder(order['id']);
        _showOrderDetails(context, controller, order);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Order ID: ${order['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${order['date']}  ${order['time']} | ${order['orderType']}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        order['customerName'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: vendorGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order['items']} Item${order['items'] > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 24, color: vendorGreen),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    VendorOrderController controller,
    Map<String, dynamic> order,
  ) {
    if (order['status'] != 'Pending') {
      Get.to(() => OrderDetailsPage(order: order));
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Confirmed';
      case 'Confirmed':
        return 'Processing';
      case 'Processing':
        return 'Ready';
      case 'Ready':
        return 'Delivered';
      default:
        return currentStatus;
    }
  }

  String _getActionButtonText(String currentStatus) {
    switch (currentStatus) {
      case 'Pending':
        return 'Confirm Order';
      case 'Confirmed':
        return 'Start Processing';
      case 'Processing':
        return 'Mark as Ready';
      case 'Ready':
        return 'Mark as Delivered';
      default:
        return 'Update Status';
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    VendorOrderController controller,
    Map<String, dynamic> order,
    String nextStatus,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 32,
                  color: vendorGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirm Action',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to change the order status to $nextStatus?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.updateOrderStatus(order['id'], nextStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vendorGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    VendorOrderController controller,
    Map<String, dynamic> order,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cancel Order',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to cancel this order? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Keep Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.updateOrderStatus(order['id'], 'Cancelled');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 45.0; // Height of the filter container

  @override
  double get maxExtent => 45.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return false;
  }
}
