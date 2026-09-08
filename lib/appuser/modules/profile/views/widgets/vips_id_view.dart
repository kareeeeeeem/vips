import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/appuser/routes/app_pages.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class VipsIdDialog {
  /// Opens the VIPs ID card.
  ///
  /// A full page rather than a dialog: this is held up to a camera across a
  /// counter, and a card boxed inside a dimmed sheet is smaller and dimmer
  /// than the screen it is being shown on.
  static void show({
    required Color primaryColor,
    required String userId,
    String userName = 'User',
  }) {
    Get.to<void>(
      () => VipsIdPage(
        primaryColor: primaryColor,
        userId: userId,
        userName: userName,
      ),
      fullscreenDialog: true,
    );
  }
}

class VipsIdPage extends StatelessWidget {
  final Color primaryColor;
  final String userId;
  final String userName;

  const VipsIdPage({
    super.key,
    required this.primaryColor,
    required this.userId,
    this.userName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        title: Text('My VIPs ID',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: VipsIdContent(
            primaryColor: primaryColor,
            userId: userId,
            userName: userName,
          ),
        ),
      ),
    );
  }
}

class VipsIdContent extends StatefulWidget {
  final Color primaryColor;
  final String userId;
  final String userName;

  const VipsIdContent({super.key,
    required this.primaryColor,
    required this.userId,
    this.userName = 'User',
  });

  @override
  State<VipsIdContent> createState() => _VipsIdContentState();
}

class _VipsIdContentState extends State<VipsIdContent> {
  /// The short id a person can read out. Falls back to the account id only
  /// while it loads — the long form still resolves, so a scan works either
  /// way, but it is never what the customer is asked to read.
  String? _vipsId;
  bool _loading = true;

  Color get primaryColor => widget.primaryColor;
  String get userId => widget.userId;
  String get userName => widget.userName;

  /// What the QR carries, and what the ID field shows.
  String get _shownId => _vipsId ?? userId;
  String get _qrData => _vipsId != null ? 'VIPS_ID_$_vipsId' : 'VIPS_USER_$userId';

  @override
  void initState() {
    super.initState();
    _loadVipsId();
  }

  Future<void> _loadVipsId() async {
    try {
      final response = await ApiService().get('/user/vips-id');
      if (!mounted) return;
      if (response.success && response.data is Map) {
        setState(() {
          _vipsId = '${(response.data as Map)['vipsId'] ?? ''}';
          if (_vipsId!.isEmpty) _vipsId = null;
          _loading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('vips id load failed: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

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
                      data: _qrData,
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
                            _loading ? 'ID: …' : 'ID: $_shownId',
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
