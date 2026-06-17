import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoucherPreviewCard extends StatelessWidget {
  final String title;
  final String discount;

  const VoucherPreviewCard({
    Key? key,
    this.title = 'GET YOUR\nVOUCHER',
    this.discount = '25% OFF',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800), // Yellow theme from Image
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern mock
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Icon(Icons.star, size: 120.sp, color: Colors.white.withOpacity(0.2)),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        discount,
                        style: TextStyle(
                          color: const Color(0xFFFFB800),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // M logo placeholder
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('M', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          // Ticket cutouts (mock)
          Positioned(
            left: -10.w,
            top: 50.h,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: -10.w,
            top: 50.h,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
