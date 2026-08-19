import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/appuser/routes/app_pages.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class VipsIdDialog {
  static void show({
    required Color primaryColor,
    required String userId,
    String userName = 'User',
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: VipsIdContent(
          primaryColor: primaryColor,
          userId: userId,
          userName: userName,
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class VipsIdContent extends StatelessWidget {
  final Color primaryColor;
  final String userId;
  final String userName;

  const VipsIdContent({super.key,
    required this.primaryColor,
    required this.userId,
    this.userName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: primaryColor,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'VIPsApp Receive',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h),

                  // QR Code Card
                  Container(
                    padding: EdgeInsets.all(30.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: 'VIPS_USER_$userId',
                      version: QrVersions.auto,
                      size: 180.w,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(8.w),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // QR Address Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'QR Address',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // ID Display with Copy Button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ID: $userId',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: userId));
                              safeSnackbar(
                                'Copied',
                                'ID copied to clipboard',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: primaryColor,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                                margin: EdgeInsets.all(16.w),
                                borderRadius: 12.r,
                              );
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.copy_rounded,
                                color: primaryColor,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Instructions Text
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Use VIPs App for instant reward transfer. Scan or Place this QRcode for receiving VIPs.pt in your wallet Point.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Share this QR for instant reward receiving.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Labels now match what actually happens — this used to
                // say "Download" over a clipboard copy and "Print" over a
                // text share (no real file save or print dialog exists).
                _buildActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  color: Colors.grey.shade700,
                  primaryColor: primaryColor,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: 'VIPs ID: $userId\nName: $userName'));
                    safeSnackbar('Copied', 'VIPs ID details copied to clipboard', snackPosition: SnackPosition.BOTTOM);
                  },
                ),
                _buildActionButton(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan',
                  color: Colors.grey.shade700,
                  primaryColor: primaryColor,
                  onTap: () => Get.toNamed(Routes.Q_R_SCANNER),
                ),
                _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: primaryColor,
                  primaryColor: primaryColor,
                  onTap: () => SharePlus.instance.share(ShareParams(
                    text: 'My VIPs Membership ID: $userId\nName: $userName\nJoin VIPs App to earn diamonds and enjoy exclusive rewards!',
                    subject: 'VIPs ID Card — $userName',
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
        ],
      ),
    );
  }
}
