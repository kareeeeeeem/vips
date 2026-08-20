import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

import '../../controllers/cart_controller.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final double totalBill;
  final int walletPoints;
  final String? selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodBottomSheet({super.key,
    required this.totalBill,
    this.walletPoints = 0,
    this.selectedMethod,
    required this.onMethodSelected,
  });

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

                  // Only Paymee/PayPal actually exist as gateways
                  // server-side (GET /payment/methods, same check
                  // CheckoutController uses) — each is only tappable once
                  // the backend reports real credentials configured for it,
                  // so a selection here never lies about what will happen
                  // at checkout.
                  Obx(() => _buildPaymentOption(
                    controller: controller,
                    id: 'paymee',
                    title: 'Paymee',
                    iconUrl:
                        'https://paymee.tn/assets/images/logo.png',
                    enabled: controller.gatewayAvailable['paymee'] == true,
                    disabledReason: 'Paymee is not activated on this account yet',
                  )),

                  SizedBox(height: 12.h),

                  Obx(() => _buildPaymentOption(
                    controller: controller,
                    id: 'paypal',
                    title: 'PayPal',
                    iconUrl:
                        'https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg',
                    enabled: controller.gatewayAvailable['paypal'] == true,
                    disabledReason: 'PayPal is not activated on this account yet',
                  )),

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
    bool enabled = true,
    String? disabledReason,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == id;

      return Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: GestureDetector(
          onTap: enabled
              ? () => controller.selectPaymentMethod(id)
              : () => safeSnackbar(
                    'Not Available',
                    disabledReason ?? '$title is not available yet',
                    snackPosition: SnackPosition.BOTTOM,
                  ),
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

                if (!enabled)
                  Text(
                    'Unavailable',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'SF Pro Display',
                    ),
                  )
                else
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

  // Same live check CheckoutController uses — only show Paymee/PayPal as
  // selectable once the backend actually has credentials configured.
  var gatewayAvailable = <String, bool>{'paymee': false, 'paypal': false}.obs;

  @override
  void onInit() {
    super.onInit();
    if (initialMethod != null) {
      selectedPaymentMethod.value = initialMethod!;
    } else {
      selectedPaymentMethod.value = 'cash_on_delivery';
    }
    _loadGatewayAvailability();
  }

  Future<void> _loadGatewayAvailability() async {
    try {
      final response = await ApiService().get('/payment/methods');
      if (response.success && response.data is Map) {
        final data = response.data as Map;
        gatewayAvailable.value = {
          'paymee': data['paymee']?['configured'] == true,
          'paypal': data['paypal']?['configured'] == true,
        };
      }
    } catch (_) {}
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
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
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
                    try {
                      final cart = Get.find<CartController>();
                      cart.applyWalletPoints();
                      if (cart.walletPointsToRedeem.value > 0) {
                        safeSnackbar(
                          'Wallet Points Applied',
                          '${cart.walletPointsToRedeem.value} pts (D ${cart.walletDiscount.toStringAsFixed(3)}) applied to your order',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                        );
                      } else {
                        safeSnackbar('No Points Available', 'You have no VIPS points to redeem.',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    } catch (_) {
                      safeSnackbar('Error', 'Could not apply wallet points.', snackPosition: SnackPosition.BOTTOM);
                    }
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
      safeSnackbar(
        'Select Payment Method',
        'Please select a payment method',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
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
          color: Colors.black.withValues(alpha: 0.05),
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
              color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
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
