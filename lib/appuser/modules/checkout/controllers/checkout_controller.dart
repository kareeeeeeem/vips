import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/core/services/api_service.dart';

import '../../Cart/controllers/cart_controller.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum OrderType { delivery, takeaway, inStore }

class CheckoutController extends GetxController {
  // Order Type
  var selectedOrderType = OrderType.delivery.obs;

  // Delivery Address
  var deliveryType = 'Deliver to -> Home'.obs;
  var deliveryAddress = ''.obs;

  // Payment Method
  var paymentMethod = 'Cash'.obs;

  // Promotions — only ever populated with a promo actually applied via
  // _applyPromoCode(), never pre-seeded, so this can't claim a discount is
  // active when nothing has actually been applied to the order.
  var activePromotions = <String>[].obs;
  var couponCode = ''.obs;

  // Real promotions loaded from /content/promotions for the picker sheet.
  var availablePromotions = <Map<String, dynamic>>[].obs;
  var isLoadingPromotions = false.obs;

  // Tip/Thanks
  var selectedTip = 0.0.obs;
  var customTip = 0.0.obs;
  final TextEditingController customTipController = TextEditingController();

  // Order Summary
  var subtotal = 31.5.obs;
  var deliveryFee = 6.0.obs;
  var discount = 0.0.obs;

  // Current VIPS wallet points balance (informational only — /order/create
  // doesn't award points, so this is never displayed as "earned").
  var vipPoints = 0.obs;

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

  // Which online gateways the backend actually has real credentials for
  // (GET /api/payment/methods — mirrors utils/paymee.js / utils/paypal.js's
  // getInitStatus()). Populated once at startup; Paymee/PayPal stay
  // disabled in the picker until the corresponding env vars are set on the
  // backend, same graceful-degrade pattern as SendGrid email.
  var gatewayAvailable = <String, bool>{'paymee': false, 'paypal': false}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCheckoutData();
    _loadUserPoints();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
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

  Future<void> _loadUserPoints() async {
    try {
      final response = await ApiService().get('/user/wallet');
      if (response.success && response.data != null) {
        vipPoints.value = ((response.data['points'] ?? 0) as num).toInt();
      }
    } catch (_) {}
  }

