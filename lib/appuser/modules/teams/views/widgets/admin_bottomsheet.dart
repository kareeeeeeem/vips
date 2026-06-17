import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../controllers/teams_controller.dart';

/// Bottom Sheet for Creating New Admin - Minimal Version
class CreateAdminBottomSheet extends StatefulWidget {
  const CreateAdminBottomSheet({super.key});

  @override
  State<CreateAdminBottomSheet> createState() => _CreateAdminBottomSheetState();
}

class _CreateAdminBottomSheetState extends State<CreateAdminBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();

  String _selectedRole = 'Admin';
  final List<String> _roles = ['Admin', 'Manager', 'Staff', 'Supervisor'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Admin',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.AppBlackColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: 24.r,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Name Field
              Text(
                'Full Name',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.AppBlackColor,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.AppBlackColor,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Email Field
              Text(
                'Email Address',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.AppBlackColor,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'example@company.com',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.AppBlackColor,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Role Dropdown
              Text(
                'Role',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.AppBlackColor,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.AppBlackColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                items:
                    _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Create Button
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          final controller = Get.find<TeamsController>();

                          final newEmployee = Employee(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            role: _selectedRole,
                            status: EmployeeStatus.pending,
                            joinDate: DateTime.now(),
                          );

                          controller.addEmployee(newEmployee);
                        }
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.AppBlackColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Create Admin',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
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

/// Bottom Sheet for Settings - Minimal Version
class SettingsAdminBottomSheet extends StatelessWidget {
  const SettingsAdminBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.AppBlackColor,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.close,
                  size: 24.r,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Settings Options
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Notifications',
                'Coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),

          _buildSettingItem(
            icon: Icons.security_outlined,
            title: 'Permissions',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Permissions',
                'Coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),

          _buildSettingItem(
            icon: Icons.filter_list_outlined,
            title: 'Filter Options',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Filters',
                'Coming soon!',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),

          _buildSettingItem(
            icon: Icons.download_outlined,
            title: 'Export Data',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Export',
                'Preparing export...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),

          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Help',
                'Opening support...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 22.r),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.AppBlackColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet for Employee Operations - Minimal Version
class OperationAdminBottomSheet extends StatelessWidget {
  final Employee employee;

  const OperationAdminBottomSheet({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeamsController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operations',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.AppBlackColor,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.close,
                  size: 24.r,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Employee Info
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.AppBlackColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      employee.name.isNotEmpty
                          ? employee.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.AppBlackColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        employee.role,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    employee.status.displayName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Operation Options
          _buildOperationButton(
            icon: Icons.info_outline,
            title: 'View Details',
            onTap: () {
              Get.back();
              Get.snackbar(
                'View Details',
                'Opening ${employee.name}\'s profile...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),

          _buildOperationButton(
            icon: Icons.edit_outlined,
            title: 'Edit Information',
            onTap: () {
              Get.back();
              Get.snackbar(
                'Edit',
                'Opening edit form...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade200),

          if (employee.status == EmployeeStatus.pending)
            _buildOperationButton(
              icon: Icons.check_circle_outline,
              title: 'Activate Employee',
              onTap: () {
                controller.updateEmployeeStatus(
                  employee.id,
                  EmployeeStatus.active,
                );
                Get.back();
              },
            )
          else if (employee.status == EmployeeStatus.active)
            _buildOperationButton(
              icon: Icons.pause_circle_outline,
              title: 'Deactivate Employee',
              onTap: () {
                controller.updateEmployeeStatus(
                  employee.id,
                  EmployeeStatus.pending,
                );
                Get.back();
              },
            ),

          if (employee.status != EmployeeStatus.removed)
            Divider(height: 1.h, color: Colors.grey.shade200),

          if (employee.status != EmployeeStatus.removed)
            _buildOperationButton(
              icon: Icons.delete_outline,
              title: 'Remove Employee',
              isDestructive: true,
              onTap: () {
                Get.back();
                _showRemoveConfirmation(context, employee, controller);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOperationButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red.shade600 : Colors.grey.shade700,
              size: 22.r,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color:
                      isDestructive
                          ? Colors.red.shade600
                          : AppColors.AppBlackColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(
    BuildContext context,
    Employee employee,
    TeamsController controller,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                Icons.warning_amber_rounded,
                size: 48.r,
                color: Colors.grey.shade700,
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                'Remove Employee?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.AppBlackColor,
                ),
              ),
              SizedBox(height: 8.h),

              // Message
              Text(
                'Are you sure you want to remove ${employee.name}? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        controller.removeEmployee(employee.id);
                        Get.back();
                      },
                      child: Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: AppColors.AppBlackColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Remove',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
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
