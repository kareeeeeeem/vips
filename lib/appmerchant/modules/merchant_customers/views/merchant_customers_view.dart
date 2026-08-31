import 'package:vip/core/chat/views/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/widgets/custom_network_image.dart';

import '../controllers/merchant_customers_controller.dart';

class MerchantCustomersView extends GetView<MerchantCustomersController> {
  const MerchantCustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MerchantCustomersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Customers',
          style: TextStyle(color: const Color(0xFF1F2937), fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // The conversations already open. A merchant answers messages far
          // more often than they start one, so this is the way in.
          IconButton(
            icon: const Icon(Icons.forum_outlined, color: Color(0xFF1F2937)),
            tooltip: 'Messages',
            onPressed: () => Get.to(() => const ChatListView(
                  accent: Color(0xFF1B7A43),
                  title: 'Customer messages',
                )),
          ),
        ],
      ),
      body: Column(
        children: [
          // The controller has always had updateSearch()/filteredCustomers
          // and the backend has always accepted ?search= — but no search
          // field existed on this screen, so all three were dead.
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search by name, phone or email',
                hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                prefixIcon: Icon(Icons.search, size: 20.sp, color: const Color(0xFF9CA3AF)),
                suffixIcon: Obx(() => controller.searchQuery.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: Icon(Icons.close, size: 18.sp),
                        onPressed: controller.clearSearch,
                      )),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
              }

              final list = controller.filteredCustomers;
              if (list.isEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) => RefreshIndicator(
                    color: const Color(0xFF10B981),
                    onRefresh: controller.loadCustomers,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 80.sp, color: const Color(0xFFD1D5DB)),
                            SizedBox(height: 16.h),
                            Text(
                              controller.searchQuery.value.isEmpty
                                  ? 'No customers yet'
                                  : 'No customer matches that search',
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4B5563)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF10B981),
                onRefresh: controller.loadCustomers,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildCustomerCard(list[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    return GestureDetector(
      onTap: () => _showCustomerActions(customer),
      child: _customerCardBody(customer),
    );
  }

  /// The list was read-only: a merchant could see a customer and had no way to
  /// act on them, even though Gift Back and Credit both already exist and both
  /// start from a phone number.
  void _showCustomerActions(CustomerModel customer) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.name,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
            if (customer.phone.isNotEmpty)
              Text(customer.phone,
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
            SizedBox(height: 12.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFFF9800)),
              title: const Text('Send Gift Back'),
              subtitle: const Text('Give this customer VIPs points'),
              onTap: () {
                Get.back();
                Get.toNamed(MerchantRoutes.GIFT_BACK_FORM,
                    arguments: {'phone': customer.phone});
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined,
                  color: Color(0xFF10B981)),
              title: const Text('Issue Credit'),
              subtitle: const Text('Record money this customer owes you'),
              onTap: () {
                Get.back();
                Get.toNamed(MerchantRoutes.MERCHANT_CREDIT_FORM, arguments: {
                  // selectCustomer() reads the id under '_id'/'id'.
                  '_id': customer.id,
                  'fullName': customer.name,
                  'phone': customer.phone,
                });
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _customerCardBody(CustomerModel customer) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: CustomNetworkImage(
              imageUrl: customer.imageUrl,
              width: 56.w,
              height: 56.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Last visit: ${customer.lastVisit}',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol('Visits', customer.totalVisits.toString(), const Color(0xFF3B82F6)),
                    _buildStatCol('Earned', customer.pointsEarned.toString(), const Color(0xFF10B981)),
                    _buildStatCol('Spent', customer.pointsSpent.toString(), const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
        Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
