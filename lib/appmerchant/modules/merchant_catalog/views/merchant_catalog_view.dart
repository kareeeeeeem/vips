import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_catalog_controller.dart';
import '../../../routes/merchant_routes.dart';

class MerchantCatalogView extends GetView<MerchantCatalogController> {
  const MerchantCatalogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(
            'My Catalog',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF10B981),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            tabs: const [
              Tab(text: 'Items'),
              Tab(text: 'Vouchers'),
              Tab(text: 'Coupons'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemList(),
            _buildVoucherList(),
            _buildCouponList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateOptions(context),
          backgroundColor: const Color(0xFF10B981),
          elevation: 4,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add New',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create New',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937))),
                SizedBox(height: 16.h),
                _buildActionTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'New Item',
                  subtitle: 'Add a new product or service',
                  onTap: () {
                    Get.back();
                    Get.toNamed(MerchantRoutes.CREATE_ITEM);
                  },
                ),
                _buildActionTile(
                  icon: Icons.local_activity_outlined,
                  title: 'New Voucher',
                  subtitle: 'Create a discount voucher',
                  onTap: () {
                    Get.back();
                    Get.toNamed(MerchantRoutes.CREATE_VOUCHER);
                  },
                ),
                _buildActionTile(
                  icon: Icons.card_giftcard_outlined,
                  title: 'New Coupon',
                  subtitle: 'Create a promotional coupon',
                  onTap: () {
                    Get.back();
                    Get.toNamed(MerchantRoutes.CREATE_COUPON);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: const Color(0xFF10B981)),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151))),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      onTap: onTap,
    );
  }

  Widget _buildItemList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildCatalogCard(
          title: 'Premium Product ${index + 1}',
          price: '\$${(index + 1) * 20}.00',
          status: 'Active',
          stock: '${(index + 1) * 15} in stock',
          imageUrl: 'https://via.placeholder.com/150',
          onEdit: () => Get.toNamed(MerchantRoutes.CREATE_ITEM),
        );
      },
    );
  }

  Widget _buildVoucherList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 2,
      itemBuilder: (context, index) {
        return _buildCatalogCard(
          title: 'Discount Voucher ${index + 1}',
          price: '20% OFF',
          status: 'Active',
          stock: 'Expires 31 Dec',
          imageUrl: 'https://via.placeholder.com/150/10B981/FFFFFF?text=V',
          onEdit: () => Get.toNamed(MerchantRoutes.CREATE_VOUCHER),
        );
      },
    );
  }

  Widget _buildCouponList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 1,
      itemBuilder: (context, index) {
        return _buildCatalogCard(
          title: 'Summer Coupon',
          price: '\$10 OFF',
          status: 'Draft',
          stock: 'Unlimited',
          imageUrl: 'https://via.placeholder.com/150/F59E0B/FFFFFF?text=C',
          onEdit: () => Get.toNamed(MerchantRoutes.CREATE_COUPON),
        );
      },
    );
  }

  Widget _buildCatalogCard({
    required String title,
    required String price,
    required String status,
    required String stock,
    required String imageUrl,
    required VoidCallback onEdit,
  }) {
    final bool isActive = status.toLowerCase() == 'active';
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              imageUrl,
              width: 80.w,
              height: 80.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80.w,
                height: 80.w,
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.image, color: Color(0xFF9CA3AF)),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  price,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981)),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stock,
                      style: TextStyle(
                          fontSize: 12.sp, color: const Color(0xFF6B7280)),
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            value: isActive,
                            onChanged: (val) {
                              // Toggle logic
                            },
                            activeColor: const Color(0xFF10B981),
                          ),
                        ),
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(Icons.edit_outlined,
                                size: 16.sp, color: const Color(0xFF4B5563)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
