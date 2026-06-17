import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MerchantPrivacyView extends StatelessWidget {
  const MerchantPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'VIPs Merchant stores account and transaction information to provide billing, rewards, and reporting features. Merchant data is processed securely and shared only as required for service operations and legal compliance.',
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151), height: 1.5),
        ),
      ),
    );
  }
}
