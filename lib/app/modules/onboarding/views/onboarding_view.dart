import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(child: Obx(() => _buildContent())),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 16.h),

          // Language Tabs en haut (seulement sur la page de bienvenue)
          _buildLanguageTabs(),

          SizedBox(height: 24.h),

          // Main Content
          Expanded(child: _buildPageView()),

          SizedBox(height: 32.h),

          // Bottom Navigation
          _buildBottomNavigation(),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // Widget pour les tabs de langue
  Widget _buildLanguageTabs() {
    return Obx(
      () => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLanguageTab('EN', 'en', Icons.language),
            SizedBox(width: 40.w),
            _buildLanguageTab('FR', 'fr', Icons.language),
            SizedBox(width: 40.w),
            _buildLanguageTab('عربي', 'ar', Icons.language),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTab(String label, String code, IconData icon) {
    final isSelected = controller.selectedLanguage.value == code;

    return GestureDetector(
      onTap: () => controller.changeLanguage(code),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color:
                    isSelected
                        ? AppColors.AppPrimaryColor
                        : Colors.grey.shade400,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? AppColors.AppPrimaryColor
                          : Colors.grey.shade400,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40.w,
            height: 2.h,
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.AppPrimaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsPage(OnboardingPageData page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône de document / conditions
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.AppPrimaryColor.withOpacity(0.7),
                  AppColors.AppPrimaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.AppPrimaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.policy_rounded,
                color: Colors.white,
                size: 60.sp,
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'SF Pro Display',
              color: const Color(0xFF1E293B),
              height: 1.5,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Text',
              color: const Color(0xFF64748B),
              height: 1.5,
              letterSpacing: -0.1,
            ),
          ),

          SizedBox(height: 32.h),

          // Checkbox pour accepter les CGU
          GetBuilder(
            init: controller,
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  final isChecked = page.isConditionsChecked ?? false;
                  controller.toggleConditionsAcceptance(!isChecked);
                  controller.update();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                          (page.isConditionsChecked ?? false)
                              ? AppColors.AppPrimaryColor
                              : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color:
                              (page.isConditionsChecked ?? false)
                                  ? AppColors.AppPrimaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color:
                                (page.isConditionsChecked ?? false)
                                    ? AppColors.AppPrimaryColor
                                    : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child:
                            (page.isConditionsChecked ?? false)
                                ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16.sp,
                                )
                                : null,
                      ),

                      SizedBox(width: 12.w),

                      // Text
                      Expanded(
                        child: Text(
                          'I accept the Terms and Conditions',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SF Pro Text',
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: controller.skipOnboarding,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontFamily: 'SF Pro Display',
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.pages.length,
      itemBuilder: (context, index) {
        final page = controller.pages[index];
        switch (page.type) {
          case OnboardingPageType.welcome:
            return _buildWelcomePage(page);
          case OnboardingPageType.standard:
            return _buildStandardPage(page);
          case OnboardingPageType.conditions:
            return _buildConditionsPage(page);
          default:
            return _buildStandardPage(page);
        }
      },
    );
  }

  Widget _buildWelcomePage(OnboardingPageData page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Container
        Image.asset(
          'assets/icons/onbordingfirst.png',
          //color: Colors.white,
        ),

        SizedBox(height: 32.h),

        // Title
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro Display',
            color: const Color(0xFF1E293B),
            height: 1.5,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 24.h),

        // Subtitle
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.AppPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.AppPrimaryColor,
              fontFamily: 'SF Pro Display',
              letterSpacing: 0.2,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Description
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Text',
              color: const Color(0xFF64748B),
              height: 1.6,
              letterSpacing: -0.1,
            ),
          ),
        ),

        SizedBox(height: 32.h),
      ],
    );
  }

  // Méthode pour afficher les CGU
  void _showTermsAndConditions() {
    Get.bottomSheet(
      Container(
        height: 0.8.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle bar
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.sp),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade200),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTermSection(
                      '1. Acceptance of Terms',
                      'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
                    ),
                    SizedBox(height: 16.h),
                    _buildTermSection(
                      '2. Use License',
                      'Permission is granted to temporarily download one copy of the materials on VIPs App for personal, non-commercial transitory viewing only.',
                    ),
                    SizedBox(height: 16.h),
                    _buildTermSection(
                      '3. Disclaimer',
                      'The materials on VIPs App are provided on an \'as is\' basis. VIPs App makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                    ),
                    SizedBox(height: 16.h),
                    _buildTermSection(
                      '4. Limitations',
                      'In no event shall VIPs App or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on VIPs App.',
                    ),
                    SizedBox(height: 16.h),
                    _buildTermSection(
                      '5. Privacy Policy',
                      'Your use of VIPs App is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the Site and informs users of our data collection practices.',
                    ),
                    SizedBox(height: 16.h),
                    _buildTermSection(
                      '6. Modifications',
                      'VIPs App may revise these terms of service for its app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.',
                    ),
                  ],
                ),
              ),
            ),

            // Accept Button
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // Auto-cocher la checkbox après avoir lu les CGU
                    controller.toggleConditionsAcceptance(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.AppPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'I Understand',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontFamily: 'SF Pro Display',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            fontFamily: 'SF Pro Text',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStandardPage(OnboardingPageData page) {
    return Column(
      children: [
        // Image Container
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.AppPrimaryColor.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.r),
              child: Image.asset(page.image!, fit: BoxFit.cover),
            ),
          ),
        ),

        SizedBox(height: 40.h),

        // Content Section
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Subtitle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  page.subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppPrimaryColor,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              ),

              SizedBox(height: 16.h),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    fontFamily: 'SF Pro Text',
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Column(
      children: [
        // Progress indicator avec points circulaires
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Generate circular indicators for all pages
            ...List.generate(controller.pages.length, (index) {
              final isActive = controller.currentIndex == index;
              return Container(
                margin: EdgeInsets.only(
                  right: index < controller.pages.length - 1 ? 8.w : 0,
                ),
                width: isActive ? 12.w : 8.w,
                height: isActive ? 12.h : 8.h,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? AppColors.AppPrimaryColor
                          : const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              );
            }),

            SizedBox(width: 12.w),

            Text(
              '${controller.currentIndex + 1}/${controller.pages.length}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'SF Pro Text',
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),

        SizedBox(height: 32.h),

        // Boutons Continue et Skip
        Row(
          children: [
            // Skip button (comme dans l'image avec bordure)
            if (controller.currentIndex != 4)
              Expanded(
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28.r),
                      onTap: controller.skipOnboarding,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SF Pro Display',
                            color: Colors.grey.shade600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (controller.currentIndex != 4) SizedBox(width: 12.w),

            // Continue button
            Expanded(
              flex: 2,
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.AppPrimaryColor,
                      AppColors.AppPrimaryColor.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.AppPrimaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28.r),
                    onTap: controller.nextPage,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.currentIndex ==
                                    controller.pages.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),

                          SizedBox(width: 8.w),

                          Icon(
                            controller.currentIndex ==
                                    controller.pages.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
