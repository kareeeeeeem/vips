import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class StaffMember {
  final String id;
  final String name;
  final String role;
  final String status;
  final double salary;
  final DateTime joinedDate;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.salary,
    required this.joinedDate,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        role: json['role'] ?? 'Staff',
        status: json['status'] ?? 'Active',
        salary: json['salary'] is num
            ? (json['salary'] as num).toDouble()
            : (double.tryParse('${json['salary'] ?? ''}') ?? 0),
        joinedDate: DateTime.tryParse('${json['joinedDate'] ?? ''}') ?? DateTime.now(),
      );
}

class MerchantHRMController extends GetxController {
  final staffList = <StaffMember>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStaff();
  }

  Future<void> loadStaff() async {
    isLoading.value = true;
    try {
      final res = await ApiService().get('/merchant/staff');
      if (res.success && res.data != null) {
        final List<dynamic> list = res.data is List ? res.data : [];
        staffList.value = list
            .whereType<Map>()
            .map((e) => StaffMember.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('loadStaff failed: $e');
      safeSnackbar('Error', 'Could not load your staff. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Real `Staff.status` enum (models/Staff.js).
  static const statuses = ['Active', 'On Leave', 'Inactive'];

  /// Returns whether the add actually went through, so the caller can close
  /// the sheet and celebrate only on success — it used to do both regardless.
  Future<bool> addStaff(Map<String, dynamic> body) async {
    try {
      final res = await ApiService().post('/merchant/staff', body);
      if (res.success && res.data != null) {
        staffList.insert(0, StaffMember.fromJson(Map<String, dynamic>.from(res.data as Map)));
        return true;
      }
      safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to add staff member',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      debugPrint('addStaff failed: $e');
      safeSnackbar('Error', 'Could not add that staff member. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  /// Change a staff member's status. `updateStaff` and PUT /merchant/staff/:id
  /// both existed with nothing calling them, so the Active / On Leave /
  /// Inactive badge could never actually be changed.
  Future<void> setStaffStatus(String id, String status) async {
    if (!statuses.contains(status)) return;
    await updateStaff(id, {'status': status});
  }

  Future<void> updateStaff(String id, Map<String, dynamic> body) async {
    try {
      final res = await ApiService().put('/merchant/staff/$id', body);
      if (res.success && res.data != null) {
        final index = staffList.indexWhere((e) => e.id == id);
        if (index != -1) {
          staffList[index] = StaffMember.fromJson(Map<String, dynamic>.from(res.data as Map));
        }
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to update staff member',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('updateStaff failed: $e');
      safeSnackbar('Error', 'Could not update that staff member. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removeStaff(String id) async {
    try {
      final res = await ApiService().delete('/merchant/staff/$id');
      if (res.success) {
        staffList.removeWhere((e) => e.id == id);
      } else {
        safeSnackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to remove staff member',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('removeStaff failed: $e');
      safeSnackbar('Error', 'Could not remove that staff member. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
