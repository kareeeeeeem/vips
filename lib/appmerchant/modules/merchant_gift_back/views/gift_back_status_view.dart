import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_gift_back_controller.dart';
import '../../../routes/merchant_routes.dart';

class GiftBackStatusView extends StatefulWidget {
  const GiftBackStatusView({Key? key}) : super(key: key);

  @override
  State<GiftBackStatusView> createState() => _GiftBackStatusViewState();
}

enum _GiftBackStatusStep { request, success, invoice, thankYou }

class _GiftBackStatusViewState extends State<GiftBackStatusView> {
  late final MerchantGiftBackController controller;
  _GiftBackStatusStep _step = _GiftBackStatusStep.request;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MerchantGiftBackController>();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRequest = _step == _GiftBackStatusStep.request;
    final bool isInvoice = _step == _GiftBackStatusStep.invoice || _step == _GiftBackStatusStep.thankYou;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isInvoice ? 'History' : '', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: isInvoice,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
          onPressed: () => Get.offAllNamed(MerchantRoutes.BUSINESS_PLAN),
        ),
        actions: isInvoice
            ? [
                IconButton(
                  onPressed: () => Get.snackbar('Saved', 'Invoice bookmarked', snackPosition: SnackPosition.BOTTOM),
                  icon: Icon(Icons.bookmark_border_rounded, size: 20.sp, color: const Color(0xFF9CA3AF)),
                )
              ]
            : null,
      ),
      body: Column(
        children: [
          if (_step == _GiftBackStatusStep.success)
            Expanded(child: _buildSuccessStep())
          else ...[
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Column(
                  children: [
                    _buildInvoiceCard(
                      title: isRequest ? 'REQUEST' : 'INVOICE',
                      amount: isRequest ? 'D 50.000' : 'D 51.000',
                    ),
                    SizedBox(height: 18.h),
                    _buildAmountRow('Gift Back Amount', 'D 50.000'),
                    _buildAmountRow('Addon Cost', 'D 0.000'),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(color: const Color(0xFFFED7AA), borderRadius: BorderRadius.circular(6.r)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF7C2D12), fontWeight: FontWeight.w700)),
                          Text('D 50.000', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF7C2D12), fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildAmountRow('VIPs Gift', 'Vr 100'),
                    _buildAmountRow('Service Charge', 'D 0.000'),
                    _buildAmountRow('Vat/Tax', 'D 1.000'),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grand Total', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800)),
                        Text('D 51.000', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    if (_step == _GiftBackStatusStep.thankYou) ...[
                      Divider(height: 28.h),
                      Text('THANK YOU', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w300, letterSpacing: 1)),
                      SizedBox(height: 4.h),
                      Text('For ordering commend from VIPs App', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF4B5563))),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomActions(isRequest: isRequest),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceCard({required String title, required String amount}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(color: const Color(0xFFF97316), borderRadius: BorderRadius.circular(10.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 30.sp, fontWeight: FontWeight.w900)),
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                  child: Icon(Icons.qr_code_2_rounded, color: const Color(0xFF1F2937), size: 30.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          _buildDetailRow('Trans Type', 'Gift Back'),
          _buildDetailRow('Trans ID', '10013'),
          _buildDetailRow('Brand Name', 'Pizza Hut'),
          _buildDetailRow('Phone', '95910000'),
          _buildDetailRow('Trans Address', 'House: 80, Road: 00, Test City'),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6.r)),
                      child: Icon(Icons.arrow_back_rounded, color: const Color(0xFF16A34A), size: 16.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text('Back', style: TextStyle(fontSize: 11.sp)),
                  ],
                ),
                Text(amount, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF16A34A), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 130.w,
            height: 130.w,
            decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 70.sp),
          ),
          SizedBox(height: 26.h),
          Text('Congrats!', style: TextStyle(fontSize: 44.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF97316))),
          SizedBox(height: 8.h),
          Text('Account Registed\nSuccessfully', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF))),
          SizedBox(height: 30.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _step = _GiftBackStatusStep.invoice),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFF97316).withOpacity(0.5), style: BorderStyle.solid),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text('View Invoice', style: TextStyle(color: const Color(0xFFF97316), fontSize: 14.sp)),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomActions({required bool isRequest}) {
    if (isRequest) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFFF97316).withOpacity(0.6), style: BorderStyle.solid),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF97316))),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _step = _GiftBackStatusStep.success),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text('Accept', style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text.rich(
                TextSpan(
                  text: 'Accept automatic in  ',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                  children: [TextSpan(text: '10\'00', style: TextStyle(color: const Color(0xFFF97316), fontWeight: FontWeight.w700))],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () => Get.snackbar('Download', 'Invoice download queued', snackPosition: SnackPosition.BOTTOM), icon: Icon(Icons.file_download_outlined, size: 18.sp, color: const Color(0xFFF97316))),
                IconButton(onPressed: () => Get.snackbar('Print', 'Invoice print started', snackPosition: SnackPosition.BOTTOM), icon: Icon(Icons.print_outlined, size: 18.sp)),
                IconButton(onPressed: () => Get.snackbar('Share', 'Invoice shared', snackPosition: SnackPosition.BOTTOM), icon: Icon(Icons.share_outlined, size: 18.sp)),
              ],
            ),
            SizedBox(height: 4.h),
            Text('© 2025 VIPs App. All right reserved', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF4B5563))),
            SizedBox(height: 6.h),
            if (_step == _GiftBackStatusStep.invoice)
              TextButton(
                onPressed: () => setState(() => _step = _GiftBackStatusStep.thankYou),
                child: Text('Finish', style: TextStyle(fontSize: 12.sp, color: const Color(0xFFF97316))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 98.w, child: Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF)))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
