import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContactController extends GetxController {
  final RxList<Map<String, dynamic>> contacts = <Map<String, dynamic>>[].obs;

  void navigateToSearch() {
    Get.toNamed('/search');
  }

  void showFilterSheet() {}

  Widget _buildFilterSheet() {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Filter Contacts',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          // Add filter options here
          Text('Filter options coming soon...'),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
