import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_cashiers_controller.dart';

class MerchantCashiersView extends StatelessWidget {
  const MerchantCashiersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantCashiersController());
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text('Staff & Cashiers',
            style: TextStyle(color: const Color(0xFF1F2937), fontSize: 18.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
            onPressed: controller.loadCashiers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showAddCashierSheet,
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Cashier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }
        if (controller.cashiers.isEmpty) {
          return _buildEmptyState(controller);
        }
        return RefreshIndicator(
          onRefresh: controller.loadCashiers,
          color: const Color(0xFF10B981),
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildSummaryCard(controller),
              SizedBox(height: 16.h),
              ...controller.cashiers.map((c) => _buildCashierCard(c, controller)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(MerchantCashiersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.badge_outlined, size: 48.sp, color: const Color(0xFF10B981)),
          ),
          SizedBox(height: 24.h),
          Text('No Cashiers Added',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
          SizedBox(height: 8.h),
          Text('Add staff accounts to let them\nmanage your POS system.',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)), textAlign: TextAlign.center),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: controller.showAddCashierSheet,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add First Cashier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(MerchantCashiersController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: Colors.white, size: 36),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${controller.cashiers.length} Staff Members',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              Text('Tap + to add more staff', style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashierCard(Map<String, dynamic> cashier, MerchantCashiersController controller) {
    final name = cashier['name']?.toString() ?? 'Unknown';
    final role = cashier['role']?.toString() ?? 'Cashier';
    final phone = cashier['phone']?.toString() ?? '';
    final email = cashier['email']?.toString() ?? '';
    final id = cashier['_id']?.toString() ?? '';
    final initials = name.isNotEmpty ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() : '?';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: CircleAvatar(
          radius: 24.r,
          backgroundColor: controller.roleColor(role).withValues(alpha: 0.15),
          child: Text(initials, style: TextStyle(color: controller.roleColor(role), fontWeight: FontWeight.bold, fontSize: 16.sp)),
        ),
        title: Text(name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: controller.roleColor(role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(role, style: TextStyle(fontSize: 11.sp, color: controller.roleColor(role), fontWeight: FontWeight.w600)),
              ),
            ]),
            if (phone.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(phone, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
            ],
            if (email.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(email, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          onSelected: (value) {
            if (value == 'remove') {
              Get.dialog(AlertDialog(
                title: const Text('Remove Cashier'),
                content: Text('Remove $name from staff?'),
                actions: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () { Get.back(); controller.removeCashier(id); },
                    child: const Text('Remove', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ));
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'remove', child: Row(children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Remove', style: TextStyle(color: Colors.red)),
            ])),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
