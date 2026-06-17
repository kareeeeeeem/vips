import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_gift_back/views/widgets/gift_back_quick_actions.dart';

class MerchantBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MerchantBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: double.infinity,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background with Notch
          CustomPaint(
            size: Size(double.infinity, 80.h),
            painter: BNBCustomPainter(),
          ),
          
          // Floating Action Button (Center Scan)
          Positioned(
            bottom: 35.h,
            child: GestureDetector(
              onTap: () => showGiftBackQuickActions(context), // Shows the Quick Actions bottom sheet
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ),
          ),

          // Nav Items
          Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, Icons.shield_outlined, 'Brand'),
                _buildNavItem(1, Icons.pie_chart_outline_rounded, 'Rapport'),
                SizedBox(width: 80.w), // Space for the center button
                _buildNavItem(3, Icons.account_balance_wallet_outlined, 'Wallet'),
                _buildNavItem(4, Icons.person_outline_rounded, 'Pro'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = currentIndex == index;
    final Color color = isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start from top-left with some radius
    path.quadraticBezierTo(0, 0, 20, 0); // Corner top-left
    
    // Line to middle
    path.lineTo(size.width * 0.35, 0);
    
    // Smooth Notch
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.42, 10);
    path.arcToPoint(
      Offset(size.width * 0.58, 10),
      radius: const Radius.circular(35),
      clockwise: false,
    );
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20); // Corner top-right
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
