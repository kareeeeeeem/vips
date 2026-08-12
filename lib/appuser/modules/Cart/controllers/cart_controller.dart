import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/order_success.dart';
import '../views/widgets/payment_method_bottomsheet.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum CartItemType { food, product, service }

class CartItem {
  final String id;
  final String name;
  final String description;
  final String? image;
  final double price;
  final double? oldPrice;
  final CartItemType type;
  int quantity;
  final String? category;
  final String? merchantId;
  final Map<String, dynamic>? options;
  bool isFavorite;

  CartItem({
    required this.id,
    this.merchantId,
    required this.name,
    required this.description,
    this.image,
    required this.price,
    this.oldPrice,
    required this.type,
    this.quantity = 1,
    this.category,
    this.options,
    this.isFavorite = false,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantId': merchantId,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'oldPrice': oldPrice,
      'type': type.toString(),
      'quantity': quantity,
      'category': category,
      'options': options,
      'isFavorite': isFavorite,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['oldPrice']?.toDouble(),
      merchantId: json['merchantId'],
      type: CartItemType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CartItemType.product,
      ),
      quantity: json['quantity'] ?? 1,
      category: json['category'],
      options: json['options'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  CartItem copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    double? price,
    double? oldPrice,
    CartItemType? type,
    int? quantity,
    String? category,
    String? merchantId,
    Map<String, dynamic>? options,
    bool? isFavorite,
  }) {
    return CartItem(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      options: options ?? this.options,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class CartController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Observable variables
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var selectedItems = <String>{}.obs;
  var isSelectionMode = false.obs;
  var couponCode = ''.obs;
  var deliveryOption = 'standard'.obs;
  var deliveryNote = ''.obs;

  // Wallet points loaded from API
  var walletPoints = 0.obs;

  // Order Type Management
  var selectedOrderType = 0.obs; // 0: Delivery, 1: Takeaway, 2: In Store
  var deliveryAddress = ''.obs;
  var selectedDate = ''.obs;
  var selectedTime = ''.obs;

  // Tip Management
  var selectedTipAmount = 0.0.obs;
  var customTipAmount = 0.0.obs;
  final TextEditingController customTipController = TextEditingController();
  final TextEditingController additionalNoteController =
      TextEditingController();

  // Calculated values
  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _calculateDeliveryFee();
  double get discount => _calculateDiscount();
  double get vipsDiscount => 0.0;
  double get couponDiscount => _calculateDiscount();
  double get serviceCharge => 0.0;
  double get vatTax => subtotal * 0.07;
  double get tipAmount =>
      selectedTipAmount.value > 0
          ? selectedTipAmount.value
          : customTipAmount.value;
  double get total =>
      subtotal +
      deliveryFee -
      couponDiscount +
      serviceCharge +
      vatTax +
      tipAmount;
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _loadCartItems();
    _loadWalletPoints();
    selectedDate.value = 'Today (${DateFormat('dd MMM, yyyy').format(DateTime.now())})';
  }

  @override
  void onClose() {
    animationController.dispose();
    customTipController.dispose();
    additionalNoteController.dispose();
    super.onClose();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    animationController.forward();
  }

  Future<void> _loadCartItems() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/cart');
      if (response.success && response.data != null) {
        final List<dynamic> raw = response.data;
        cartItems.value = raw.map((item) => CartItem(
          id: item['itemId']?.toString() ?? item['_id']?.toString() ?? '',
          merchantId: item['merchantId']?.toString(),
          name: item['name'] ?? 'Product',
          description: '',
          price: (item['price'] ?? 0).toDouble(),
          type: CartItemType.product,
          quantity: item['quantity'] ?? 1,
        )).toList();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _loadWalletPoints() async {
    try {
      final res = await ApiService().get('/user/wallet');
      if (res.success && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        walletPoints.value = ((d['walletPoints'] ?? d['points'] ?? 0) as num).toInt();
      }
    } catch (_) {}
  }

  Future<void> syncCartToServer() async {
    try {
      for (var item in cartItems) {
        await ApiService().post('/cart/add', {
          'itemId': item.id,
          'itemType': 'product',
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'merchantId': item.merchantId,
        });
      }
    } catch (_) {}
  }

  // ==================== TIP MANAGEMENT ====================

  void setTipAmount(double amount) {
    selectedTipAmount.value = amount;
    customTipAmount.value = 0.0;
    customTipController.clear();
  }

  void setCustomTip(double amount) {
    selectedTipAmount.value = 0.0;
    customTipAmount.value = amount;
  }

  // ==================== PRICE BREAKDOWN ====================

  void showPriceBreakdown() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Price breakdown items
              _buildBreakdownRow(
                'Item Price',
                'D ${subtotal.toStringAsFixed(3)}',
              ),
              _buildBreakdownRow('Addon Cost', 'D 0.000'),

              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFED7AA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    Text(
                      'D ${subtotal.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),
              _buildBreakdownRow(
                'Coupon Discount',
                couponDiscount > 0 ? '- D ${couponDiscount.toStringAsFixed(3)}' : 'None',
                isDiscount: couponDiscount > 0,
              ),
              _buildBreakdownRow(
                'Service Charge',
                'D ${serviceCharge.toStringAsFixed(3)}',
              ),
              _buildBreakdownRow(
                'Delivery Charge',
                'D ${deliveryFee.toStringAsFixed(3)}',
              ),
              _buildBreakdownRow('Vat/Tax', 'D ${vatTax.toStringAsFixed(3)}'),

              SizedBox(height: 24.h),

              // Total
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFF6B35)),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Cart Items ($itemCount)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFF6B35),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'D ',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        Text(
                          '${total.toInt()}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                        Text(
                          '.${((total - total.toInt()) * 1000).toInt().toString().padLeft(3, '0')}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Place Order Button
              GestureDetector(
                onTap: () {
                  Get.back();
                  placeOrder();
                },
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Place Order',
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

              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
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
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.green : Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ORDER TYPE MANAGEMENT ====================

  void setOrderType(int type) {
    selectedOrderType.value = type;

    // Reset time when changing type
    if (type == 0) {
      // Delivery selected
      selectedTime.value = '';
    }
  }

  void selectDeliveryAddress() {
    final TextEditingController addressController = TextEditingController(text: deliveryAddress.value);
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Delivery Address',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'e.g. 221B Baker Street...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (addressController.text.trim().isNotEmpty) {
                          deliveryAddress.value = addressController.text.trim();
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
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

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF6B35),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      if (picked.year == now.year &&
          picked.month == now.month &&
          picked.day == now.day) {
        selectedDate.value =
            'Today (${DateFormat('dd MMM, yyyy').format(picked)})';
      } else {
        selectedDate.value = DateFormat('dd MMM, yyyy').format(picked);
      }
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFF6B35),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      selectedTime.value = DateFormat('HH:mm').format(selectedDateTime);
    }
  }

