import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../design_system/atoms/app_colors.dart';
import 'order_details.dart';

class CardDetailsController extends GetxController {
  // Liste des cartes
  final RxList<CardDetails> cards =
      <CardDetails>[
        CardDetails(
          cardNumber: '1234 5678 9012 3456',
          vipPoints: '1500 Points',
          status: 'D1',
        ),
        CardDetails(
          cardNumber: '9876 5432 1098 7654',
          vipPoints: '2300 Points',
          status: 'D5',
        ),
        CardDetails(
          cardNumber: '5432 1098 7654 3210',
          vipPoints: '750 Points',
          status: 'D1',
        ),
        CardDetails(
          cardNumber: '6789 0123 4567 8901',
          vipPoints: '3100 Points',
          status: 'D10',
        ),
      ].obs;

  final RxInt currentCardIndex = 0.obs;
  final RxBool isCardNumberVisible = false.obs;

  void toggleCardNumberVisibility() {
    isCardNumberVisible.toggle();
  }

  void copyCardNumberToClipboard(String cardNumber) {
    Clipboard.setData(ClipboardData(text: cardNumber));
  }

  void displayQr(String cardNumber) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 340.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.AppPrimaryColor.withOpacity(0.15),
                blurRadius: 30,
                offset: Offset(0, 15),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50.h,
                right: -50.w,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.AppPrimaryColor.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -30.h,
                left: -30.w,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.AppPrimaryColor.withOpacity(0.03),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.AppPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 40.sp,
                        color: AppColors.AppPrimaryColor,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Point your camera at this code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // QR Code container with enhanced design
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.AppPrimaryColor.withOpacity(0.15),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.AppPrimaryColor.withOpacity(0.08),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Corner decorations
                          ...List.generate(4, (index) {
                            return Positioned(
                              top: index < 2 ? 0 : null,
                              bottom: index >= 2 ? 0 : null,
                              left: index % 2 == 0 ? 0 : null,
                              right: index % 2 == 1 ? 0 : null,
                              child: Container(
                                width: 20.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top:
                                        index < 2
                                            ? BorderSide(
                                              color: AppColors.AppPrimaryColor,
                                              width: 3,
                                            )
                                            : BorderSide.none,
                                    bottom:
                                        index >= 2
                                            ? BorderSide(
                                              color: AppColors.AppPrimaryColor,
                                              width: 3,
                                            )
                                            : BorderSide.none,
                                    left:
                                        index % 2 == 0
                                            ? BorderSide(
                                              color: AppColors.AppPrimaryColor,
                                              width: 3,
                                            )
                                            : BorderSide.none,
                                    right:
                                        index % 2 == 1
                                            ? BorderSide(
                                              color: AppColors.AppPrimaryColor,
                                              width: 3,
                                            )
                                            : BorderSide.none,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // QR Code
                          QrImageView(
                            data: cardNumber,
                            version: QrVersions.auto,
                            size: 200.w,
                            backgroundColor: Colors.white,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.AppPrimaryColor,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Card number display
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            cardNumber,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Partager le QR code
                              Get.snackbar(
                                'Share',
                                'QR code sharing feature',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.grey.shade100,
                                margin: EdgeInsets.all(16.w),
                                borderRadius: 12.r,
                                duration: Duration(seconds: 2),
                              );
                            },
                            icon: Icon(Icons.share_rounded, size: 18.sp),
                            label: Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.AppPrimaryColor,
                              side: BorderSide(
                                color: AppColors.AppPrimaryColor.withOpacity(
                                  0.3,
                                ),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: Icon(Icons.check_rounded, size: 18.sp),
                            label: Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.AppPrimaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: AppColors
                                  .AppPrimaryColor.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Close button (X)
              Positioned(
                right: 12.w,
                top: 12.h,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade700,
                      size: 22.sp,
                    ),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.all(8.w),
                    constraints: BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
    );
  }

  void navigateToTransferBill() {
    Get.put(OrderDetailsController());
    Get.to(() => OrderDetailsView());
  }
}

class CardDetails {
  final String cardNumber;
  final String vipPoints;
  final String status;

  CardDetails({
    required this.cardNumber,
    required this.vipPoints,
    required this.status,
  });
}

class CardDetailsView extends GetView<CardDetailsController> {
  const CardDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CardDetailsController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Cards',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.AppPrimaryColor,
              size: 24.sp,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Card indicator (moved to top)
            Obx(
              () => Text(
                '${controller.currentCardIndex.value + 1}/${controller.cards.length}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
            ),

            SizedBox(height: 15.h),

            // Carousel
            Expanded(
              child: Obx(
                () => CarouselSlider.builder(
                  itemCount: controller.cards.length,
                  itemBuilder: (context, index, realIndex) {
                    return _buildCardItem(controller.cards[index]);
                  },
                  options: CarouselOptions(
                    height: 450.h,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.85,
                    enlargeFactor: 0.2,
                    onPageChanged: (index, reason) {
                      controller.currentCardIndex.value = index;
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Action buttons row
            _buildActionButtonsRow(),

            SizedBox(height: 20.h),

            // Transfer button
            _buildTransferButton(),

            SizedBox(height: 25.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(CardDetails card) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.AppPrimaryColor,
            AppColors.AppPrimaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.AppPrimaryColor.withOpacity(0.25),
            blurRadius: 25,
            offset: Offset(0, 12),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Décoration de fond - cercles
          Positioned(
            right: -80.w,
            top: -80.h,
            child: Container(
              width: 250.w,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -50.w,
            bottom: -50.h,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // Contenu de la carte
          Padding(
            padding: EdgeInsets.all(28.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(card),
                Spacer(),
                _buildCardNumberSection(card),
                SizedBox(height: 28.h),
                _buildCardDetails(card),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(CardDetails card) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VIP CARD',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                card.status,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => controller.displayQr(card.cardNumber),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Image.network(
              'https://e7.pngegg.com/pngimages/385/840/png-clipart-burma-ooredoo-kuwait-ooredoo-myanmar-telecommunication-business-text-people-thumbnail.png',
              height: 40,
              width: 40,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardNumberSection(CardDetails card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Card Number',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: controller.toggleCardNumberVisibility,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Obx(
                  () => Icon(
                    controller.isCardNumberVisible.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.h),
            GestureDetector(
              onTap: () {
                controller.copyCardNumberToClipboard(card.cardNumber);
              },
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  controller.isCardNumberVisible.value
                      ? card.cardNumber
                      : '• • • • • • • • •  ${card.cardNumber.split(' ').last}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    letterSpacing: 3,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
      ],
    );
  }

  Widget _buildCardDetails(CardDetails card) {
    return Row(
      children: [
        Expanded(child: _buildDetailColumn('Serial Code', card.vipPoints)),
        Container(
          width: 1.5,
          height: 45.h,
          color: Colors.white.withOpacity(0.3),
        ),
        SizedBox(width: 20.w),
        Expanded(child: _buildDetailColumn('Date', '25 Oct 2025')),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.file_download_outlined,
            label: '',
            onTap: () {
              Get.snackbar(
                'Download',
                'Download card feature',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.grey.shade100,
                margin: EdgeInsets.all(16.w),
                borderRadius: 12.r,
                duration: Duration(seconds: 2),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: '',
            onTap: () {
              final card = controller.cards[controller.currentCardIndex.value];
              controller.displayQr(card.cardNumber);
            },
          ),
          _buildActionButton(
            icon: Icons.print_outlined,
            label: '',
            onTap: () {
              Get.snackbar(
                'Print',
                'Print card feature',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.grey.shade100,
                margin: EdgeInsets.all(16.w),
                borderRadius: 12.r,
                duration: Duration(seconds: 2),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: '',
            onTap: () {
              Get.snackbar(
                'Share',
                'Share card feature',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.grey.shade100,
                margin: EdgeInsets.all(16.w),
                borderRadius: 12.r,
                duration: Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.AppPrimaryColor, size: 26.sp),
      ),
    );
  }

  Widget _buildTransferButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.navigateToTransferBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.AppPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.AppPrimaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 24.sp, color: Colors.white),
            SizedBox(width: 12.w),
            Text(
              'View Transfer Bill',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
