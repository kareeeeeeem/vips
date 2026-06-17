import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/business_registration_controller.dart';

class TimeScheduleWidget extends GetView<BusinessRegistrationController> {
  const TimeScheduleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Schedule time',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() {
          return Column(
            children: controller.schedule.keys.map((day) {
              final data = controller.schedule[day]!;
              final isEnabled = data['enabled'] as bool;
              final timeString = data['time'] as String;

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80.w,
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        // Toggle logic
                        final copy = Map<String, Map<String, dynamic>>.from(controller.schedule);
                        copy[day]!['enabled'] = !isEnabled;
                        controller.schedule.value = copy;
                      },
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: isEnabled ? const Color(0xFF10B981) : Colors.transparent,
                          border: Border.all(
                            color: isSelectedColor(isEnabled),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          isEnabled ? Icons.add : Icons.remove,
                          color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Color isSelectedColor(bool isEnabled) {
    return isEnabled ? const Color(0xFF10B981) : const Color(0xFFD1D5DB);
  }
}