  RxString selectedPaymentMethod = 'cash_on_delivery'.obs;

  String get selectedPaymentMethodLabel {
    switch (selectedPaymentMethod.value) {
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      case 'paypal':
        return 'Paypal';
      case 'bkash':
        return 'Bkash';
      case 'stripe':
        return 'Stripe';
      case 'razorpay':
        return 'Razorpay';
      case 'semangpay':
        return 'SemangPay';
      case 'flutterwave':
        return 'Flutterwave';
      case 'paystack':
        return 'Paystack';
      default:
        return selectedPaymentMethod.value;
    }
  }

  String get normalizedPaymentMethod {
    if (selectedPaymentMethod.value == 'cash_on_delivery') return 'cash';
    return selectedPaymentMethod.value.toLowerCase();
  }

  void selectPaymentMethod() {
    Get.put(PaymentMethodController(totalBill: total, walletPoints: walletPoints.value));
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          children: [
            PaymentMethodBottomSheet(
              totalBill: total,
              walletPoints: walletPoints.value,
              selectedMethod: selectedPaymentMethod.value,
              onMethodSelected: (method) {
                selectedPaymentMethod.value = method;
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildSelectButton(Get.find<PaymentMethodController>(), (
                method,
              ) {
                selectedPaymentMethod.value = method;
              }),
            ),
          ],
        );
      },
    );
  }

  void viewPromotions() {
    Get.toNamed('/promotions');
  }

  // ==================== MAIN METHODS ====================

  void placeOrder() async {
    if (cartItems.isEmpty) {
      safeSnackbar(
        'Error',
        'Your cart is empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final items = cartItems
          .map(
            (item) => {
              'productId': item.id,
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
            },
          )
          .toList();

      final response = await ApiService().post('/order/create', {
        'merchantId': cartItems.first.merchantId ?? '',
        'items': items,
        'paymentMethod': normalizedPaymentMethod,
        'deliveryAddress':
            selectedOrderType.value == 0 ? deliveryAddress.value : 'Pickup',
      });

      Get.back(); // close loading dialog

      if (response.success) {
        Get.to(() => const OrderSuccessView());
        clearCartLocally();
      } else {
        safeSnackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // close loading dialog
      safeSnackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }



  void addItems() {
    Get.back();
    Get.toNamed('/all-merchants');
  }

  void updateNote(String note) {
    deliveryNote.value = note;
  }

  Future<void> clearCartLocally() async {
    cartItems.clear();
    selectedItems.clear();
    try { await ApiService().post('/cart/clear', {}); } catch (_) {}
  }

  void toggleFavorite(CartItem item) {
    final index = cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      cartItems[index].isFavorite = !cartItems[index].isFavorite;
      cartItems.refresh();
    }
  }

  void increaseQuantity(CartItem item) {
    final index = cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      cartItems[index].quantity++;
      cartItems.refresh();
      final updatedQuantity = cartItems[index].quantity;
      ApiService().put('/cart/update', {'itemId': item.id, 'quantity': updatedQuantity}).then((res) {
        if (!res.success) {
          cartItems[index].quantity = updatedQuantity - 1;
          cartItems.refresh();
          safeSnackbar('Error', 'Failed to update cart', snackPosition: SnackPosition.BOTTOM);
        }
      }, onError: (_) {
        cartItems[index].quantity = updatedQuantity - 1;
        cartItems.refresh();
        safeSnackbar('Error', 'Failed to update cart', snackPosition: SnackPosition.BOTTOM);
      });
    }
  }

  void decreaseQuantity(CartItem item) {
    final index = cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1 && cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
      final updatedQuantity = cartItems[index].quantity;
      ApiService().put('/cart/update', {'itemId': item.id, 'quantity': updatedQuantity}).then((res) {
        if (!res.success) {
          cartItems[index].quantity = updatedQuantity + 1;
          cartItems.refresh();
          safeSnackbar('Error', 'Failed to update cart', snackPosition: SnackPosition.BOTTOM);
        }
      }, onError: (_) {
        cartItems[index].quantity = updatedQuantity + 1;
        cartItems.refresh();
        safeSnackbar('Error', 'Failed to update cart', snackPosition: SnackPosition.BOTTOM);
      });
    }
  }

  void removeItem(CartItem item) {
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
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Remove Item',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to remove "${item.name}" from your basket?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
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
                      onTap: () async {
                        cartItems.remove(item);
                        selectedItems.remove(item.id);
                        Get.back();
                        try { await ApiService().delete('/cart/remove/${item.id}'); } catch (_) {}
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Remove',
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
      barrierDismissible: true,
    );
  }

  void clearCart() {
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
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Clear Basket',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to remove all items from your basket?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Text',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
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
                      onTap: () async {
                        cartItems.clear();
                        selectedItems.clear();
                        isSelectionMode.value = false;
                        deliveryNote.value = '';
                        Get.back();
                        try { await ApiService().post('/cart/clear', {}); } catch (_) {}
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Clear Basket',
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
      barrierDismissible: true,
    );
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedItems.clear();
    }
  }

  void toggleItemSelection(String itemId) {
    if (selectedItems.contains(itemId)) {
      selectedItems.remove(itemId);
    } else {
      selectedItems.add(itemId);
    }
  }

  void selectAllItems() {
    if (selectedItems.length == cartItems.length) {
      selectedItems.clear();
    } else {
      selectedItems.assignAll(cartItems.map((item) => item.id));
    }
  }

  void deleteSelectedItems() {
    if (selectedItems.isEmpty) return;

    Get.dialog(
      AlertDialog(
        title: Text('Delete Items'),
        content: Text('Delete ${selectedItems.length} selected item(s)?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              final toDelete = List<String>.from(selectedItems);
              cartItems.removeWhere((item) => selectedItems.contains(item.id));
              selectedItems.clear();
              isSelectionMode.value = false;
              Get.back();
              for (final id in toDelete) {
                try { await ApiService().delete('/cart/remove/$id'); } catch (_) {}
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void setDeliveryOption(String option) {
    deliveryOption.value = option;
  }

  void removeCoupon() {
    couponCode.value = '';
    appliedCouponDiscount.value = 0.0;
  }

  final RxDouble appliedCouponDiscount = 0.0.obs;
  final RxBool isCouponLoading = false.obs;

  double _calculateDeliveryFee() {
    if (selectedOrderType.value == 0) {
      return _deliveryFeeRate.value;
    }
    return 0.0;
  }

  final RxDouble _deliveryFeeRate = 6.0.obs;

  double _calculateDiscount() {
    return appliedCouponDiscount.value;
  }

  Future<void> validateAndApplyCoupon(String code) async {
    if (code.isEmpty) return;
    isCouponLoading.value = true;
    try {
      final res = await ApiService().post('/rewards/validate-qr', {'code': code});
      if (res.success && res.data != null && res.data['type'] == 'coupon') {
        final coupon = res.data['coupon'];
        final pct = ((coupon['discountPercentage'] ?? 0) as num).toDouble();
        appliedCouponDiscount.value = subtotal * (pct / 100);
        couponCode.value = code;
        safeSnackbar('Coupon Applied', '${pct.toInt()}% discount applied!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white);
      } else {
        safeSnackbar('Invalid Coupon', res.message.isNotEmpty ? res.message : 'Coupon not found',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not validate coupon', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCouponLoading.value = false;
    }
  }

  void applyCoupon(String code) {
    validateAndApplyCoupon(code);
  }

  void goBack() {
    Get.back();
  }

  void proceedToCheckout() {
    if (cartItems.isEmpty) return;

    Get.toNamed(
      '/checkout',
      arguments: {
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'deliveryOption': selectedOrderType.value == 0
            ? 'delivery'
            : selectedOrderType.value == 1
                ? 'takeaway'
                : 'inStore',
        'paymentMethod': normalizedPaymentMethod,
      },
    );
  }

  void continueShopping() {
    Get.back();
  }

  // ==================== UTILITY METHODS ====================

  void addItem(CartItem item) {
    final existingIndex = cartItems.indexWhere(
      (existing) =>
          existing.id == item.id &&
          _compareOptions(existing.options, item.options),
    );

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += item.quantity;
      cartItems.refresh();
    } else {
      cartItems.add(item);
    }
  }

  bool _compareOptions(
    Map<String, dynamic>? options1,
    Map<String, dynamic>? options2,
  ) {
    if (options1 == null && options2 == null) return true;
    if (options1 == null || options2 == null) return false;
    if (options1.length != options2.length) return false;

    for (String key in options1.keys) {
      if (!options2.containsKey(key) || options1[key] != options2[key]) {
        return false;
      }
    }
    return true;
  }

  int getItemCountByType(CartItemType type) {
    return cartItems
        .where((item) => item.type == type)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  double getTotalByType(CartItemType type) {
    return cartItems
        .where((item) => item.type == type)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool containsItem(String itemId) {
    return cartItems.any((item) => item.id == itemId);
  }

  int getItemQuantity(String itemId) {
    try {
      return cartItems.firstWhere((item) => item.id == itemId).quantity;
    } catch (e) {
      return 0;
    }
  }

  void updateItemQuantity(String itemId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index].quantity = newQuantity;
      }
      cartItems.refresh();
    }
  }

  List<CartItem> get favoriteItems {
    return cartItems.where((item) => item.isFavorite).toList();
  }
}
