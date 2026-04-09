import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'order_request.dart';

class OrderSuccessController extends GetxController {
  // Timer variables
  var remainingSeconds = 30.obs;
  Timer? _timer;

  // QR Code data
  var qrData = ''.obs;

  // Order details
  var orderId = ''.obs;
  var orderAmount = 0.0.obs;
  var orderType = ''.obs;

  // Timer expired state
  var isTimerExpired = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrderDetails();
    _generateQRCode();
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _loadOrderDetails() {
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      orderId.value = args['orderId'] ?? _generateOrderId();
      orderAmount.value = args['total'] ?? 0.0;
      orderType.value = args['orderType'] ?? 'Delivery';
    } else {
      orderId.value = _generateOrderId();
    }
  }

  String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ORD-${timestamp.toString().substring(timestamp.toString().length - 8)}';
  }

  void _generateQRCode() {
    qrData.value = '''
{
  "orderId": "${orderId.value}",
  "amount": ${orderAmount.value},
  "type": "${orderType.value}",
  "timestamp": "${DateTime.now().toIso8601String()}",
  "paymentMethod": "contactless"
}
''';
  }

  void _startTimer() {
    isTimerExpired.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        isTimerExpired.value = true;
      }
    });
  }

  String get formattedTime {
    final minutes = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return "$minutes'$seconds";
  }

  void viewOrderRequest() {
    Get.to(
      () => OrderRequestView(),
      arguments: {'orderId': orderId.value, 'grandTotal': 87.0},
    );
  }

  void goHome() {
    Get.offAllNamed('/home');
  }

  void restartTimer() {
    remainingSeconds.value = 30;
    isTimerExpired.value = false;
    _timer?.cancel();
    _startTimer();
  }

  void closeExpiredOverlay() {
    // Ferme l'overlay sans redémarrer le timer
    isTimerExpired.value = false;
  }
}

class OrderSuccessView extends GetView<OrderSuccessController> {
  const OrderSuccessView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrderSuccessController());
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),

                  // Hourglass Icon
                  _buildHourglassIcon(),

                  SizedBox(height: 20.h),

                  // Contactless Badge with Timer/Restart
                  _buildContactlessBadge(),

                  SizedBox(height: 24.h),

                  // "Scan Me" Title
                  _buildScanMeTitle(),

                  SizedBox(height: 24.h),

                  // QR Code with Timer Expired Overlay
                  _buildQRCodeSection(),

                  SizedBox(height: 24.h),

                  // Success Message
                  _buildSuccessMessage(),

                  SizedBox(height: 30.h),

                  // Buttons
                  _buildButtons(),

                  SizedBox(height: 40.h),
                ],
              ),
            ),

            // Close Button
            Positioned(top: 16.h, left: 16.w, child: _buildCloseButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: controller.goHome,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.close, color: Colors.grey.shade600, size: 20.sp),
      ),
    );
  }

  Widget _buildHourglassIcon() {
    return Container(
      width: 70.w,
      height: 70.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.hourglass_empty_rounded,
        color: Colors.white,
        size: 36.sp,
      ),
    );
  }

  /// Badge avec Contactless + Timer OU Restart (quand expiré)
  Widget _buildContactlessBadge() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contactless Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.contactless_rounded,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Contactless',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0891B2),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Timer OU Restart Button
            controller.isTimerExpired.value
                ? _buildRestartBadge()
                : _buildTimerBadge(),
          ],
        ),
      );
    });
  }

  /// Timer Badge (quand le timer tourne)
  Widget _buildTimerBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            color: const Color(0xFFFF6B35),
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Obx(
            () => Text(
              controller.formattedTime,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF6B35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Restart Badge (quand le timer est expiré)
  Widget _buildRestartBadge() {
    return GestureDetector(
      onTap: controller.restartTimer,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: const Color(0xFFFF6B35),
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'Restart',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanMeTitle() {
    return Text(
      'Scan Me',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111827),
      ),
    );
  }

  /// QR Code avec overlay Timer Expired
  Widget _buildQRCodeSection() {
    return Obx(() {
      return Stack(
        alignment: Alignment.center,
        children: [
          // QR Code Container
          Container(
            width: 220.w,
            height: 220.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Stack(
              children: [
                // QR Code
                QrImageView(
                  data: controller.qrData.value,
                  version: QrVersions.auto,
                  size: 188.w,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF111827),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF111827),
                  ),
                ),

                // Corner Indicators
                ..._buildCorners(),
              ],
            ),
          ),

          // Timer Expired Overlay
          if (controller.isTimerExpired.value) _buildTimerExpiredOverlay(),
        ],
      );
    });
  }

  List<Widget> _buildCorners() {
    return [
      // Top Left
      Positioned(
        top: 0,
        left: 0,
        child: _buildCorner(isTop: true, isLeft: true),
      ),
      // Top Right
      Positioned(
        top: 0,
        right: 0,
        child: _buildCorner(isTop: true, isLeft: false),
      ),
      // Bottom Left
      Positioned(
        bottom: 0,
        left: 0,
        child: _buildCorner(isTop: false, isLeft: true),
      ),
      // Bottom Right
      Positioned(
        bottom: 0,
        right: 0,
        child: _buildCorner(isTop: false, isLeft: false),
      ),
    ];
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return SizedBox(
      width: 24.w,
      height: 24.h,
      child: CustomPaint(
        painter: CornerPainter(
          color: const Color(0xFFFF6B35),
          strokeWidth: 3,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }

  /// Overlay quand le timer expire (sur le QR code) avec bouton Close
  Widget _buildTimerExpiredOverlay() {
    return Container(
      width: 220.w,
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          // Close Button (X)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: controller.closeExpiredOverlay,
              child: Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.grey.shade600,
                  size: 16.sp,
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer Icon
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer_off_outlined,
                    color: const Color(0xFFFF9800),
                    size: 28.sp,
                  ),
                ),

                SizedBox(height: 14.h),

                // Title
                Text(
                  'Timer Expired',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 8.h),

                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'The contactless payment window has expired. Please proceed to view your order or go home.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // Restart Button
                GestureDetector(
                  onTap: controller.restartTimer,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Restart',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Text(
          'Enjoy !',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'See you in the next visit !',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // View Order Request Button
        GestureDetector(
          onTap: controller.viewOrderRequest,
          child: Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8A5B)],
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'View Order Request',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Home Button
        GestureDetector(
          onTap: controller.goHome,
          child: Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Center(
              child: Text(
                'Home',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== CORNER PAINTER ====================

class CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isTop;
  final bool isLeft;

  CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    final length = size.width * 0.8;

    if (isTop && isLeft) {
      path.moveTo(0, length);
      path.lineTo(0, 0);
      path.lineTo(length, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, length);
    } else if (!isTop && isLeft) {
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height);
      path.lineTo(length, size.height);
    } else {
      path.moveTo(size.width, size.height - length);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width - length, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== BINDING ====================

class OrderSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderSuccessController>(() => OrderSuccessController());
  }
}
