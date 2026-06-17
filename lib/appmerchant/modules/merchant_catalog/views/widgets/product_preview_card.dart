import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductPreviewCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String points;
  final String sales;
  final String tag;

  const ProductPreviewCard({
    Key? key,
    this.imageUrl = 'https://via.placeholder.com/150', // Mock burger image
    this.title = 'McDonald\'s Spicy meal',
    this.price = '250',
    this.points = '60',
    this.sales = '12K',
    this.tag = 'Recommended',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image part with Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Container(
                  height: 120.h,
                  width: double.infinity,
                  color: const Color(0xFFF3F4F6),
                  child: Center(
                    child: Icon(Icons.fastfood, size: 60.sp, color: const Color(0xFFD1D5DB)), // Fallback icon instead of network image for safety
                  ),
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Positioned(
                bottom: -15.h,
                right: 16.w,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Icon(Icons.favorite_border, color: const Color(0xFFEF4444), size: 16.sp),
                ),
              ),
            ],
          ),
          
          // Details part
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('$price VIPs', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: const Color(0xFFF59E0B), size: 12.sp),
                              SizedBox(width: 4.w),
                              Text('$points Pt', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFFF59E0B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: const Color(0xFFEF4444), size: 14.sp),
                    SizedBox(width: 4.w),
                    Text('$sales Sold', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
