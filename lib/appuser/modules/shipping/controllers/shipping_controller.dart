import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../design_system/atoms/app_colors.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class ShippingController extends GetxController {
  final RxList<Map<String, dynamic>> trips = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrips();
  }

  Future<void> loadTrips() async {
    try {
      isLoading.value = true;
      final response = await ApiService().get('/order/trips');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        trips.value = data.map((e) => {
          ...e as Map<String, dynamic>,
          'icon': Icons.directions_car
        }).toList();
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to load trips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Grouper les trips par date
  Map<String, List<Map<String, dynamic>>> get groupedTrips {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var trip in trips) {
      final String date = (trip['date'] as String?) ?? 'Unknown Date';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(trip);
    }
    return grouped;
  }

  Future<void> showCalendar() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
    );
    if (picked != null) {
      await loadTripsInRange(picked.start, picked.end);
    }
  }

  Future<void> loadTripsInRange(DateTime from, DateTime to) async {
    try {
      isLoading.value = true;
      final response = await ApiService().get('/order/trips', queryParams: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        trips.value = data.map((e) => {
          ...e as Map<String, dynamic>,
          'icon': Icons.directions_car
        }).toList();
      }
    } catch (e) {
      safeSnackbar('Error', 'Failed to load trips');
    } finally {
      isLoading.value = false;
    }
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

  void deleteTrip(String tripId) {
    trips.removeWhere((trip) => trip['id']?.toString() == tripId);
    Get.back();
  }

  void markTrip(String tripId) {
    final index = trips.indexWhere((t) => t['id']?.toString() == tripId);
    if (index != -1) {
      trips[index] = {...trips[index], 'isMarked': !(trips[index]['isMarked'] == true)};
      trips.refresh();
    }
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
          Wrap(
            spacing: 8,
            children: ['All', 'Pending', 'Active', 'Completed', 'Cancelled'].map((s) {
              return ActionChip(
                label: Text(s),
                onPressed: () {
                  Get.back();
                  loadTrips();
                },
              );
            }).toList(),
          ),
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
                    color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
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
                        (trip['title'] as String?) ?? 'Trip',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${(trip['location'] as String?) ?? ''} • ${(trip['time'] as String?) ?? ''}',
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
            onTap: () => markTrip(trip['id']?.toString() ?? ''),
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
            onTap: () => deleteTrip(trip['id']?.toString() ?? ''),
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
