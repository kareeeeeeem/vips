import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// Same support contact set used by the merchant app's Help & Support sheet
// (lib/appmerchant/modules/merchant_settings/views/merchant_settings_view.dart)
// — kept in one place so every "Help !" button in the consumer app opens
// the same real contact info. "Real" used to just mean the row existed —
// none of the three rows had a tap handler at all (Email Support didn't
// actually launch mailto:), and Phone/Live Chat displayed a fabricated
// placeholder number and a made-up operating schedule for channels that
// don't exist. Only Email is real; the other two now say so honestly.
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
          _supportOption(
            Icons.email_outlined,
            'Email Support',
            'support@vipsapp.com',
            accentColor,
            onTap: () => _launchMailto('support@vipsapp.com', 'VIPs Help'),
          ),
          // Phone Support and Live Chat used to sit here permanently subtitled
          // "Coming soon" — no support line and no chat backend exists, so they
          // were two rows that could never do anything. Email support is real.
          SizedBox(height: 16.h),
        ],
      ),
    ),
    backgroundColor: Colors.transparent,
  );
}

Future<void> _launchMailto(String email, String subject) async {
  final uri = Uri.parse('mailto:$email?subject=$subject');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Widget _supportOption(IconData icon, String title, String subtitle, Color accentColor, {VoidCallback? onTap}) {
  final row = Row(
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
  );

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: onTap == null
        ? row
        : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8.r), child: row),
  );
}
