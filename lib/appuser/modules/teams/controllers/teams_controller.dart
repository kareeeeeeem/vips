import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/admin_bottomsheet.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

/// Controller for TeamSync screen using GetX
class TeamsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  final _tabIndex = 0.obs;
  final _isLoading = false.obs;
  final _employees = <Employee>[].obs;
  final _filteredEmployees = <Employee>[].obs;

  // Getters
  int get tabIndex => _tabIndex.value;
  bool get isLoading => _isLoading.value;
  List<Employee> get employees => _employees;
  List<Employee> get filteredEmployees => _filteredEmployees;

  // Tab controller
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(_onTabChanged);
    loadEmployees();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Handle tab changes
  void _onTabChanged() {
    _tabIndex.value = tabController.index;
    filterEmployees();
  }

  /// Change tab programmatically
  void changeTab(int index) {
    tabController.animateTo(index);
  }

  /// Load employees data
  Future<void> loadEmployees() async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService().get('/user/teams');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        _employees.value = data.map((json) => Employee.fromJson(json)).toList();
        filterEmployees();
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        'Failed to load employees: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filter employees based on selected tab
  void filterEmployees() {
    switch (_tabIndex.value) {
      case 0: // All
        _filteredEmployees.value = _employees;
        break;
      case 1: // Active
        _filteredEmployees.value =
            _employees.where((e) => e.status == EmployeeStatus.active).toList();
        break;
      case 2: // Pending
        _filteredEmployees.value =
            _employees
                .where((e) => e.status == EmployeeStatus.pending)
                .toList();
        break;
      case 3: // Removed
        _filteredEmployees.value =
            _employees
                .where((e) => e.status == EmployeeStatus.removed)
                .toList();
        break;
    }
  }

  /// Add new employee
  Future<void> addEmployee(Employee employee) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService().post('/user/teams', employee.toJson());
      
      if (response.success && response.data != null) {
        _employees.insert(0, Employee.fromJson(response.data));
        filterEmployees();

        Get.back();
        safeSnackbar(
          'Success',
          'Employee added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        'Failed to add employee: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update employee status
  Future<void> updateEmployeeStatus(String id, EmployeeStatus status) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService().put('/user/teams/$id/status', {
        'status': status.name,
      });

      if (response.success) {
        final index = _employees.indexWhere((e) => e.id == id);
        if (index != -1) {
          _employees[index] = _employees[index].copyWith(status: status);
          filterEmployees();

          safeSnackbar(
            'Success',
            'Employee status updated',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        'Failed to update status: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Remove employee
  Future<void> removeEmployee(String id) async {
    try {
      _isLoading.value = true;
      
      final response = await ApiService().delete('/user/teams/$id');
      
      if (response.success) {
        _employees.removeWhere((e) => e.id == id);
        filterEmployees();
        safeSnackbar('Success', 'Employee removed');
      } else {
        safeSnackbar('Error', response.message);
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to remove employee: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Show create admin bottom sheet
  void showCreateAdminSheet() {
    Get.bottomSheet(
      const CreateAdminBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Show settings bottom sheet
  void showSettingsSheet() {
    Get.bottomSheet(
      const SettingsAdminBottomSheet(),
      backgroundColor: Colors.transparent,
    );
  }

  /// Show operations bottom sheet
  void showOperationsSheet(Employee employee) {
    Get.bottomSheet(
      OperationAdminBottomSheet(employee: employee),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showFilterSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Employees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: ['All', 'Active', 'Pending', 'Removed'].map((f) {
                return ActionChip(
                  label: Text(f),
                  onPressed: () {
                    Get.back();
                    final idx = ['All', 'Active', 'Pending', 'Removed'].indexOf(f);
                    tabController.animateTo(idx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void exportEmployees() {
    final list = _employees.toList();
    if (list.isEmpty) {
      safeSnackbar('No Data', 'No employees to export');
      return;
    }
    final buffer = StringBuffer('VIPs Teams Export\n${'─' * 40}\n');
    for (final e in list) {
      buffer.writeln('${e.name} | ${e.role} | ${e.status.displayName} | ${e.email}');
    }
    buffer.writeln('${'─' * 40}\nTotal: ${list.length} employees');
    SharePlus.instance.share(ShareParams(text: buffer.toString(), subject: 'VIPs Teams Export'));
  }

  void showEditEmployeeSheet(Employee employee) {
    final nameCtrl = TextEditingController(text: employee.name);
    final emailCtrl = TextEditingController(text: employee.email);
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Employee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Get.back();
                  try {
                    final response = await ApiService().put('/admin/employees/${employee.id}', {
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                    });
                    if (response.success) {
                      safeSnackbar('Success', 'Employee updated', backgroundColor: Colors.green, colorText: Colors.white);
                      loadEmployees();
                    } else {
                      safeSnackbar('Error', response.message);
                    }
                  } catch (_) {
                    safeSnackbar('Error', 'Failed to update employee');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

/// Employee model
class Employee {
  final String id;
  final String name;
  final String role;
  final EmployeeStatus status;
  final String email;
  final DateTime joinDate;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.email,
    required this.joinDate,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? role,
    EmployeeStatus? status,
    String? email,
    DateTime? joinDate,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    EmployeeStatus statusEnum = EmployeeStatus.pending;
    if (json['status'] == 'active') statusEnum = EmployeeStatus.active;
    if (json['status'] == 'removed') statusEnum = EmployeeStatus.removed;

    return Employee(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      status: statusEnum,
      email: json['email'] ?? '',
      joinDate: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'status': status.name,
      'email': email,
    };
  }
}

/// Employee status enum
enum EmployeeStatus { active, pending, removed }

extension EmployeeStatusExtension on EmployeeStatus {
  String get displayName {
    switch (this) {
      case EmployeeStatus.active:
        return 'Active';
      case EmployeeStatus.pending:
        return 'Pending';
      case EmployeeStatus.removed:
        return 'Removed';
    }
  }

  Color get color {
    switch (this) {
      case EmployeeStatus.active:
        return const Color(0xff4CAF50);
      case EmployeeStatus.pending:
        return const Color(0xffFF9800);
      case EmployeeStatus.removed:
        return const Color(0xffF44336);
    }
  }
}
