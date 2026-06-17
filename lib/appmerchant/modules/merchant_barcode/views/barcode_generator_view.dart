import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BarcodeGeneratorView extends StatelessWidget {
  const BarcodeGeneratorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Barcode Generator',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Icon(Icons.barcode_reader, size: 100.sp, color: const Color(0xFF1F2937)),
                  SizedBox(height: 24.h),
                  Text(
                    'PROD-882910',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: 4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            _buildActionItem(Icons.print, 'Print Labels', 'Connect to thermal printer'),
            _buildActionItem(Icons.save_alt, 'Save as PDF', 'Export for offline printing'),
            _buildActionItem(Icons.settings, 'Barcode Settings', 'Format: EAN-13, QR, etc.'),
            
            SizedBox(height: 48.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Generate New Barcode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
