import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/merchant_barcode_controller.dart';

class BarcodeGeneratorView extends StatelessWidget {
  const BarcodeGeneratorView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MerchantBarcodeController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Barcode / QR Generator',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
            onPressed: () => Get.back(),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF10B981),
            tabs: const [
              Tab(text: 'Generate'),
              Tab(text: 'Saved'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GenerateTab(ctrl: ctrl),
            _SavedTab(ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

// ─── Generate Tab ─────────────────────────────────────────

class _GenerateTab extends StatelessWidget {
  final MerchantBarcodeController ctrl;
  const _GenerateTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // QR Preview
          Obx(() => Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                if (ctrl.generatedCode.value.isNotEmpty)
                  QrImageView(
                    data: ctrl.generatedCode.value,
                    version: QrVersions.auto,
                    size: 180.w,
                    backgroundColor: Colors.white,
                  )
                else
                  Icon(Icons.qr_code_2_rounded, size: 120.sp, color: const Color(0xFFD1D5DB)),
                SizedBox(height: 16.h),
                Text(
                  ctrl.generatedCode.value.isNotEmpty ? ctrl.generatedCode.value : 'Enter details below',
                  style: TextStyle(
                    fontSize: ctrl.generatedCode.value.length > 20 ? 12.sp : 16.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
          SizedBox(height: 24.h),

          // Input Fields
          TextField(
            controller: ctrl.nameCtrl,
            decoration: InputDecoration(
              labelText: 'Product Name',
              prefixIcon: const Icon(Icons.label_outline, color: Color(0xFF10B981)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF10B981))),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: ctrl.codeCtrl,
            decoration: InputDecoration(
              labelText: 'Product Code (optional)',
              prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF10B981)),
              hintText: 'e.g. PROD-123456',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFF10B981))),
            ),
          ),
          SizedBox(height: 24.h),

          // Action buttons after generation
          Obx(() => ctrl.generatedCode.value.isNotEmpty
              ? Column(children: [
                  _buildActionItem(Icons.copy_rounded, 'Copy Code', 'Copy to clipboard', () {
                    Clipboard.setData(ClipboardData(text: ctrl.generatedCode.value));
                    ctrl.copyCode(ctrl.generatedCode.value);
                  }),
                  _buildActionItem(Icons.save_alt_rounded, 'Save Barcode', 'Save to collection', ctrl.saveBarcode),
                  SizedBox(height: 16.h),
                ])
              : const SizedBox()),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: ctrl.generate,
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              label: const Text('Generate QR Code',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10.r)),
        child: Icon(icon, color: const Color(0xFF10B981), size: 20.sp),
      ),
      title: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
    );
  }
}

// ─── Saved Tab ────────────────────────────────────────────

class _SavedTab extends StatelessWidget {
  final MerchantBarcodeController ctrl;
  const _SavedTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
      }
      if (ctrl.savedBarcodes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2_rounded, size: 64.sp, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 16.h),
              Text('No saved barcodes yet',
                  style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6B7280))),
              SizedBox(height: 8.h),
              Text('Generate and save a QR code to see it here',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF))),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: EdgeInsets.all(24.w),
        itemCount: ctrl.savedBarcodes.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, i) {
          final b = ctrl.savedBarcodes[i];
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: QrImageView(
                    data: b['qrData'] ?? b['code'] ?? 'N/A',
                    version: QrVersions.auto,
                    size: 60.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['productName'] ?? 'Unknown',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      Text(b['code'] ?? '',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Color(0xFF10B981), size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: b['code'] ?? ''));
                    ctrl.copyCode(b['code'] ?? '');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                  onPressed: () => ctrl.deleteBarcode(b['_id']?.toString() ?? ''),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
