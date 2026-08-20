import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Same support contact set used by the merchant app's Help & Support sheet
// (lib/appmerchant/modules/merchant_settings/views/merchant_settings_view.dart)
// — kept in one place so every "Help !" button in the consumer app opens
// the same real contact info instead of doing nothing.
void showHelpSheet({Color accentColor = const Color(0xFF2E7D5F)}) {
  Get.bottomSheet(
    Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Icon(Icons.support_agent_rounded, size: 48.sp, color: accentColor),
          SizedBox(height: 12.h),
          Text(
            'Help & Support',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Contact our support team for assistance.',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          _supportOption(Icons.email_outlined, 'Email Support', 'support@vips.tn', accentColor),
          _supportOption(Icons.phone_outlined, 'Phone Support', '+216 XX XXX XXX', accentColor),
          _supportOption(Icons.chat_bubble_outline_rounded, 'Live Chat', 'Available 9am - 6pm', accentColor),
          SizedBox(height: 16.h),
        ],
      ),
    ),
    backgroundColor: Colors.transparent,
  );
}

Widget _supportOption(IconData icon, String title, String subtitle, Color accentColor) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20.sp, color: accentColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 2.h),
              Text(subtitle, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    ),
  );
}
