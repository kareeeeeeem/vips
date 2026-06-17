import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ShippingOptions extends StatelessWidget {
  final RxBool isDelivery;
  final RxBool isTakeaway;
  final RxBool isDineIn;
  final RxString selectedTime;

  const ShippingOptions({
    Key? key,
    required this.isDelivery,
    required this.isTakeaway,
    required this.isDineIn,
    required this.selectedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 12.h),
        // Toggle Row
        Row(
          children: [
            Expanded(child: Obx(() => _buildToggle('Delivery', isDelivery.value, (val) => isDelivery.value = val!))),
            SizedBox(width: 8.w),
            Expanded(child: Obx(() => _buildToggle('Takeaway', isTakeaway.value, (val) => isTakeaway.value = val!))),
            SizedBox(width: 8.w),
            Expanded(child: Obx(() => _buildToggle('In Dine', isDineIn.value, (val) => isDineIn.value = val!))),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          'Time',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 8.h),
        // Time Pills Row
        Obx(() => Row(
          children: [
            _buildTimePill('15 Min', selectedTime.value == '15 Min'),
            SizedBox(width: 8.w),
            _buildTimePill('30 Min', selectedTime.value == '30 Min'),
            SizedBox(width: 8.w),
            _buildTimePill('45 Min', selectedTime.value == '45 Min'),
            SizedBox(width: 8.w),
            _buildTimePill('+90 Min', selectedTime.value == '+90 Min'),
          ],
        )),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: value ? const Color(0xFFECFDF5) : Colors.transparent, // Very light green if active
        border: Border.all(color: value ? const Color(0xFF10B981) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: value ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill(String time, bool isSelected) {
    return GestureDetector(
      onTap: () => selectedTime.value = time,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 11.sp,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
