import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/help_sheet.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class GiftBackPage extends StatefulWidget {
  const GiftBackPage({super.key});

  @override
  State<GiftBackPage> createState() => _GiftBackPageState();
}

class _GiftBackPageState extends State<GiftBackPage> {
  final TextEditingController phoneIdController = TextEditingController(
    text: '',
  );
  final TextEditingController amountController = TextEditingController(
    text: '0.000',
  );

  final FocusNode phoneIdFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();

  String selectedCurrency = 'D';
  bool isSubmitting = false;

  bool isLoadingLimits = true;
  double minAmount = 0;
  double maxAmountPerTransaction = 0;
  double dailyLimitAmount = 0;
  double remainingTodayAmount = 0;
  double monthlyLimitAmount = 0;
  double remainingThisMonthAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadLimits();
  }

  // Same pattern as reward_page.dart's _scanMerchantQR(): a scanned VIPs ID
  // QR comes back as {type: 'user', user: {id, fullName, phone}} — the
  // recipient field here takes a phone number, so populate from that.
  void _scanRecipientQR() {
    Get.toNamed('/q-r-scanner')?.then((result) {
      if (result is Map && result['type'] == 'user') {
        final phone = result['user']?['phone']?.toString();
        if (phone != null && phone.isNotEmpty) {
          setState(() => phoneIdController.text = phone);
        }
      } else if (result is Map) {
        safeSnackbar('Not a VIPs ID', 'Scan the recipient\'s VIPs ID QR code.', snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Future<void> _loadLimits() async {
    try {
      final res = await ApiService().get('/rewards/limits');
      if (res.success && res.data != null) {
        final gift = res.data['giftBack'] as Map;
        setState(() {
          minAmount = (gift['minAmount'] as num).toDouble();
          maxAmountPerTransaction = (gift['maxAmountPerTransaction'] as num).toDouble();
          dailyLimitAmount = (gift['dailyLimitAmount'] as num).toDouble();
          remainingTodayAmount = (gift['remainingTodayAmount'] as num).toDouble();
          monthlyLimitAmount = (gift['monthlyLimitAmount'] as num).toDouble();
          remainingThisMonthAmount = (gift['remainingThisMonthAmount'] as num).toDouble();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => isLoadingLimits = false);
    }
  }

  Future<void> _proceed() async {
    final recipientPhone = phoneIdController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    if (recipientPhone.isEmpty) {
      safeSnackbar('Missing recipient', 'Enter the recipient\'s phone number.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (amount == null || amount <= 0) {
      safeSnackbar('Invalid amount', 'Enter an amount greater than 0.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final response = await ApiService().post('/rewards/send-gift', {
        'recipientPhone': recipientPhone,
        'amount': amount,
      });
      if (response.success) {
        Get.back();
        safeSnackbar('Success', 'Gift sent to $recipientPhone!', snackPosition: SnackPosition.BOTTOM);
      } else {
        safeSnackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not send gift. Please try again.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    phoneIdController.dispose();
    amountController.dispose();
    phoneIdFocus.dispose();
    amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 18.sp,
            ),
          ),
        ),
        title: Text(
          'Gift Back',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => showHelpSheet(accentColor: const Color(0xFF2E7D5F)),
            child: Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Center(
                child: Text(
                  'Help !',
                  style: TextStyle(
                    color: Color(0xFF5ED5A8),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone / ID Section with refined styling
                    Text(
                      'Phone / ID',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildInputCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: phoneIdController,
                              focusNode: phoneIdFocus,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Recipient phone number',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15.sp),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _scanRecipientQR,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFF5ED5A8),
                                size: 22.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Enter Back Amount Section with elegant design
                    Text(
                      'Enter Back Amount',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildInputCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amountController,
                              focusNode: amountFocus,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 42.sp,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Static badge, not a picker — TND ('D') is the
                          // only currency this app supports anywhere (same
                          // as reward_page.dart's identical amount field).
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 20.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF2E7D5F),
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF2E7D5F).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              selectedCurrency,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Fees & Exchange with improved styling
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16.sp,
                                color: Color(0xFF5ED5A8),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Fees & Exchange: ',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '000 D',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Color(0xFF2E7D5F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 16.sp,
                                color: Color(0xFF5ED5A8),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Limit: ',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                isLoadingLimits
                                    ? '...'
                                    : '${minAmount.toStringAsFixed(0)} - ${maxAmountPerTransaction.toStringAsFixed(0)} D',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Color(0xFF2E7D5F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Limit Information Section with refined card design
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE8F5F0), Color(0xFFF0F9F5)],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Color(0xFF5ED5A8).withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF5ED5A8).withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2E7D5F).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 18.sp,
                                  color: Color(0xFF2E7D5F),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Limit Information',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D5F),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          if (isLoadingLimits)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            // Real numbers from GET /rewards/limits, backed
                            // by this user's actual Transaction history.
                            _buildLimitRow(
                              leftLabel: 'Daily Limit',
                              leftValue: '${dailyLimitAmount.toStringAsFixed(0)} D',
                              rightLabel: 'Remaining Today',
                              rightValue: '${remainingTodayAmount.toStringAsFixed(3)} D',
                            ),

                            SizedBox(height: 18.h),

                            // Divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF5ED5A8).withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 18.h),

                            // Monthly Limit Row
                            _buildLimitRow(
                              leftLabel: 'Monthly Limit',
                              leftValue: '${monthlyLimitAmount.toStringAsFixed(0)} D',
                              rightLabel: 'Remaining This Month',
                              rightValue: '${remainingThisMonthAmount.toStringAsFixed(3)} D',
                            ),

                            SizedBox(height: 18.h),

                            // Divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF5ED5A8).withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 18.h),

                            // Transaction Limit
                            Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 18.sp,
                                    color: Color(0xFF2E7D5F),
                                  ),
                                  SizedBox(width: 10.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transaction Limit',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Color(0xFF5ED5A8),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '${minAmount.toStringAsFixed(0)} - ${maxAmountPerTransaction.toStringAsFixed(0)} D',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Color(0xFF2E7D5F),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),

          // Fixed Bottom Buttons
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 54.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xFFFF6B35),
                            width: 1.5.w,
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B35).withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFFFF6B35),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: isSubmitting ? null : _proceed,
                      child: Container(
                        height: 54.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8555)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B35).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isSubmitting
                              ? SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Proceed',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for input cards
  Widget _buildInputCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper widget for limit rows
  Widget _buildLimitRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Color(0xFF5ED5A8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                leftValue,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF2E7D5F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rightLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Color(0xFF5ED5A8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 6.h),
              Text(
                rightValue,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF2E7D5F),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
