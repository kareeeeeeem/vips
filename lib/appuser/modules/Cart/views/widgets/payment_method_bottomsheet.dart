import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final double totalBill;
  final int walletPoints;
  final String? selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodBottomSheet({
    Key? key,
    required this.totalBill,
    this.walletPoints = 28560,
    this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PaymentMethodController(
        initialMethod: selectedMethod,
        totalBill: totalBill,
        walletPoints: walletPoints,
      ),
    );

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 20.h),

          // Title
          Text(
            'Choose Payment Method',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),

          SizedBox(height: 24.h),

          // Total Bill
          Text(
            'Total Bill',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
              fontFamily: 'SF Pro Text',
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            'D ${totalBill.toStringAsFixed(3)}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF22C55E),
              fontFamily: 'SF Pro Display',
            ),
          ),

          SizedBox(height: 24.h),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  // Wallet Points
                  _buildWalletPointsSection(controller),

                  SizedBox(height: 16.h),

                  // Cash on Delivery
                  _buildPaymentOption(
                    controller: controller,
                    id: 'cash_on_delivery',
                    title: 'Cash on Delivery',
                  ),

                  SizedBox(height: 24.h),

                  // Pay Via Online Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pay Via Online',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Online Payment Options
                  _buildPaymentOption(
                    controller: controller,
                    id: 'paypal',
                    title: 'Paypal',
                    iconUrl:
                        'https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg',
                  ),

                  SizedBox(height: 12.h),

                  _buildPaymentOption(
                    controller: controller,
                    id: 'bkash',
                    title: 'Bkash',
                    iconUrl:
                        'https://seeklogo.com/images/B/bkash-logo-835789094F-seeklogo.com.png',
                  ),

                  SizedBox(height: 12.h),

                  _buildPaymentOption(
                    controller: controller,
                    id: 'stripe',
                    title: 'Stripe',
                    iconUrl:
                        'https://upload.wikimedia.org/wikipedia/commons/b/ba/Stripe_Logo%2C_revised_2016.svg',
                  ),

                  SizedBox(height: 12.h),

                  _buildPaymentOption(
                    controller: controller,
                    id: 'razorpay',
                    title: 'Razor pay',
                    iconUrl:
                        'https://upload.wikimedia.org/wikipedia/commons/8/89/Razorpay_logo.svg',
                  ),

                  SizedBox(height: 12.h),

                  _buildPaymentOption(
                    controller: controller,
                    id: 'semangpay',
                    title: 'Semang pay',
                    iconUrl:
                        'https://via.placeholder.com/100x40/4A90E2/FFFFFF?text=Semang',
                  ),

                  SizedBox(height: 12.h),

                  _buildPaymentOption(
                    controller: controller,
                    id: 'flutterwave',
                    title: 'Flutterwave',
                    iconUrl: 'https://flutterwave.com/images/logo/full.svg',
                  ),

                  SizedBox(height: 12.h),

                  _buildPaymentOption(
                    controller: controller,
                    id: 'paystack',
                    title: 'Paystack',
                    iconUrl:
                        'https://paystack.com/assets/img/logo/full-logo-primary.svg',
                  ),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletPointsSection(PaymentMethodController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Points',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'VPT ${walletPoints.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.applyWalletPoints,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Apply',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF22C55E),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethodController controller,
    required String id,
    required String title,
    String? iconUrl,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == id;

      return GestureDetector(
        onTap: () => controller.selectPaymentMethod(id),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon/Logo
              if (iconUrl != null)
                Container(
                  width: 40.w,
                  height: 24.h,
                  child: Image.network(
                    iconUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.payment,
                        color: const Color(0xFF6B7280),
                        size: 24.sp,
                      );
                    },
                  ),
                )
              else
                SizedBox(width: 40.w),

              SizedBox(width: 12.w),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),

              // Radio Button
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 12.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                        )
                        : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ==================== CONTROLLER ====================

class PaymentMethodController extends GetxController {
  final String? initialMethod;
  final double totalBill;
  final int walletPoints;

  PaymentMethodController({
    this.initialMethod,
    required this.totalBill,
    required this.walletPoints,
  });

  var selectedPaymentMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (initialMethod != null) {
      selectedPaymentMethod.value = initialMethod!;
    } else {
      selectedPaymentMethod.value = 'cash_on_delivery';
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void applyWalletPoints() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: const Color(0xFF22C55E),
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Apply Wallet Points',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You have VPT $walletPoints available.\nHow much would you like to use?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Wallet Points Applied',
                      'Your wallet points have been applied',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Apply All',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmSelection(Function(String) onMethodSelected) {
    if (selectedPaymentMethod.value.isEmpty) {
      Get.snackbar(
        'Select Payment Method',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
      return;
    }

    onMethodSelected(selectedPaymentMethod.value);
    Get.back();
  }
}

// ==================== SELECT BUTTON (à ajouter en bas du bottom sheet) ====================

Widget buildSelectButton(
  PaymentMethodController controller,
  Function(String) onMethodSelected,
) {
  return Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: GestureDetector(
      onTap: () => controller.confirmSelection(onMethodSelected),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Select',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ),
      ),
    ),
  );
}

// ==================== UTILISATION ====================

/*
// Dans cart_controller.dart ou checkout_controller.dart


*/
