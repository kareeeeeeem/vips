import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_partnership_controller.dart';

class MerchantOnboardingView extends GetView<MerchantPartnershipController> {
  const MerchantOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.skip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingData.length,
                itemBuilder: (context, index) {
                  final item = controller.onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Placeholder
                        Container(
                          height: 240.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.storefront_outlined,
                              size: 80,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // Title
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Subtitle
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Steps (1, 2, 3)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStepCircle(1, index == 0),
                            _buildStepLine(),
                            _buildStepCircle(2, index == 1),
                            _buildStepLine(),
                            _buildStepCircle(3, index == 2),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Section: Watch Video & Next
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Watch Video Banner
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.play_circle_fill,
                            color: const Color(0xFFEF4444),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Watch Video to Learn more About Loyalty Points',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Watch Video >>',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFFEF4444),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Dot Indicator & Next Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Obx(() => Row(
                            children: List.generate(
                              controller.onboardingData.length,
                              (index) => Container(
                                margin: EdgeInsets.only(right: 6.w),
                                width: controller.currentPage.value == index
                                    ? 24.w
                                    : 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: controller.currentPage.value == index
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFD1D5DB),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          )),

                      // Next Button
                      ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          minimumSize: Size(120.w, 50.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int number, bool isActive) {
    return Container(
      width: 28.w,
      height: 28.h,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.transparent : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF9CA3AF),
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 30.w,
      height: 1.5.h,
      color: const Color(0xFFD1D5DB),
    );
  }
}
