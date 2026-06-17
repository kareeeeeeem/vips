import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/spin_wheel_controller.dart';

class SpinWheelView extends GetView<SpinWheelController> {
  const SpinWheelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SpinWheelController());
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'VIPs Club',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The spinning wheel
                  _buildWheel(),

                  SizedBox(height: 40.h),

                  // Remaining spins text
                  Obx(
                    () => Text(
                      'Spin the wheel: ${controller.remainingSpins.value}x3',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Play Button
          _buildPlayButton(),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // The wheel
        Obx(
          () => Transform.rotate(
            angle: controller.rotation.value * 2 * pi,
            child: Container(
              width: 300.w,
              height: 300.w,
              child: CustomPaint(
                painter: WheelPainter(prizes: controller.prizes),
                child: Container(),
              ),
            ),
          ),
        ),

        // Center button (red circle)
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDC143C), Color(0xFF8B0000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),

        // Indicator dots on the edge
        ..._buildIndicatorDots(),

        // Top indicator (arrow/pointer)
        Positioned(
          top: -10.h,
          child: Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildIndicatorDots() {
    return List.generate(8, (index) {
      double angle = (index * 45) * pi / 180;
      double radius = 150.w;

      return Positioned(
        left: 150.w + radius * cos(angle) - 6.w,
        top: 150.w + radius * sin(angle) - 6.w,
        child: Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: Colors.green.shade400,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 4),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlayButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        // color: Colors.white,
      ),
      child: SafeArea(
        child: Obx(() {
          bool canPlay =
              controller.remainingSpins.value > 0 &&
              !controller.isSpinning.value &&
              controller.canSpin.value;

          return Container(
            width: 200.w,
            height: 56.h,
            decoration: BoxDecoration(
              gradient:
                  canPlay
                      ? LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                      )
                      : null,
              color: canPlay ? null : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow:
                  canPlay
                      ? [
                        BoxShadow(
                          color: Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ]
                      : null,
            ),
            child: ElevatedButton(
              onPressed: canPlay ? controller.spinWheel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                controller.isSpinning.value ? 'Spinning...' : 'Play',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: canPlay ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Custom painter for the wheel
class WheelPainter extends CustomPainter {
  final List<WheelPrize> prizes;

  WheelPainter({required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = (2 * pi) / prizes.length;

    // Draw each section
    for (int i = 0; i < prizes.length; i++) {
      final startAngle = (i * sectionAngle) - (pi / 2);

      // Draw section background
      final paint =
          Paint()
            ..color = prizes[i].color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw white border
      final borderPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Draw icon in the middle of each section
      final iconAngle = startAngle + (sectionAngle / 2);
      final iconRadius = radius * 0.65;
      final iconX = center.dx + iconRadius * cos(iconAngle);
      final iconY = center.dy + iconRadius * sin(iconAngle);

      // Draw white circle background for icon
      final iconBgPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(iconX, iconY), 25, iconBgPaint);

      // Draw icon using TextPainter
      _drawIcon(canvas, prizes[i].icon, prizes[i].color, Offset(iconX, iconY));
    }

    // Draw center white circle
    final centerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 50, centerPaint);
  }

  void _drawIcon(Canvas canvas, IconData icon, Color color, Offset position) {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontSize: 24, fontFamily: icon.fontFamily, color: color),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
