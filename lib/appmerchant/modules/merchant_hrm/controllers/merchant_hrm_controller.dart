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
        salary: (json['salary'] ?? 0).toDouble(),
        joinedDate: json['joinedDate'] != null
            ? DateTime.parse(json['joinedDate'])
            : DateTime.now(),
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
        staffList.value = list.map((e) => StaffMember.fromJson(e)).toList();
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addStaff(Map<String, dynamic> body) async {
    try {
      final res = await ApiService().post('/merchant/staff', body);
      if (res.success && res.data != null) {
        staffList.insert(0, StaffMember.fromJson(res.data));
      } else {
        safeSnackbar('Error', 'Failed to add staff member', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to add staff member', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateStaff(String id, Map<String, dynamic> body) async {
    try {
      final res = await ApiService().put('/merchant/staff/$id', body);
      if (res.success && res.data != null) {
        final data = res.data;
        final index = staffList.indexWhere((e) => e.id == id);
        if (index != -1) staffList[index] = StaffMember.fromJson(data);
      } else {
        safeSnackbar('Error', 'Failed to update staff member', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to update staff member', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removeStaff(String id) async {
    try {
      final res = await ApiService().delete('/merchant/staff/$id');
      if (res.success) {
        staffList.removeWhere((e) => e.id == id);
      } else {
        safeSnackbar('Error', 'Failed to remove staff member', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to remove staff member', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
