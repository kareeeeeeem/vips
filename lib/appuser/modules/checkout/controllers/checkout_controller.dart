import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../Cart/controllers/cart_controller.dart';

enum OrderType { delivery, takeaway, inStore }

class CheckoutController extends GetxController {
  // Order Type
  var selectedOrderType = OrderType.delivery.obs;

  // Delivery Address
  var deliveryType = 'Deliver to -> Home'.obs;
  var deliveryAddress = '221B Baker Street, London, United K...'.obs;

  // Payment Method
  var paymentMethod = 'Cash'.obs;

  // Promotions
  var activePromotions = <String>['FREE SHIPPING', '20%'].obs;

  // Tip/Thanks
  var selectedTip = 1.0.obs;
  var customTip = 0.0.obs;
  final TextEditingController customTipController = TextEditingController();

  // Order Summary
  var subtotal = 31.5.obs;
  var deliveryFee = 6.0.obs;
  var discount = 6.3.obs;

  // VIP Points
  var vipPoints = 250.obs;

  // Computed
  double get grandTotal {
    double total = subtotal.value + deliveryFee.value - discount.value;
    // Add tip if selected
    if (selectedTip.value > 0) {
      total += selectedTip.value;
    } else if (customTip.value > 0) {
      total += customTip.value;
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    // Load data from previous page (cart)
    _loadCheckoutData();
  }

  @override
  void onClose() {
    customTipController.dispose();
    super.onClose();
  }

  void _loadCheckoutData() {
    // Get data from cart page arguments
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;

      if (args.containsKey('subtotal')) {
        subtotal.value = args['subtotal'];
      }

      if (args.containsKey('deliveryFee')) {
        deliveryFee.value = args['deliveryFee'];
      }

      if (args.containsKey('discount')) {
        discount.value = args['discount'];
      }

      if (args.containsKey('deliveryOption')) {
        final option = args['deliveryOption'];
        if (option == 'delivery') {
          selectedOrderType.value = OrderType.delivery;
        } else if (option == 'takeaway') {
          selectedOrderType.value = OrderType.takeaway;
        } else if (option == 'pickup' || option == 'inStore') {
          selectedOrderType.value = OrderType.inStore;
        }
      }

      if (args.containsKey('paymentMethod')) {
        final method = args['paymentMethod'] as String;
        switch (method) {
          case 'cash':
            paymentMethod.value = 'Cash';
            break;
          case 'paypal':
            paymentMethod.value = 'PayPal';
            break;
          case 'credit card':
            paymentMethod.value = 'Credit Card';
            break;
          case 'apple pay':
            paymentMethod.value = 'Apple Pay';
            break;
          default:
            paymentMethod.value = method.capitalizeFirst ?? method;
            break;
        }
      }

      // Update delivery fee based on order type
      _updateDeliveryFee();
    }
  }

  // ==================== ORDER TYPE ====================

  void selectOrderType(OrderType type) {
    selectedOrderType.value = type;
    _updateDeliveryFee();

    Get.snackbar(
      'Order Type Updated',
      'Selected: ${_getOrderTypeName(type)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  String _getOrderTypeName(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.inStore:
        return 'In Store';
    }
  }

  void _updateDeliveryFee() {
    switch (selectedOrderType.value) {
      case OrderType.delivery:
        deliveryFee.value = 6.0;
        break;
      case OrderType.takeaway:
      case OrderType.inStore:
        deliveryFee.value = 0.0;
        break;
    }
  }

  // ==================== DELIVERY ADDRESS ====================

  void selectDeliveryAddress() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Select Delivery Address',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 20.h),

            _buildAddressOption(
              'Home',
              '221B Baker Street, London, United Kingdom',
              Icons.home_outlined,
            ),
            SizedBox(height: 12.h),
            _buildAddressOption(
              'Work',
              '10 Downing Street, Westminster, London, UK',
              Icons.business_outlined,
            ),
            SizedBox(height: 12.h),
            _buildAddressOption(
              'Other',
              'Add new address',
              Icons.add_location_outlined,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildAddressOption(String label, String address, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          deliveryType.value = 'Deliver to -> $label';
          deliveryAddress.value = address;
          Get.back();

          Get.snackbar(
            'Address Updated',
            'Delivering to $label',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: EdgeInsets.all(16.w),
            borderRadius: 12.r,
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF6B35), size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF9CA3AF),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PAYMENT METHOD ====================

  void selectPaymentMethod() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 20.h),

