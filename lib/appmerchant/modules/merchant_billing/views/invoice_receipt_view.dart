import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/core/services/api_service.dart';

class InvoiceReceiptView extends StatefulWidget {
  const InvoiceReceiptView({super.key});

  @override
  State<InvoiceReceiptView> createState() => _InvoiceReceiptViewState();
}

class _InvoiceReceiptViewState extends State<InvoiceReceiptView> {
  String _storeName = 'VIPsApp';
  String _storeAddress = '';

  @override
  void initState() {
    super.initState();
    _loadStoreProfile();
  }

  Future<void> _loadStoreProfile() async {
    try {
      final response = await ApiService().get('/merchant/profile');
      if (response.success && response.data != null) {
        final data = response.data;
        final name = (data['storeName'] ?? data['fullName'] ?? '').toString();
        if (mounted && name.isNotEmpty) {
          setState(() {
            _storeName = name;
            _storeAddress = (data['address'] ?? '').toString();
          });
        }
      }
    } catch (_) {
      // Keep the default branding on failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String headerTitle = args['headerTitle'] ?? 'INVOICE';
    final String transType = args['transType'] ?? 'Sale';
    final String grandTotal = args['grandTotal'] ?? 'D 0.00';
    final String subTotal = args['subTotal'] ?? grandTotal;
    final String invoiceNo = args['invoiceNo'] ?? '#INV-0000';
    final String dateTime = args['dateTime'] ?? '';
    final String paymentMethod = args['paymentMethod'] ?? 'VIPs Point';
    final String vipsPoint = args['vipsPoint'] ?? 'D 0.00';
    final String serviceCharge = args['serviceCharge'] ?? 'D 0.00';
    final List<Map<String, dynamic>> items = (args['items'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList() ?? [];
    final bool isRequest = headerTitle == 'REQUEST';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F4F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'History',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1F2937)),
            onPressed: () => Get.offAllNamed(MerchantRoutes.HOME),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            // Receipt Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: isRequest ? const Color(0xFFF97316) : const Color(0xFFFF8A00),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(headerTitle, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
                          child: Icon(Icons.qr_code, size: 32.sp, color: const Color(0xFF1F2937)),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        // Store Info
                        Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(color: (isRequest ? Colors.orange : Colors.orange).withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: Center(child: Text('V', style: TextStyle(color: const Color(0xFFFF8A00), fontSize: 24.sp, fontWeight: FontWeight.bold))),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_storeName, textAlign: TextAlign.right, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
                                  if (_storeAddress.isNotEmpty)
                                    Text(_storeAddress, textAlign: TextAlign.right, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        
                        // Meta Info
                        if (dateTime.isNotEmpty)
                          _buildReceiptRow('Date & Time', dateTime),
                        _buildReceiptRow('Invoice No', invoiceNo),
                        _buildReceiptRow('Transaction status', 'Paid', valueColor: const Color(0xFF10B981)),
                        _buildReceiptRow('Payment Method', paymentMethod),
                        _buildReceiptRow('Trans Type', transType),
                        
                        SizedBox(height: 16.h),
                        const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                        if (!isRequest && items.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(flex: 3, child: Text('Item Name', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)))),
                              Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)))),
                              Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)))),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ...items.map((item) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(item['name']?.toString() ?? '', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                                ),
                                Expanded(child: Text('${item['qty'] ?? 1}', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)))),
                                Expanded(flex: 2, child: Text(item['amount']?.toString() ?? '', textAlign: TextAlign.right, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)))),
                              ],
                            ),
                          )),
                          SizedBox(height: 8.h),
                          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                        ],
                        SizedBox(height: 16.h),
                        
                        // Calculations
                        _buildReceiptRow('SubTotal', subTotal),
                        _buildReceiptRow('VIPs Point', vipsPoint, valueColor: const Color(0xFF10B981)),
                        _buildReceiptRow('Service Charge', serviceCharge),
                        
                        SizedBox(height: 16.h),
                        const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                        SizedBox(height: 16.h),
                        
                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grand Total', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                            Text(grandTotal, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Bottom Actions (Download/Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  Icons.download_rounded,
                  'Download',
                  onTap: () => SharePlus.instance.share(ShareParams(
                    text: '$headerTitle\nInvoice: $invoiceNo\nTotal: $grandTotal\nPayment: $paymentMethod',
                  )),
                ),
                SizedBox(width: 32.w),
                _buildActionButton(
                  Icons.share_rounded,
                  'Share',
                  onTap: () => SharePlus.instance.share(ShareParams(
                    text: '$headerTitle\nInvoice: $invoiceNo\nTotal: $grandTotal\nPayment: $paymentMethod',
                  )),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Text('© ${DateTime.now().year} VIPs App. All rights reserved', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF1F2937), size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
        ],
      ),
    );
  }
}
