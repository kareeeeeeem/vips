import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/business_registration_controller.dart';

class CategorySheet extends GetView<BusinessRegistrationController> {
  const CategorySheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'latin': 'Restaurants', 'arabic': 'مطاعم ومقاهي'},
      {'latin': 'Tourism', 'arabic': 'ترفيه وسياحة'},
      {'latin': 'Electronics', 'arabic': 'إلكترونيات'},
      {'latin': 'Food', 'arabic': 'غذائية و تنظيف'},
      {'latin': 'Services', 'arabic': 'خدمات و حرف'},
      {'latin': 'Clothes', 'arabic': 'ملابس وأحذية'},
      {'latin': 'Bakery', 'arabic': 'مخابز وحلويات'},
      {'latin': 'Makeup', 'arabic': 'جمال و عناية'},
      {'latin': 'Education', 'arabic': 'تعلم'},
      {'latin': 'Health', 'arabic': 'صحة و رياضة'},
      {'latin': 'Other', 'arabic': 'أخرى'},
    ];

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E40AF),
            ),
          ),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: categories.map((catData) {
              return Obx(() {
                final isSelected = controller.category.value == catData['latin'];
                return GestureDetector(
                  onTap: () {
                    controller.category.value = catData['latin']!;
                    Get.back();
                  },
                  child: Container(
                    width: (Get.width - 48.w - 12.w) / 2, // 2 items per row
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFB800) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFB800) : const Color(0xFFD1D5DB),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFB800),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                catData['arabic']!,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                '#${catData['latin']}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }
}