            _buildPaymentOption('Cash', Icons.money),
            SizedBox(height: 12.h),
            _buildPaymentOption('Credit Card', Icons.credit_card),
            SizedBox(height: 12.h),
            _buildPaymentOption('PayPal', Icons.account_balance_wallet),
            SizedBox(height: 12.h),
            _buildPaymentOption('Apple Pay', Icons.apple),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    final isSelected = paymentMethod.value == method;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          paymentMethod.value = method;
          Get.back();

          Get.snackbar(
            'Payment Method Updated',
            'Selected: $method',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: EdgeInsets.all(16.w),
            borderRadius: 12.r,
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12.r),
            color:
                isSelected
                    ? const Color(0xFFFF6B35).withOpacity(0.05)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF6B7280),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  method,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFFFF6B35) : Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFFFF6B35),
                  size: 24.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PROMOTIONS ====================

  void viewPromotions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Active Promotions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 20.h),

            // List of promotions
            _buildPromotionItem(
              'FREE SHIPPING',
              'Free delivery on all orders',
              true,
            ),
            SizedBox(height: 12.h),
            _buildPromotionItem('20% OFF', '20% discount on your order', true),
            SizedBox(height: 12.h),
            _buildPromotionItem(
              'FIRST ORDER',
              '10% off for new customers',
              false,
            ),

            SizedBox(height: 20.h),

            // Add promo code button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF6B35)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  'Add Promo Code',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B35),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildPromotionItem(String title, String description, bool isActive) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? const Color(0xFFFF6B35) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(12.r),
        color:
            isActive ? const Color(0xFFFF6B35).withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.local_offer, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Icon(
              Icons.check_circle,
              color: const Color(0xFF22C55E),
              size: 24.sp,
            ),
        ],
      ),
    );
  }

  // ==================== TIP/THANKS ====================

  void selectTip(double amount) {
    selectedTip.value = amount;
    customTip.value = 0;
    customTipController.clear();
  }

  // ==================== PLACE ORDER ====================

  void placeOrder() async {
    // Show loading dialog
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: const Color(0xFFFF6B35)),
              SizedBox(height: 16.h),
              Text(
                'Placing your order...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      List<Map<String, dynamic>> items = [];
      try {
        final cartController = Get.find<CartController>();
        items =
            cartController.cartItems
                .map(
                  (item) => {
                    'productId': item.id,
                    'name': item.name,
                    'price': item.price,
                    'quantity': item.quantity,
                  },
                )
                .toList();
      } catch (e) {
        // CartController not found or empty
      }

      final cartController = Get.isRegistered<CartController>()
          ? Get.find<CartController>()
          : null;
      final merchantId = cartController?.cartItems.first.merchantId ?? '64abcd1234567890abcdef12';

      final response = await ApiService().post('/order/create', {
        'merchantId': merchantId,
        'items': items,
        'paymentMethod': paymentMethod.value == 'Cash'
            ? 'cash'
            : paymentMethod.value.toLowerCase(),
        'deliveryAddress':
            selectedOrderType.value == OrderType.delivery
                ? deliveryAddress.value
                : 'Pickup',
      });

      Get.back(); // Close loading dialog

      if (response.success) {
        _showOrderSuccessDialog();
        try {
          Get.find<CartController>().clearCartLocally();
        } catch (_) {}
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showOrderSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF22C55E),
                  size: 50.sp,
                ),
              ),

              SizedBox(height: 24.h),

              // Title
              Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  fontFamily: 'SF Pro Display',
                ),
              ),

              SizedBox(height: 12.h),

              // Message
              Text(
                'Your order has been successfully placed.\nYou earned ${vipPoints.value} VIP points!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // Order Details
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildOrderDetailRow('Order Total', grandTotal),
                    SizedBox(height: 8.h),
                    _buildOrderDetailRow(
                      'VIP Points Earned',
                      vipPoints.value.toDouble(),
                    ),
                    SizedBox(height: 8.h),
                    _buildOrderDetailRow(
                      'Estimated Delivery',
                      0,
                      customValue: '30-45 mins',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to home/cart
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back(); // Close dialog
                        Get.toNamed('/order-tracking'); // Go to order tracking
                      },
                      child: Container(
                        height: 48.h,
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
                            'Track Order',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildOrderDetailRow(
    String label,
    double value, {
    String? customValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF6B7280),
            fontFamily: 'SF Pro Text',
          ),
        ),
        Text(
          customValue ?? 'D ${value.toStringAsFixed(3)}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ],
    );
  }

  // ==================== NAVIGATION ====================

  void goBack() {
    Get.back();
  }
}
