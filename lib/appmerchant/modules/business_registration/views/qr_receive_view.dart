import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';

class QrReceiveView extends StatefulWidget {
  const QrReceiveView({super.key});

  @override
  State<QrReceiveView> createState() => _QrReceiveViewState();
}

class _QrReceiveViewState extends State<QrReceiveView> {
  bool _isLoading = true;
  bool _isExporting = false;
  String _merchantId = '';

  @override
  void initState() {
    super.initState();
    _loadMerchantId();
  }

  Future<void> _loadMerchantId() async {
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        _merchantId = response.data['_id']?.toString() ?? '';
      }
    } catch (_) {
      // Keep _merchantId empty; UI shows a fallback below.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Renders the same QR the screen displays into a real PNG file.
  /// "Download" used to just copy the merchant id to the clipboard and
  /// "Print" was a toast telling the merchant to connect a printer — neither
  /// produced anything the merchant could actually save, send to a printer, or
  /// stick on the counter.
  Future<File?> _renderQrToFile() async {
    try {
      final painter = QrPainter(
        data: _merchantId,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF1F2937),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF1F2937),
        ),
      );
      final ByteData? bytes =
          await painter.toImageData(1024, format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      final file = File(
        '${Directory.systemTemp.path}/vips-merchant-qr-$_merchantId.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      return file;
    } catch (e) {
      debugPrint('QR export failed: $e');
      return null;
    }
  }

  Future<void> _exportQr({required String subject, required String text}) async {
    if (_merchantId.isEmpty || _isExporting) return;
    setState(() => _isExporting = true);
    try {
      final file = await _renderQrToFile();
      if (file == null) {
        Get.snackbar('Error', 'Could not generate the QR image',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text,
          subject: subject,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1F2937), size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'VIPsApp Receive',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E40AF),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              children: [
                // Alert Box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: const Color(0xFFFFB800), size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          '65% businessmen saw their business increase after sharing their visiting card',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // QR Code Display
                Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_isLoading)
                        SizedBox(
                          height: 200.sp,
                          child: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                        )
                      else if (_merchantId.isNotEmpty)
                        QrImageView(
                          data: _merchantId,
                          version: QrVersions.auto,
                          size: 200.sp,
                          backgroundColor: Colors.white,
                        )
                      else
                        Icon(Icons.qr_code_2, size: 200.sp, color: const Color(0xFF1F2937)),
                      SizedBox(height: 24.h),
                      Text(
                        'QR Address',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _merchantId.isNotEmpty ? 'ID: $_merchantId' : (_isLoading ? 'Loading…' : 'ID unavailable'),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E40AF),
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Use VIP' 's App for instant reward transfer. Scan or Place this QRcode for receiving VIPs pt in your wallet Point.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9CA3AF),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Share this QR for instant reward receiving.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(MerchantRoutes.HOME),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Continue to Dashboard',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100.h), // Space for bottom actions
              ],
            ),
          ),

          // Bottom Actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFF3F4F6),
                    const Color(0xFFF3F4F6).withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    Icons.download_rounded,
                    const Color(0xFFFFB800),
                    onTap: _merchantId.isEmpty || _isExporting
                        ? null
                        : () => _exportQr(
                              subject: 'My VIPs store QR code',
                              text: 'Save this QR code to let customers scan '
                                  'your store.',
                            ),
                  ),
                  _buildActionButton(
                    Icons.grid_view_rounded,
                    const Color(0xFFFFB800),
                    onTap: () => Get.offAllNamed(MerchantRoutes.HOME),
                  ),
                  _buildActionButton(
                    Icons.print_rounded,
                    const Color(0xFFEF4444),
                    onTap: _merchantId.isEmpty || _isExporting
                        ? null
                        : () => _exportQr(
                              subject: 'Print my VIPs store QR code',
                              text: 'VIPs store QR code — print and display it '
                                  'at your counter.',
                            ),
                  ),
                  _buildActionButton(
                    Icons.share_rounded,
                    const Color(0xFF1F2937),
                    onTap: _merchantId.isEmpty
                        ? null
                        : () {
                            _exportQr(
                              subject: 'My VIPs store QR code',
                              text: 'Scan my VIPs store QR code to collect '
                                  'points.',
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: onTap == null ? color.withValues(alpha: 0.4) : color, size: 24.sp),
      ),
    );
  }
}