  double _parseDouble(dynamic value, [double fallback = 0.0]) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
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
        subtotal.value = _parseDouble(args['subtotal']);
      }

      if (args.containsKey('deliveryFee')) {
        deliveryFee.value = _parseDouble(args['deliveryFee']);
      }

      if (args.containsKey('discount')) {
        discount.value = _parseDouble(args['discount']);
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
        final method = args['paymentMethod']?.toString() ?? '';
        switch (method.toLowerCase()) {
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
            paymentMethod.value =
                method.isNotEmpty
                    ? method.capitalizeFirst ?? method
                    : paymentMethod.value;
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

    safeSnackbar(
      'Order Type Updated',
      'Selected: ${_getOrderTypeName(type)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  // Must match the Order schema's enum exactly (['delivery','takeaway',
  // 'dine_in']) — any other string fails Mongoose validation and the whole
  // order creation throws.
  String _orderTypeString(OrderType type) {
    switch (type) {
      case OrderType.delivery:
        return 'delivery';
      case OrderType.takeaway:
        return 'takeaway';
      case OrderType.inStore:
        return 'dine_in';
    }
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
    final addressController = TextEditingController(text: deliveryAddress.value);
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Delivery Address',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Street, building, city...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final address = addressController.text.trim();
                        if (address.isNotEmpty) {
                          deliveryAddress.value = address;
                          deliveryType.value = 'Deliver to -> $address';
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
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
            Obx(
              () => _buildPaymentOption(
                'Paymee',
                Icons.account_balance_wallet,
                enabled: gatewayAvailable['paymee'] == true,
                disabledReason: 'Paymee is not activated on this account yet',
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => _buildPaymentOption(
                'PayPal',
                Icons.account_balance_wallet_outlined,
                enabled: gatewayAvailable['paypal'] == true,
                disabledReason: 'PayPal is not activated on this account yet',
              ),
            ),
            SizedBox(height: 12.h),
            // Card entry would need a PCI-compliant tokenization flow (a
            // real processor's client SDK) that isn't wired up — genuinely
            // out of scope here, unlike Paymee/PayPal above which are fully
            // built and just waiting on the backend's API keys.
            _buildPaymentOption(
              'Credit Card',
              Icons.credit_card,
              enabled: false,
              disabledReason: 'Card payments require a card processor integration',
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildPaymentOption(
    String method,
    IconData icon, {
    bool enabled = true,
    String? disabledReason,
  }) {
    return Obx(() {
      final isSelected = paymentMethod.value == method;
      return Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: !enabled
              ? () => safeSnackbar(
                    'Not Available',
                    disabledReason ?? '$method is not available right now',
                    snackPosition: SnackPosition.BOTTOM,
                  )
              : () {
            paymentMethod.value = method;
            Get.back();

            safeSnackbar(
              'Payment Method Updated',
              'Selected: $method',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.9),
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
                      ? const Color(0xFFFF6B35).withValues(alpha: 0.05)
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
                      color:
                          isSelected ? const Color(0xFFFF6B35) : Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
                if (!enabled)
                  Text(
                    'Soon',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'SF Pro Display',
                    ),
                  )
                else if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFFFF6B35),
                    size: 24.sp,
                  ),
              ],
            ),
          ),
        ),
        ),
      );
    }); // end Obx
  }

  // ==================== PROMOTIONS ====================

  Future<void> _loadPromotions() async {
    isLoadingPromotions.value = true;
    try {
      final res = await ApiService().get('/content/promotions');
      if (res.success && res.data != null) {
        availablePromotions.value = List<Map<String, dynamic>>.from(res.data);
      }
    } catch (_) {
    } finally {
      isLoadingPromotions.value = false;
    }
  }

  void viewPromotions() {
    _loadPromotions();
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.75),
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
              'Available Promotions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
              ),
            ),
            SizedBox(height: 20.h),

            Flexible(
              child: Obx(() {
                if (isLoadingPromotions.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (availablePromotions.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      'No promotions available right now.',
                      style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: availablePromotions
                        .map((promo) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildPromotionItem(promo),
                            ))
                        .toList(),
                  ),
                );
              }),
            ),

            SizedBox(height: 8.h),

            // Add promo code button
            GestureDetector(
              onTap: () {
                Get.back(); // close the promotions sheet first
                _promptPromoCode();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF6B35)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'Have a code? Enter it manually',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6B35),
                      fontFamily: 'SF Pro Display',
                    ),
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

  Widget _buildPromotionItem(Map<String, dynamic> promo) {
    final title = (promo['title'] ?? '').toString();
    final subtitle = (promo['subtitle'] ?? '').toString();
    final code = (promo['code'] ?? '').toString();
    final isApplied = couponCode.value.isNotEmpty && couponCode.value.toUpperCase() == code.toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: code.isEmpty || isApplied ? null : () => _applyPromoCode(code, closeSheet: true),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isApplied ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(12.r),
            color: isApplied
                ? const Color(0xFF22C55E).withValues(alpha: 0.05)
                : Colors.white,
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
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ],
                ),
              ),
              if (isApplied)
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF22C55E),
                  size: 24.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  final RxBool isApplyingPromo = false.obs;

  Future<void> _applyPromoCode(String code, {bool closeSheet = false}) async {
    if (code.isEmpty) return;
    isApplyingPromo.value = true;
    try {
      final res = await ApiService().post('/rewards/validate-qr', {'code': code});
      final type = res.data is Map ? res.data['type'] : null;
      if (res.success && type == 'coupon') {
        final coupon = res.data['coupon'];
        final pct = ((coupon['discountPercentage'] ?? 0) as num).toDouble();
        discount.value = subtotal.value * (pct / 100);
        couponCode.value = code;
        activePromotions.value = [(coupon['title'] ?? code).toString()];
        if (closeSheet) Get.back();
        safeSnackbar(
          'Promo Applied',
          '${pct.toInt()}% discount applied!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );
      } else if (res.success && type == 'promotion') {
        // Seeded site-wide promotions — a separate collection from
        // merchant Coupons, with its own field names and a minimum
        // order value that isn't enforced server-side on this endpoint
        // (validate-qr only checks the code is real/active), so it has
        // to be checked here before treating the discount as applied.
        final promo = res.data['promotion'];
        final minOrder = ((promo['minOrderValue'] ?? 0) as num).toDouble();
        if (subtotal.value < minOrder) {
          safeSnackbar(
            'Minimum Order Not Met',
            'This promotion requires a minimum order of ${minOrder.toStringAsFixed(0)} TND.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        final pct = ((promo['discount'] ?? 0) as num).toDouble();
        // A "shipping" promo discounts the delivery fee, not the item
        // subtotal — applying its percentage to the subtotal instead
        // would hand out a much larger discount than the promotion means.
        final isShipping = promo['type'] == 'shipping';
        if (isShipping) {
          discount.value = deliveryFee.value * (pct / 100);
        } else {
          discount.value = subtotal.value * (pct / 100);
        }
        couponCode.value = code;
        activePromotions.value = [(promo['title'] ?? code).toString()];
        if (closeSheet) Get.back();
        safeSnackbar(
          'Promo Applied',
          isShipping ? 'Free shipping applied!' : '${pct.toInt()}% discount applied!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
        );
      } else {
        safeSnackbar(
          'Invalid Code',
          res.message.isNotEmpty ? res.message : 'Promo code not found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not validate promo code', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isApplyingPromo.value = false;
    }
  }

  void _promptPromoCode() {
    final codeController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Promo Code',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. SAVE20',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: isApplyingPromo.value
                        ? null
                        : () => _applyPromoCode(codeController.text.trim(), closeSheet: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child:
                        isApplyingPromo.value
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
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

      final cartController =
          Get.isRegistered<CartController>()
              ? Get.find<CartController>()
              : null;

      if (cartController == null || cartController.cartItems.isEmpty) {
        Get.back();
        safeSnackbar(
          'Error',
          'Cart is empty or unavailable.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // merchantId is legitimately optional — plenty of real seeded deals
      // have no merchant attached. Blocking the order here used to make
      // checkout fail for every one of them before it even reached the
      // backend.
      final merchantId = cartController.cartItems.first.merchantId;

      final response = await ApiService().post('/order/create', {
        if (merchantId != null && merchantId.isNotEmpty) 'merchantId': merchantId,
        'items': items,
        'paymentMethod':
            paymentMethod.value == 'Cash'
                ? 'cash'
                : paymentMethod.value.toLowerCase(),
        'deliveryAddress':
            selectedOrderType.value == OrderType.delivery
                ? deliveryAddress.value
                : 'Pickup',
        'orderType': _orderTypeString(selectedOrderType.value),
        if (couponCode.value.isNotEmpty) 'couponCode': couponCode.value,
        if (discount.value > 0) 'couponDiscountAmount': discount.value,
      });

      Get.back(); // Close loading dialog

      if (response.success) {
        try {
          Get.find<CartController>().clearCartLocally();
        } catch (_) {}

        final orderId = response.data is Map ? response.data['_id']?.toString() : null;
        final gateway = paymentMethod.value == 'Paymee'
            ? 'paymee'
            : paymentMethod.value == 'PayPal'
                ? 'paypal'
                : null;

        if (gateway != null && orderId != null) {
          await _startOnlinePayment(orderId, gateway);
        } else {
          _showOrderSuccessDialog();
        }
      } else {
        safeSnackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      safeSnackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ==================== ONLINE PAYMENT (Paymee / PayPal) ====================
  //
  // Both gateways host their own checkout page — there's no in-app card
  // form here, so the flow is: open that page in the system browser, then
  // poll our backend (which the gateway's webhook updates) until the
  // payment resolves. The order already exists in 'pending' status at this
  // point; nothing is lost if the user abandons the browser, they just land
  // back on an unpaid order they can retry from Order History.
  Future<void> _startOnlinePayment(String orderId, String gateway) async {
    try {
      final initiateResponse = await ApiService().post(
        gateway == 'paymee' ? '/payment/paymee/initiate' : '/payment/paypal/create',
        {'orderId': orderId},
      );

      if (!initiateResponse.success || initiateResponse.data == null) {
        safeSnackbar(
          'Payment Unavailable',
          initiateResponse.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final data = initiateResponse.data as Map;
      final url = gateway == 'paymee' ? data['paymentUrl'] : data['approveUrl'];
      if (url == null || url.toString().isEmpty) {
        safeSnackbar('Error', 'Payment link unavailable.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final launched = await launchUrl(Uri.parse(url.toString()), mode: LaunchMode.externalApplication);
      if (!launched) {
        safeSnackbar('Error', 'Could not open the payment page.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      _showAwaitingPaymentDialog(orderId, gateway);
    } catch (e) {
      safeSnackbar('Error', 'Failed to start payment: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showAwaitingPaymentDialog(String orderId, String gateway) {
    final isChecking = false.obs;
    Timer? pollTimer;

    Future<void> checkStatus({bool manual = false}) async {
      if (isChecking.value) return;
      isChecking.value = true;
      try {
        String? paymentStatus;
        if (gateway == 'paypal') {
          // PayPal requires an explicit capture call after approval — it
          // doesn't settle just by the user approving in the browser. Safe
          // to call repeatedly: the backend no-ops once already paid.
          final captureResponse = await ApiService().post('/payment/paypal/capture', {'orderId': orderId});
          if (captureResponse.data is Map) {
            paymentStatus = captureResponse.data['paymentStatus']?.toString();
          }
        } else {
          final statusResponse = await ApiService().get('/payment/paymee/status/$orderId');
          if (statusResponse.data is Map) {
            paymentStatus = statusResponse.data['paymentStatus']?.toString();
          }
        }
        if (paymentStatus == 'paid') {
          pollTimer?.cancel();
          Get.back(); // close awaiting dialog
          _showOrderSuccessDialog();
        } else if (manual) {
          safeSnackbar(
            'Not Confirmed Yet',
            'Payment hasn\'t completed yet. Finish it in the browser, then try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (_) {
      } finally {
        isChecking.value = false;
      }
    }

    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 32.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF6B35)),
                SizedBox(height: 16.h),
                Text(
                  'Waiting for payment confirmation…',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Complete the payment in your browser, then come back here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        pollTimer?.cancel();
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => checkStatus(manual: true),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
                      child: const Text('I\'ve Paid', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Auto-poll every 4s for up to 2 minutes in case the webhook lands
    // before the user taps back into the app.
    var elapsed = 0;
    pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      elapsed += 4;
      if (elapsed >= 120) {
        timer.cancel();
        return;
      }
      checkStatus();
    });
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
                color: Colors.black.withValues(alpha: 0.1),
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
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
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
                'Your order has been successfully placed.\nWe\'ll notify you once the merchant confirms it.',
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
                      'Payment Method',
                      0,
                      customValue: paymentMethod.value,
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
                        Get.offAllNamed('/main-app');
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
                        Get.back();
                        Get.offAllNamed('/profile');
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B35,
                              ).withValues(alpha: 0.3),
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
