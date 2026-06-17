import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class GiftBackScanMeView extends StatefulWidget {
  const GiftBackScanMeView({Key? key}) : super(key: key);

  @override
  State<GiftBackScanMeView> createState() => _GiftBackScanMeViewState();
}

enum _ScanScreenState { scan, invalid, showMyQr }

class _GiftBackScanMeViewState extends State<GiftBackScanMeView> {
  final MobileScannerController _scannerController = MobileScannerController();
  _ScanScreenState _screenState = _ScanScreenState.scan;
  bool _isFlashOn = false;
  bool _handledScan = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handledScan || _screenState != _ScanScreenState.scan) return;
    _handledScan = true;
    final String? value = capture.barcodes.first.rawValue;
    final bool isValid = value != null && value.trim().isNotEmpty;

    if (!mounted) return;
    setState(() {
      _screenState = isValid ? _ScanScreenState.scan : _ScanScreenState.invalid;
    });

    if (isValid) {
      Get.toNamed(MerchantRoutes.GIFT_BACK_STATUS);
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
        Container(color: Colors.black.withOpacity(0.30)),
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
          color: Colors.black.withOpacity(0.35),
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
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Text(
                'Present your QR-code\nfor scanning',
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp),
              ),
              SizedBox(height: 14.h),
              QrImageView(
                data: 'merchant_vips_qr_123456',
                version: QrVersions.auto,
                size: 180.w,
                gapless: false,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Text(
            'VIPsApp.com',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
