import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/order_success.dart';
import '../views/widgets/payment_method_bottomsheet.dart';

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
      price: json['price'].toDouble(),
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

  // Order Type Management
  var selectedOrderType = 0.obs; // 0: Delivery, 1: Takeaway, 2: In Store
  var deliveryAddress = '221B Baker Street, London, United K...'.obs;
  var selectedDate = 'Today (26 Nov, 2025)'.obs;
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
  double get vipsDiscount => 0.1; // 100 VIPs points
  double get couponDiscount => 0.4; // 400 VIPs points
  double get serviceCharge => 0.0;
  double get vatTax =>
      (subtotal - vipsDiscount - couponDiscount) * 0.07; // 7% tax
  double get tipAmount =>
      selectedTipAmount.value > 0
          ? selectedTipAmount.value
          : customTipAmount.value;
  double get total =>
      subtotal +
      deliveryFee -
      vipsDiscount -
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

  void _loadCartItems() {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 500), () {
      cartItems.value = [
        CartItem(
          id: '1',
          merchantId: '64abcd1234567890abcdef12',
          name: 'Pizza Hub happy meal',
          description: 'Delicious combo with pizza, fries and drink',
          image:
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop',
          price: 6.0,
          oldPrice: 10.0,
          type: CartItemType.food,
          quantity: 1,
          category: 'Pizza Hub',
          isFavorite: false,
        ),
        CartItem(
          id: '2',
          name: 'Cherry Tomato Salad',
          description: 'Fresh salad with cherry tomatoes and greens',
          image:
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop',
          price: 6.0,
          oldPrice: 10.0,
          type: CartItemType.food,
          quantity: 2,
          category: 'Pizza Hub',
          isFavorite: true,
        ),
        CartItem(
          id: '3',
          name: 'Margherita Pizza',
          description: 'Classic Italian pizza with fresh mozzarella',
          image:
              'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=400&fit=crop',
          price: 8.5,
          oldPrice: 12.0,
          type: CartItemType.food,
          quantity: 1,
          category: 'Pizza Hub',
          isFavorite: false,
        ),
        CartItem(
          id: '4',
          name: 'Chicken Burger Deluxe',
          description: 'Juicy chicken patty with special sauce',
          image:
              'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&h=400&fit=crop',
          price: 7.5,
          oldPrice: 11.0,
          type: CartItemType.food,
          quantity: 1,
          category: 'Burger King',
          isFavorite: false,
        ),
        CartItem(
          id: '5',
          name: 'Caesar Salad',
          description: 'Crispy romaine with parmesan and croutons',
          image:
              'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=400&fit=crop',
          price: 5.5,
          oldPrice: 8.0,
          type: CartItemType.food,
          quantity: 1,
          category: 'Salad Bar',
          isFavorite: true,
        ),
      ];
      isLoading.value = false;
    });
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
                'VIPs Discount',
                'V₽+ ${(vipsDiscount * 1000).toInt()}',
                isDiscount: true,
              ),
              _buildBreakdownRow(
                'Coupon Discount',
                'V₽+ ${(couponDiscount * 1000).toInt()}',
                isDiscount: true,
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
    // TODO: Navigate to address selection page
    Get.snackbar(
      'Select Address',
      'Address selection page coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF6B35).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
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
    Get.put(PaymentMethodController(totalBill: total, walletPoints: 28560));
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          children: [
            PaymentMethodBottomSheet(
              totalBill: total,
              walletPoints: 28560,
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
      Get.snackbar(
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
        'merchantId': cartItems.first.merchantId ?? '64abcd1234567890abcdef12',
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
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // close loading dialog
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }



  void addItems() {
    Get.back();
  }

  void updateNote(String note) {
    deliveryNote.value = note;
  }

  void clearCartLocally() {
    cartItems.clear();
    selectedItems.clear();
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
    }
  }

  void decreaseQuantity(CartItem item) {
    final index = cartItems.indexWhere((i) => i.id == item.id);
    if (index != -1 && cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
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
                color: Colors.black.withOpacity(0.1),
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
                  color: Colors.red.withOpacity(0.1),
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
                      onTap: () {
                        cartItems.remove(item);
                        selectedItems.remove(item.id);
                        Get.back();
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
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
                color: Colors.black.withOpacity(0.1),
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
                  color: Colors.red.withOpacity(0.1),
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
                      onTap: () {
                        cartItems.clear();
                        selectedItems.clear();
                        isSelectionMode.value = false;
                        deliveryNote.value = '';
                        Get.back();
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
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
            onPressed: () {
              cartItems.removeWhere((item) => selectedItems.contains(item.id));
              selectedItems.clear();
              isSelectionMode.value = false;
              Get.back();
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

  void applyCoupon(String code) {
    couponCode.value = code;
  }

  void removeCoupon() {
    couponCode.value = '';
  }

  double _calculateDeliveryFee() {
    if (selectedOrderType.value == 0) {
      // Delivery
      return 6.0;
    } else {
      // Takeaway or In Store
      return 0.0;
    }
  }

  double _calculateDiscount() {
    if (couponCode.value == 'SAVE10') {
      return subtotal * 0.1;
    }
    return 0.0;
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
