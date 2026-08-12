import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_hrm_controller.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class StaffManagementView extends GetView<MerchantHRMController> {
  const StaffManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Staff Management',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Employee Directory',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                FloatingActionButton.small(
                  onPressed: () => _showAddStaffSheet(),
                  backgroundColor: const Color(0xFF3B82F6),
                  child: const Icon(Icons.person_add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
              }
              if (controller.staffList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt_outlined, size: 60.sp, color: const Color(0xFFD1D5DB)),
                      SizedBox(height: 16.h),
                      Text('No Staff Added', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4B5563))),
                      SizedBox(height: 8.h),
                      Text('Tap + to add staff members', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: controller.staffList.length,
                itemBuilder: (context, index) {
                  final staff = controller.staffList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          child: Text(
                            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                            style: TextStyle(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
                              Text(staff.role, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: staff.status == 'Active' ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                staff.status,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: staff.status == 'Active' ? const Color(0xFF059669) : const Color(0xFFB45309),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text('D ${staff.salary.toStringAsFixed(0)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4.h),
                            GestureDetector(
                              onTap: () => _confirmRemove(staff.id, staff.name),
                              child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAddStaffSheet() {
    final nameCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final role = 'Staff'.obs;
    final roles = ['Staff', 'Manager', 'Supervisor', 'Accountant'];

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Add Staff Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF3B82F6)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<String>(
                key: ValueKey(role.value),
                initialValue: role.value,
                decoration: InputDecoration(
                  labelText: 'Role',
                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF3B82F6)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                ),
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => role.value = v!,
              )),
              const SizedBox(height: 12),
              TextField(
                controller: salaryCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monthly Salary',
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF3B82F6)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await controller.addStaff({
                      'name': nameCtrl.text.trim(),
                      'role': role.value,
                      'salary': double.tryParse(salaryCtrl.text) ?? 0,
                      'status': 'Active',
                    });
                    Get.back();
                    safeSnackbar('Added', '${nameCtrl.text} added successfully',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF3B82F6),
                        colorText: Colors.white);
                  },
                  child: const Text('Add Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmRemove(String id, String name) {
    Get.dialog(AlertDialog(
      title: const Text('Remove Staff'),
      content: Text('Remove $name from staff?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () { Get.back(); controller.removeStaff(id); },
          child: const Text('Remove', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
  }
}
