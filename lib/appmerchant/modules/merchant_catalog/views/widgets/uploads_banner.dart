import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadsBanner extends StatelessWidget {
  final int remaining;
  final int total;
  final VoidCallback? onUpgrade;

  const UploadsBanner({
    Key? key,
    this.remaining = 8,
    this.total = 2, // design says 8/2
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Remaining uploads:',
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
              ),
              SizedBox(width: 4.w),
              Text(
                '8/2', // Matches mock
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
              ),
            ],
          ),
          GestureDetector(
            onTap: onUpgrade ?? () {}, // Trigger onUpgrade
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Text(
                    'Upgrade Package',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_ios, size: 10.sp, color: const Color(0xFF1F2937)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
