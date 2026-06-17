import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';

class ShippingController extends GetxController {
  final RxList<Map<String, dynamic>> trips =
      <Map<String, dynamic>>[
        {
          'id': 1,
          'title': 'You on McDonald\'s',
          'location': 'McDonald\'s',
          'time': '20:14',
          'date': 'December 17, 2024',
          'icon': Icons.fastfood,
        },
        {
          'id': 2,
          'title': 'Grocery Shopping',
          'location': 'Carrefour',
          'time': '18:30',
          'date': 'December 17, 2024',
          'icon': Icons.shopping_cart,
        },
        {
          'id': 3,
          'title': 'Coffee Break',
          'location': 'Starbucks',
          'time': '15:45',
          'date': 'December 16, 2024',
          'icon': Icons.coffee,
        },
      ].obs;

  // Grouper les trips par date
  Map<String, List<Map<String, dynamic>>> get groupedTrips {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var trip in trips) {
      String date = trip['date'];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(trip);
    }
    return grouped;
  }

  void showCalendar() {
    // TODO: Implémenter le calendrier
  }

  void showFilter() {
    Get.bottomSheet(
      _buildFilterSheet(),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  void showTripOptions(Map<String, dynamic> trip) {
    Get.bottomSheet(
      _buildTripOptionsSheet(trip),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      isScrollControlled: true,
    );
  }

  void deleteTrip(int tripId) {
    trips.removeWhere((trip) => trip['id'] == tripId);
    Get.back();
  }

  void markTrip(int tripId) {
    Get.back();
  }

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
            'Filter Trips',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Text('Filter options coming soon...'),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTripOptionsSheet(Map<String, dynamic> trip) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.AppPrimaryColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 32.h),

          // Trip info card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.AppPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    trip['icon'],
                    color: AppColors.AppPrimaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${trip['location']} • ${trip['time']}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Mark button
          GestureDetector(
            onTap: () => markTrip(trip['id']),
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.AppPrimaryColor, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    color: AppColors.AppPrimaryColor,
                    size: 22.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Mark',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.AppPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Delete button
          GestureDetector(
            onTap: () => deleteTrip(trip['id']),
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 22.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
