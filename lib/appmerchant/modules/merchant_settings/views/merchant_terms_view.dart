import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MerchantTermsView extends StatelessWidget {
  const MerchantTermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'By using VIPs Merchant, you agree to use the platform for lawful business transactions, maintain accurate merchant information, and honor issued rewards and invoices. Misuse, fraud, or policy violations may result in account suspension.',
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151), height: 1.5),
        ),
      ),
    );
  }
}
