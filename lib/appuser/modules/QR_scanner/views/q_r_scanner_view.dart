import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/q_r_scanner_controller.dart';

class QRScannerView extends StatelessWidget {
  final Color primaryColor;
  final controller = Get.put(QRScannerController());

  QRScannerView({Key? key, this.primaryColor = const Color(0xFFFF6B35)})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mobile Scanner View
          MobileScanner(
            controller: controller.scannerController,
            onDetect: controller.handleBarcode,
          ),

          // Custom Overlay
          _buildCustomOverlay(),

          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),

                Spacer(),

                // Center content
                _buildCenterContent(),

                Spacer(),

                // Bottom Button
                _buildBottomButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomOverlay() {
    return Center(
      child: SizedBox(
        width: 300.w,
        height: 300.w,
        child: Stack(
          children: [
            // Animated scanning line
            AnimatedBuilder(
              animation: controller.scanLineAnimation,
              builder: (context, child) {
                return Positioned(
                  top: controller.scanLineAnimation.value * 300.w,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryColor,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Animated corners
            AnimatedBuilder(
              animation: controller.pulseAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Top Left
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCorner(
                        primaryColor,
                        controller.pulseAnimation.value,
                        isTopLeft: true,
                      ),
                    ),
                    // Top Right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildCorner(
                        primaryColor,
                        controller.pulseAnimation.value,
                        isTopRight: true,
                      ),
                    ),
                    // Bottom Left
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildCorner(
                        primaryColor,
                        controller.pulseAnimation.value,
                        isBottomLeft: true,
                      ),
                    ),
                    // Bottom Right
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCorner(
                        primaryColor,
                        controller.pulseAnimation.value,
                        isBottomRight: true,
                      ),
                    ),
                  ],
                );
              },
            ),

            // Border glow effect
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(
    Color color,
    double opacity, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return SizedBox(
      width: 50.w,
      height: 50.w,
      child: CustomPaint(
        painter: CornerPainter(
          color: color.withOpacity(opacity),
          isTopLeft: isTopLeft,
          isTopRight: isTopRight,
          isBottomLeft: isBottomLeft,
          isBottomRight: isBottomRight,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Get.back(),
          ),

          Row(
            children: [
              // Flash Button
              Obx(
                () => _buildIconButton(
                  icon:
                      controller.isFlashOn.value
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                  onTap: controller.toggleFlash,
                  isActive: controller.isFlashOn.value,
                ),
              ),

              SizedBox(width: 12.w),

              // Gallery Button
              _buildIconButton(
                icon: Icons.photo_library_rounded,
                onTap: controller.pickImageFromGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient:
              isActive
                  ? LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  )
                  : null,
          color: isActive ? null : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? primaryColor : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                  : null,
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }

  Widget _buildCenterContent() {
    return Column(
      children: [
        // Title with animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
        ),

        SizedBox(height: 80.h),

        // Main title
        Text(
          'Scan QR Code',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Subtitle
        SizedBox(
          width: 280.w,
          child: Text(
            'Position the QR code within the frame to scan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        children: [
          // Instructions
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Make sure the QR code is clearly visible',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Show My QR Code Button
          GestureDetector(
            onTap: controller.showMyQRCode,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Show my QR Code',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter pour les coins animés
class CornerPainter extends CustomPainter {
  final Color color;
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  CornerPainter({
    required this.color,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();
    final cornerLength = size.width;

    if (isTopLeft) {
      path.moveTo(cornerLength, 0);
      path.lineTo(0, 0);
      path.lineTo(0, cornerLength);
    } else if (isTopRight) {
      path.moveTo(0, 0);
      path.lineTo(cornerLength, 0);
      path.lineTo(cornerLength, cornerLength);
    } else if (isBottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, cornerLength);
      path.lineTo(cornerLength, cornerLength);
    } else if (isBottomRight) {
      path.moveTo(0, cornerLength);
      path.lineTo(cornerLength, cornerLength);
      path.lineTo(cornerLength, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
