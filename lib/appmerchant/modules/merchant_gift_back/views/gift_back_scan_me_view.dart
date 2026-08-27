import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';
import '../controllers/merchant_gift_back_controller.dart';

class GiftBackScanMeView extends StatefulWidget {
  const GiftBackScanMeView({super.key});

  @override
  State<GiftBackScanMeView> createState() => _GiftBackScanMeViewState();
}

enum _ScanScreenState { scan, invalid, showMyQr }

class _GiftBackScanMeViewState extends State<GiftBackScanMeView> {
  final MobileScannerController _scannerController = MobileScannerController();
  _ScanScreenState _screenState = _ScanScreenState.scan;
  bool _isFlashOn = false;
  bool _handledScan = false;
  String? _merchantId;

  @override
  void initState() {
    super.initState();
    _loadMerchantId();
  }

  Future<void> _loadMerchantId() async {
    final response = await ApiService().get('/merchant/profile');
    if (!mounted) return;
    if (response.success && response.data is Map) {
      setState(() => _merchantId = response.data['_id']?.toString());
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handledScan || _screenState != _ScanScreenState.scan) return;
    final String? value = capture.barcodes.first.rawValue;
    // Consumer-side QR is generated as 'VIPS_USER_<mongoId>' — see
    // vips_id_view.dart. Anything else scanned isn't a VIPs customer code.
    final match = value != null ? RegExp(r'^VIPS_USER_([a-fA-F0-9]{24})$').firstMatch(value.trim()) : null;

    if (match == null) {
      if (!mounted) return;
      setState(() => _screenState = _ScanScreenState.invalid);
      return;
    }

    _handledScan = true;
    final userId = match.group(1)!;

    final response = await ApiService().get('/merchant/gift-back/lookup?userId=$userId');
    if (!mounted) return;

    if (response.success && response.data is Map) {
      final data = response.data as Map;
      Get.find<MerchantGiftBackController>().applyScannedCustomer(
        userId: data['userId'].toString(),
        phone: data['phone']?.toString() ?? '',
        fullName: data['fullName']?.toString(),
      );
      // This screen is only ever opened from the form (onScanQR), so return
      // to it rather than pushing a second copy on top — the old
      // `Get.toNamed` left a Form → Scan → Form stack, so Cancel on the form
      // dropped the merchant back onto the camera.
      Get.back();
    } else {
      setState(() => _screenState = _ScanScreenState.invalid);
      safeSnackbar('Not Found', response.message, snackPosition: SnackPosition.BOTTOM);
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      _handledScan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenState == _ScanScreenState.showMyQr ? const Color(0xFFF59E0B) : Colors.black,
      body: SafeArea(
        child: _screenState == _ScanScreenState.showMyQr ? _buildShowMyQr() : _buildScannerStates(),
      ),
    );
  }

  Widget _buildScannerStates() {
    return Stack(
      children: [
        if (_screenState == _ScanScreenState.scan)
          MobileScanner(controller: _scannerController, onDetect: _onDetect)
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1F2937), Color(0xFF111827)],
              ),
            ),
          ),
        Container(color: Colors.black.withValues(alpha: 0.30)),
        _buildTopBar(),
        Center(
          child: _screenState == _ScanScreenState.invalid ? _buildInvalidState() : _buildScanState(),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 24.h,
          child: _buildBottomButton(),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 12.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _topCircleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Get.back()),
          Row(
            children: [
              _topCircleButton(
                icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                onTap: () async {
                  await _scannerController.toggleTorch();
                  if (!mounted) return;
                  setState(() => _isFlashOn = !_isFlashOn);
                },
              ),
              SizedBox(width: 8.w),
              _topCircleButton(
                icon: Icons.qr_code_2_rounded,
                onTap: () => setState(() => _screenState = _ScanScreenState.showMyQr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 16.sp),
      ),
    );
  }

  Widget _buildScanState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Scan QR Code here',
          style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 220.w,
          height: 220.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
          ),
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, child: _corner()),
              Positioned(top: 0, right: 0, child: Transform.rotate(angle: 1.57, child: _corner())),
              Positioned(bottom: 0, left: 0, child: Transform.rotate(angle: -1.57, child: _corner())),
              Positioned(bottom: 0, right: 0, child: Transform.rotate(angle: 3.14, child: _corner())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _corner() {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white, width: 3.w), left: BorderSide(color: Colors.white, width: 3.w)),
      ),
    );
  }

  Widget _buildInvalidState() {
    return Container(
      width: 300.w,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: const Color(0xFFF3F4F6),
            child: Icon(Icons.qr_code_scanner_rounded, color: const Color(0xFF9CA3AF), size: 30.sp),
          ),
          SizedBox(height: 14.h),
          Text('Invalid QR Code', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
          SizedBox(height: 8.h),
          Text(
            'Please check if the QR is readable and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final bool isInvalid = _screenState == _ScanScreenState.invalid;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isInvalid) {
            setState(() => _screenState = _ScanScreenState.scan);
            return;
          }
          setState(() => _screenState = _ScanScreenState.showMyQr);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text(
          isInvalid ? 'Scan Again' : 'Show my QR Code',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildShowMyQr() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _screenState = _ScanScreenState.scan),
                child: Text('Done', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF065F46), fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Scan', style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        SizedBox(height: 28.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 32.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Text(
                'Present your QR-code\nfor scanning',
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: 180.w,
                height: 180.w,
                child: _merchantId == null
                    ? const Center(child: CircularProgressIndicator())
                    : QrImageView(
                        data: 'vips_merchant_$_merchantId',
                        version: QrVersions.auto,
                        size: 180.w,
                        gapless: false,
                      ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Text(
            'VIPsApp.com',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
