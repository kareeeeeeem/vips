import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderItem {
  final String id;
  final String name;
  final String? image;
  final double price;
  final int quantity;
  final int couponCount;
  final Map<String, dynamic>? addons;

  OrderItem({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    this.quantity = 1,
    this.couponCount = 0,
    this.addons,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: json['price'].toDouble(),
      quantity: json['quantity'] ?? 1,
      couponCount: json['couponCount'] ?? 0,
      addons: json['addons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'couponCount': couponCount,
      'addons': addons,
    };
  }
}

class OrderRequestController extends GetxController {
  // Order Info
  var orderId = ''.obs;
  var orderStatus = 'Pending'.obs;
  var paymentMethod = 'Cash On Delivery'.obs;
  var paymentStatus = 'PAID'.obs;
  var deliveryType = 'Home Delivery'.obs;

  // Current Step (0: Assigned, 1: Picked, 2: On The Way, 3: Delivered)
  var currentOrderStep = 0.obs;

  // Restaurant Info
  var restaurantName = ''.obs;
  var restaurantAddress = ''.obs;
  var restaurantPhone = ''.obs;
  var restaurantLogo = ''.obs;

  // Customer Info
  var customerName = ''.obs;
  var customerPhone = ''.obs;
  var deliveryAddress = ''.obs;

  // Order Items
  var orderItems = <OrderItem>[].obs;

  // Pricing
  var itemPrice = 0.0.obs;
  var addonCost = 0.0.obs;
  var subtotal = 0.0.obs;
  var vipDiscount = 0.obs;
  var couponDiscount = 0.obs;
  var serviceCharge = 0.0.obs;
  var deliveryCharge = 0.0.obs;
  var vatTax = 0.0.obs;
  var grandTotal = 0.0.obs;

  // QR Code
  var qrData = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrderData();
    _generateQRCode();
  }

  void _loadOrderData() {
    // Charger les données depuis les arguments
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;

      orderId.value = args['orderId'] ?? '100113';
      orderStatus.value = args['status'] ?? 'Pending';
      paymentMethod.value = args['paymentMethod'] ?? 'Cash On Delivery';
      deliveryType.value = args['deliveryType'] ?? 'Home Delivery';

      // Step
      currentOrderStep.value = args['currentStep'] ?? 0;

      // Restaurant
      restaurantName.value = args['restaurantName'] ?? 'Pizza Hut';
      restaurantAddress.value =
          args['restaurantAddress'] ??
          'House: 80, Road: 00, Test City\n01/Jun/2025: 10:47';
      restaurantPhone.value = args['restaurantPhone'] ?? '71******';

      // Customer
      customerName.value = args['customerName'] ?? 'Jamil Test';
      customerPhone.value = args['customerPhone'] ?? '95910000';
      deliveryAddress.value =
          args['deliveryAddress'] ?? 'Rue Hédi Nouira, 1002 Tunis';

      // Items
      if (args['items'] != null) {
        orderItems.value =
            (args['items'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList();
      } else {
        // Sample data
        orderItems.value = [
          OrderItem(
            id: '1',
            name: 'McDonald\'s',
            image:
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
            price: 80.0,
            quantity: 1,
            couponCount: 3,
          ),
        ];
      }

      // Pricing
      itemPrice.value = args['itemPrice'] ?? 80.0;
      addonCost.value = args['addonCost'] ?? 0.0;
      subtotal.value = args['subtotal'] ?? 80.0;
      vipDiscount.value = args['vipDiscount'] ?? 100;
      couponDiscount.value = args['couponDiscount'] ?? 400;
      serviceCharge.value = args['serviceCharge'] ?? 0.0;
      deliveryCharge.value = args['deliveryCharge'] ?? 0.0;
      vatTax.value = args['vatTax'] ?? 7.0;
      grandTotal.value = args['grandTotal'] ?? 87.0;
    } else {
      // Données par défaut
      _loadDefaultData();
    }
  }

  void _loadDefaultData() {
    orderId.value = '100113';
    orderStatus.value = 'Pending';
    paymentMethod.value = 'Cash On Delivery';
    paymentStatus.value = 'PAID';
    deliveryType.value = 'Home Delivery';

    currentOrderStep.value = 0;

    restaurantName.value = 'Pizza Hut';
    restaurantAddress.value =
        'House: 80, Road: 00, Test City\n01/Jun/2025: 10:47';
    restaurantPhone.value = '71******';

    customerName.value = 'Jamil Test';
    customerPhone.value = '95910000';
    deliveryAddress.value = 'Rue Hédi Nouira, 1002 Tunis';

    orderItems.value = [
      OrderItem(
        id: '1',
        name: 'McDonald\'s',
        image:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
        price: 80.0,
        quantity: 1,
        couponCount: 3,
      ),
    ];

    itemPrice.value = 80.0;
    addonCost.value = 0.0;
    subtotal.value = 80.0;
    vipDiscount.value = 100;
    couponDiscount.value = 400;
    serviceCharge.value = 0.0;
    deliveryCharge.value = 0.0;
    vatTax.value = 7.0;
    grandTotal.value = 87.0;
  }

  void _generateQRCode() {
    qrData.value = '''
{
  "orderId": "${orderId.value}",
  "customerName": "${customerName.value}",
  "total": ${grandTotal.value},
  "restaurant": "${restaurantName.value}",
  "deliveryAddress": "${deliveryAddress.value}",
  "timestamp": "${DateTime.now().toIso8601String()}"
}
''';
  }

  void reorderItem(OrderItem item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restart_alt, color: const Color(0xFFFF6B35), size: 48),
              SizedBox(height: 16),
              Text(
                'Reorder Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Do you want to reorder "${item.name}"?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _addToCart(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                      ),
                      child: Text('Reorder'),
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

  void _addToCart(OrderItem item) {
    Get.snackbar(
      'Added to Cart',
      '${item.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void viewItemDetails(OrderItem item) {
    // TODO: Naviguer vers la page de détails de l'article
    Get.toNamed('/item-details', arguments: {'item': item});
  }

  void acceptRequest() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF22C55E),
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Accept Order Request',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Do you want to accept this order request?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _acceptOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                      ),
                      child: Text('Accept'),
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

  void _acceptOrder() {
    orderStatus.value = 'Accepted';
    currentOrderStep.value = 1; // Passer à "Picked"

    Get.snackbar(
      'Order Accepted',
      'Order #${orderId.value} has been accepted',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void updateOrderStep(int step) {
    currentOrderStep.value = step;

    String status = '';
    switch (step) {
      case 0:
        status = 'Assigned';
        break;
      case 1:
        status = 'Picked';
        break;
      case 2:
        status = 'On The Way';
        break;
      case 3:
        status = 'Delivered';
        break;
    }

    orderStatus.value = status;
  }

  void goBack() {
    Get.back();
  }

  // ==================== API METHODS ====================

  Future<void> fetchOrderDetails(String orderId) async {
    try {
      // TODO: Appel API pour récupérer les détails de la commande
      // final response = await ApiService.getOrderDetails(orderId);
      // _updateFromResponse(response);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load order details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateOrderStatus(String status) async {
    try {
      // TODO: Appel API pour mettre à jour le statut
      // await ApiService.updateOrderStatus(orderId.value, status);
      orderStatus.value = status;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }
}

class OrderRequestView extends GetView<OrderRequestController> {
  const OrderRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(OrderRequestController());
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Orange Card with QR
                    _buildOrangeCard(),

                    SizedBox(height: 16.h),

                    // Stepper
                    _buildOrderStepper(),

                    SizedBox(height: 24.h),

                    // Restaurant Info
                    _buildRestaurantInfo(),

                    SizedBox(height: 16.h),

                    // Pending Badge & Delivery Type
                    _buildPendingSection(),

                    SizedBox(height: 16.h),

                    // Order Details Card
                    _buildOrderDetailsCard(),

                    SizedBox(height: 16.h),

                    // Items List
                    _buildItemsSection(),

                    SizedBox(height: 16.h),

                    // Price Breakdown
                    _buildPriceBreakdown(),

                    SizedBox(height: 20.h),

                    // Accept Request Button
                    _buildAcceptRequestButton(),

                    SizedBox(height: 16.h),

                    // Copyright
                    _buildCopyright(),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.close, color: Colors.black, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrangeCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A5B), Color(0xFFFF6B35)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REQUEST',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'SF Pro Display',
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'PAID',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Obx(
                      () => Text(
                        controller.paymentMethod.value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // QR Code
          Container(
            width: 80.w,
            height: 80.h,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Obx(
              () => QrImageView(
                data: controller.qrData.value,
                version: QrVersions.auto,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStepper() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() {
        final currentStep = controller.currentOrderStep.value;

        return Row(
          children: [
            Expanded(
              child: _buildStepItem(
                icon: Icons.hourglass_bottom,
                label: 'Assigned',
                isActive: currentStep >= 0,
                color: const Color(0xFF0891B2),
              ),
            ),
            _buildStepConnector(isActive: currentStep >= 1),
            Expanded(
              child: _buildStepItem(
                icon: Icons.inventory_2,
                label: 'Picked',
                isActive: currentStep >= 1,
                color: const Color(0xFFFBBF24),
              ),
            ),
            _buildStepConnector(isActive: currentStep >= 2),
            Expanded(
              child: _buildStepItem(
                icon: Icons.directions_bike,
                label: 'On The Way',
                isActive: currentStep >= 2,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: isActive ? color : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.black : const Color(0xFF9CA3AF),
            fontFamily: 'SF Pro Text',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Container(
      width: 40.w,
      height: 2.h,
      margin: EdgeInsets.only(bottom: 30.h),
      color: isActive ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.local_pizza,
              color: const Color(0xFFFF6B35),
              size: 32.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.restaurantName.value,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    controller.restaurantAddress.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontFamily: 'SF Pro Text',
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Phone: ${controller.restaurantPhone.value}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontFamily: 'SF Pro Text',
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

  Widget _buildPendingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Pending',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF22C55E),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
          Obx(
            () => Text(
              controller.deliveryType.value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFD1D5DB),
          strokeWidth: 1,
          dashWidth: 6,
          dashSpace: 4,
          radius: 16.r,
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Obx(
            () => Column(
              children: [
                _buildDetailRow('Order ID', controller.orderId.value),
                SizedBox(height: 12.h),
                _buildDetailRow('Customer Name', controller.customerName.value),
                SizedBox(height: 12.h),
                _buildDetailRow('Phone', controller.customerPhone.value),
                SizedBox(height: 12.h),
                _buildDetailRow(
                  'Delivery Address',
                  controller.deliveryAddress.value,
                  isAddress: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAddress = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF9CA3AF),
              fontFamily: 'SF Pro Text',
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => Column(
          children:
              controller.orderItems.map((item) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Item Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: 80.w,
                              height: 80.h,
                              color: const Color(0xFFF3F4F6),
                              child:
                                  item.image != null
                                      ? CachedNetworkImage(
                                        imageUrl: item.image!,
                                        fit: BoxFit.cover,
                                      )
                                      : Icon(
                                        Icons.fastfood,
                                        color: const Color(0xFF9CA3AF),
                                        size: 40.sp,
                                      ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'D ${item.price.toStringAsFixed(3)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFF6B35),
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                                if (item.couponCount > 0) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${item.couponCount} Coupon',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF9CA3AF),
                                      fontFamily: 'SF Pro Text',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.reorderItem(item),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                              ),
                              child: Text(
                                'Reorder',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.viewItemDetails(item),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFEDE8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                              ),
                              child: Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF6B35),
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(
        () => Column(
          children: [
            _buildPriceRow(
              'Item Price',
              'D ${controller.itemPrice.value.toStringAsFixed(3)}',
            ),
            SizedBox(height: 8.h),
            _buildPriceRow(
              'Addon Cost',
              'D ${controller.addonCost.value.toStringAsFixed(3)}',
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDE8),
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
                    'D ${controller.subtotal.value.toStringAsFixed(3)}',
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
            SizedBox(height: 12.h),
            _buildPriceRow(
              'VIPs Discount',
              'VPT ${controller.vipDiscount.value}',
            ),
            SizedBox(height: 8.h),
            _buildPriceRow(
              'Coupon Discount',
              'VPT ${controller.couponDiscount.value}',
            ),
            SizedBox(height: 8.h),
            _buildPriceRow(
              'Service Charge',
              'D ${controller.serviceCharge.value.toStringAsFixed(3)}',
            ),
            SizedBox(height: 8.h),
            _buildPriceRow(
              'Delivery Charge',
              'D ${controller.deliveryCharge.value.toStringAsFixed(3)}',
            ),
            SizedBox(height: 8.h),
            _buildPriceRow(
              'Vat/Tax',
              'D ${controller.vatTax.value.toStringAsFixed(3)}',
            ),
            SizedBox(height: 16.h),
            Container(height: 1.h, color: const Color(0xFFE5E7EB)),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                Text(
                  'D ${controller.grandTotal.value.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9CA3AF),
            fontFamily: 'SF Pro Text',
          ),
        ),
        Text(
          value,
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

  Widget _buildAcceptRequestButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Accept Request',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9CA3AF),
              fontFamily: 'SF Pro Display',
            ),
          ),
          Row(
            children: [
              Icon(Icons.schedule, color: const Color(0xFFFF6B35), size: 20.sp),
              SizedBox(width: 6.w),
              Text(
                'Pending',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6B35),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2025 VIPs App. All right reserved',
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color(0xFF9CA3AF),
        fontFamily: 'SF Pro Text',
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final dashPath = _createDashedPath(path, dashWidth, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final Path dest = Path();
    for (PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dashWidth : dashSpace;
        if (distance + length > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        } else {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, distance + length),
              Offset.zero,
            );
          }
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class OrderRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRequestController>(() => OrderRequestController());
  }
}
