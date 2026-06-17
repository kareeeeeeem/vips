import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/widgets/admin_bottomsheet.dart';

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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _employees.value = [
        Employee(
          id: '1',
          name: 'John Doe',
          role: 'Admin',
          status: EmployeeStatus.active,
          email: 'john.doe@example.com',
          joinDate: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Employee(
          id: '2',
          name: 'Jane Smith',
          role: 'Manager',
          status: EmployeeStatus.pending,
          email: 'jane.smith@example.com',
          joinDate: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Employee(
          id: '3',
          name: 'Bob Johnson',
          role: 'Staff',
          status: EmployeeStatus.active,
          email: 'bob.johnson@example.com',
          joinDate: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Employee(
          id: '4',
          name: 'Alice Brown',
          role: 'Admin',
          status: EmployeeStatus.removed,
          email: 'alice.brown@example.com',
          joinDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
      ];

      filterEmployees();
    } catch (e) {
      Get.snackbar(
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      _employees.add(employee);
      filterEmployees();

      Get.back();
      Get.snackbar(
        'Success',
        'Employee added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) {
        _employees[index] = _employees[index].copyWith(status: status);
        filterEmployees();

        Get.snackbar(
          'Success',
          'Employee status updated',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      await updateEmployeeStatus(id, EmployeeStatus.removed);
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
