import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/business_registration_controller.dart';

class TimeScheduleWidget extends GetView<BusinessRegistrationController> {
  const TimeScheduleWidget({super.key});

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
              final shifts = controller.shiftsFor(day);

              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 80.w,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isEnabled
                                  ? const Color(0xFF4B5563)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              for (var i = 0; i < shifts.length; i++)
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: i == shifts.length - 1 ? 0 : 6.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => controller.editShift(
                                              context, day, i),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 8.h),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color(0xFFE5E7EB)),
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${shifts[i]['open']} - ${shifts[i]['close']}',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: const Color(0xFF6B7280),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Icon(Icons.schedule_rounded,
                                                    size: 14.sp,
                                                    color: const Color(0xFF9CA3AF)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // A second opening can be taken back off;
                                      // the first cannot, because a day with no
                                      // hours is what the day's switch says.
                                      if (shifts.length > 1)
                                        GestureDetector(
                                          onTap: () =>
                                              controller.removeShift(day, i),
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 6.w),
                                            child: Icon(Icons.close,
                                                size: 15.sp,
                                                color: const Color(0xFFEF4444)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Adds another opening for shops that close over the
                        // middle of the day. This used to switch the whole day
                        // on and off, which the checkbox beside it now does.
                        GestureDetector(
                          onTap: () => controller.addShift(context, day),
                          child: Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Icon(Icons.add,
                                color: Colors.white, size: 16.sp),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => controller.toggleDay(day, !isEnabled),
                          child: Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              color: isEnabled
                                  ? const Color(0xFF10B981)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelectedColor(isEnabled),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Icon(
                              isEnabled ? Icons.check : Icons.close,
                              color: isEnabled
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                              size: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isEnabled)
                      Padding(
                        padding: EdgeInsets.only(left: 80.w, top: 4.h),
                        child: Text(
                          'Closed',
                          style: TextStyle(
                              fontSize: 10.5.sp, color: const Color(0xFF9CA3AF)),
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
