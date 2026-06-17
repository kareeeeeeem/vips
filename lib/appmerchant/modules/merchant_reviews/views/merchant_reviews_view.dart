import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MerchantReviewsView extends StatelessWidget {
  const MerchantReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reviews & Ratings',
          style: TextStyle(color: const Color(0xFF1F2937), fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border_outlined, size: 80.sp, color: const Color(0xFFF59E0B)),
            SizedBox(height: 16.h),
            Text('No reviews yet', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4B5563))),
            SizedBox(height: 8.h),
            Text('Customer reviews will appear here.', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}
