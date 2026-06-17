import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_order_controller.dart';
import 'widgets/order_stats_cards.dart';
import 'widgets/order_status_tabs.dart';
import 'widgets/order_list_widget.dart';
import 'widgets/search_bar_widget.dart';

class MerchantOrdersView extends GetView<MerchantOrderController> {
  const MerchantOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: const Color(0xFF10B981),
          child: Column(
            children: [
              // Stats Cards
              const OrderStatsCards(),

              SizedBox(height: 16.h),

              // Search Bar
              const SearchBarWidget(),

              SizedBox(height: 16.h),

              // Status Tabs
              const OrderStatusTabs(),

              SizedBox(height: 16.h),

              // Orders List
              Expanded(
                child: Obx(() {
                  switch (controller.status.value) {
                    case MerchantOrderViewStatus.loading:
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                        ),
                      );
                    case MerchantOrderViewStatus.success:
                      if (controller.filteredOrders.isEmpty) {
                        return _buildEmptyState();
                      }
                      return const OrderListWidget();
                    case MerchantOrderViewStatus.error:
                      return _buildErrorState();
                    case MerchantOrderViewStatus.empty:
                      return _buildEmptyState();
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Order Management',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111827),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFF6B7280)),
          onPressed: () => _showFilterDialog(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16.h),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Orders will appear here once customers place them',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load orders',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: controller.loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Orders',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 24.h),

              // Status Filter
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() {
                return Wrap(
                  spacing: 8.w,
                  children: controller.statusFilters.map((status) {
                    final isSelected = controller.selectedStatusFilter.value == status;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(status.toUpperCase()),
                      onSelected: (selected) {
                        if (selected) {
                          controller.updateStatusFilter(status);
                        }
                      },
                      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF10B981),
                    );
                  }).toList(),
                );
              }),

              SizedBox(height: 24.h),

              // Date Range Filter
              Text(
                'Date Range',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 8.h),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF10B981)),
                title: Obx(() {
                  final range = controller.selectedDateRange.value;
                  if (range == null) {
                    return const Text('Select date range');
                  }
                  return Text(
                    '${_formatDate(range.start)} - ${_formatDate(range.end)}',
                  );
                }),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF10B981),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (range != null) {
                    controller.updateDateRange(range);
                  }
                },
              ),

              SizedBox(height: 24.h),

              // Clear Filters Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Color(0xFF6B7280)),
                  ),
                  child: const Text('Clear All Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}