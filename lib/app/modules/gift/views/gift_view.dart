import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/gift_controller.dart';

class GiftView extends GetView<GiftController> {
  const GiftView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(GiftController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [_buildGiftFriendTab(), _buildGiftMeTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 12.w),
          Text(
            'Gift',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: TabBar(
        labelColor: AppColors.AppPrimaryColor,
        unselectedLabelColor: Colors.grey.shade400,
        indicatorColor: AppColors.AppPrimaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        tabs: [Tab(text: 'Gift Friend'), Tab(text: 'Gift Me')],
      ),
    );
  }

  Widget _buildGiftFriendTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildOfferIdSection(),
                SizedBox(height: 30.h),
                Obx(
                  () =>
                      !controller.isExpressSelected.value
                          ? _buildPhoneIdSection()
                          : SizedBox.shrink(),
                ),
                Obx(
                  () =>
                      !controller.isExpressSelected.value
                          ? SizedBox(height: 30.h)
                          : SizedBox.shrink(),
                ),
                _buildExpressOption(),
                SizedBox(height: 30.h),
                _buildHowItWorksSection(),
                SizedBox(height: 16.h),
                _buildRequiredConditionsSection(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildGiftMeTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80.sp, color: Colors.grey.shade300),
            SizedBox(height: 24.h),
            Text(
              'Gift Me',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'This feature allows you to send a gift to yourself',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offer ID',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: TextField(
                  controller: controller.offerIdController,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: '123456',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: controller.scanOfferQR,
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.AppPrimaryColor,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone / ID',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        controller.isUserIdEnabled.value
                            ? Colors.white
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: TextField(
                    controller: controller.userIdController,
                    enabled: controller.isUserIdEnabled.value,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: '#123456',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: controller.openUserSelector,
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Icon(
                  Icons.group,
                  color: AppColors.AppPrimaryColor,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: controller.scanUserQR,
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.AppPrimaryColor,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpressOption() {
    return Obx(() {
      return GestureDetector(
        onTap: controller.toggleExpress,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        controller.isExpressSelected.value
                            ? AppColors.AppPrimaryColor
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                  color:
                      controller.isExpressSelected.value
                          ? AppColors.AppPrimaryColor
                          : Colors.transparent,
                ),
                child:
                    controller.isExpressSelected.value
                        ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                        : null,
              ),
              SizedBox(width: 12.w),
              Text(
                'Express',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Icon(Icons.flash_on, color: Colors.grey.shade600, size: 20.sp),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHowItWorksSection() {
    return _buildExpandableSection(
      'How it works',
      'Welcome to resort paradise we ensure the best service during your stay in bali with an emphasis on customer comfort. Enjoy Balinese specialties, dance and music every Saturday for free at competitive prices.',
    );
  }

  Widget _buildRequiredConditionsSection() {
    return _buildExpandableSection(
      'Required conditions',
      'Welcome to resort paradise we ensure the best service during your stay in bali with an emphasis on customer comfort. Enjoy Balinese specialties, dance and music every Saturday for free at competitive prices.',
    );
  }

  Widget _buildExpandableSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          collapsedIconColor: Colors.grey.shade400,
          iconColor: Colors.grey.shade700,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Text(
              content,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54.h,
              child: OutlinedButton(
                onPressed: controller.cancel,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: AppColors.AppPrimaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Obx(() {
              return SizedBox(
                height: 54.h,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.AppPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors
                        .AppPrimaryColor.withOpacity(0.5),
                  ),
                  child:
                      controller.isLoading.value
                          ? SizedBox(
                            width: 22.w,
                            height: 22.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            'Proceed',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
