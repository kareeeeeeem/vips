import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BillsFilterWidget extends StatelessWidget {
  final RxString selectedFilter;
  final Function(String) onFilterChanged;

  const BillsFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          // Calendar Icon
          Container(
            width: 35.w,
            height: 35.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF6B35),
                  const Color(0xFFFF6B35).withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.sort_rounded, color: Colors.white, size: 28.sp),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 8.w),
          Container(height: 30, width: 1, color: Colors.grey.shade300),

          // Vertical Divider
          Container(height: 30.h, width: 1.5, color: Colors.grey.shade300),

          SizedBox(width: 12.w),

          // Filter Buttons
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    _buildFilterButton('Products'),
                    SizedBox(width: 8.w),
                    _buildFilterButton('Services'),
                    SizedBox(width: 8.w),
                    _buildFilterButton('History'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = selectedFilter.value == label;

    return GestureDetector(
      onTap: () => onFilterChanged(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          border: !isSelected ? Border.all(color: Colors.grey.shade300) : null,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
