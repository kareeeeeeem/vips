import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/Cart/views/widgets/my_locations.dart';

import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  CartView({Key? key}) : super(key: key);

  // GlobalKey pour la section Cart Items
  final GlobalKey _cartItemsKey = GlobalKey();

  // ScrollController pour contrôler le scroll
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Get.put(CartController());
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFFF6B35),
                    ),
                  );
                }

                if (controller.cartItems.isEmpty) {
                  return _buildEmptyCart();
                }

                return _buildCartContent();
              }),
            ),
            Obx(
              () =>
                  controller.cartItems.isNotEmpty
                      ? _buildBottomSection()
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour scroller vers les Cart Items
  void _scrollToCartItems() {
    final context = _cartItemsKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0, // 0.0 = top, 0.5 = center, 1.0 = bottom
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.goBack,
            child: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 24.h),
          Text(
            'Your basket is empty',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'SF Pro Display',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Text',
            ),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: controller.continueShopping,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Start Shopping',
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
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receive Order Type Section
          _buildReceiveOrderTypeSection(),

          SizedBox(height: 16.h),

          // Conditional Widget (Address OR Estimated Arrival Time)
          _buildConditionalWidget(),

          SizedBox(height: 16.h),

          // Payment Method
          _buildPaymentMethodSection(),

          SizedBox(height: 16.h),

          // Promotions
          _buildPromotionsSection(),

          SizedBox(height: 16.h),

          // Give Thanks / Tips Section
          _buildGiveThanksSection(),

          SizedBox(height: 24.h),

          // Order Summary Header avec GlobalKey
          Container(
            key: _cartItemsKey, // ← GlobalKey ici
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                GestureDetector(
                  onTap: controller.addItems,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF6B35)),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Add Items',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFF6B35),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Cart items list
          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.cartItems.length,
              itemBuilder: (context, index) {
                final item = controller.cartItems[index];
                return _buildCartItem(item);
              },
            ),
          ),

          SizedBox(height: 24.h),

          // Additional Note Section
          _buildAdditionalNoteSection(),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  // ==================== ADDITIONAL NOTE SECTION ====================

  Widget _buildAdditionalNoteSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Note',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: TextField(
              controller: controller.additionalNoteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share any specific delivery details here...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFFD1D5DB),
                  fontFamily: 'SF Pro Text',
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontFamily: 'SF Pro Text',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== RECEIVE ORDER TYPE ====================

  Widget _buildReceiveOrderTypeSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Receive Order Type',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.question_mark,
                  color: Colors.white,
                  size: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildOrderTypeOption('Delivery', '+D 6', 0),
              SizedBox(width: 12.w),
              _buildOrderTypeOption('Takeaway', 'free', 1),
              SizedBox(width: 12.w),
              _buildOrderTypeOption('In Store', 'free', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeOption(String title, String charge, int index) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedOrderType.value == index;
        return GestureDetector(
          onTap: () => controller.setOrderType(index),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color:
                    isSelected
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFFE5E7EB),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFFFF6B35),
                    size: 20.sp,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: const Color(0xFFD1D5DB),
                    size: 20.sp,
                  ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  charge,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ==================== CONDITIONAL WIDGET ====================

  Widget _buildConditionalWidget() {
    return Obx(() {
      if (controller.selectedOrderType.value == 0) {
        return _buildDeliveryAddressWidget();
      } else {
        return _buildEstimatedArrivalTimeWidget();
      }
    });
  }

  Widget _buildDeliveryAddressWidget() {
    return GestureDetector(
      onTap: () => Get.to(() => MyLocationsView()),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.location_on,
                color: const Color(0xFFFF6B35),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Deliver to',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.arrow_forward,
                        size: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Obx(
                    () => Text(
                      controller.deliveryAddress.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.black,
                        fontFamily: 'SF Pro Text',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFFD1D5DB),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedArrivalTimeWidget() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Arrival Time',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: controller.selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9CA3AF),
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(
                        () => Text(
                          controller.selectedDate.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: const Color(0xFF9CA3AF),
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: controller.selectTime,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Time',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9CA3AF),
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(
                        () => Text(
                          controller.selectedTime.value.isEmpty
                              ? 'Choose time'
                              : controller.selectedTime.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                controller.selectedTime.value.isEmpty
                                    ? const Color(0xFF9CA3AF)
                                    : Colors.black,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.access_time,
                    color: const Color(0xFF9CA3AF),
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PAYMENT METHOD ====================

  Widget _buildPaymentMethodSection() {
    return GestureDetector(
      onTap: controller.selectPaymentMethod,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.payment,
                color: const Color(0xFFFF6B35),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment method',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFFD1D5DB),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROMOTIONS ====================

  Widget _buildPromotionsSection() {
    return GestureDetector(
      onTap: controller.viewPromotions,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.local_offer,
                color: const Color(0xFFFF6B35),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promotions',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'FREE SHIPPING',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '20%',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
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
            Icon(
              Icons.chevron_right,
              color: const Color(0xFFD1D5DB),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GIVE THANKS / TIPS SECTION ====================

  Widget _buildGiveThanksSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You may also like! Give Thanks :',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
          ),
          SizedBox(height: 16.h),
          ...[1.0, 2.0, 3.0, 4.0, 5.0].map((amount) {
            return Obx(() {
              final isSelected = controller.selectedTipAmount.value == amount;
              return GestureDetector(
                onTap: () => controller.setTipAmount(amount),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '${'*' * amount.toInt()}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontFamily: 'SF Pro Text',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '+ D ${(amount * 1000).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontFamily: 'SF Pro Text',
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? const Color(0xFFFF6B35)
                                        : const Color(0xFFD1D5DB),
                                width: isSelected ? 6.w : 2.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Text(
                  'D',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: controller.customTipController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter custom amount',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFD1D5DB),
                        fontFamily: 'SF Pro Text',
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontFamily: 'SF Pro Text',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.setCustomTip(double.tryParse(value) ?? 0);
                      } else {
                        controller.setCustomTip(0);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child:
                      item.image != null && item.image!.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: item.image!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[400],
                                  size: 40.sp,
                                ),
                          )
                          : Icon(
                            Icons.restaurant,
                            color: Colors.grey[400],
                            size: 40.sp,
                          ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category ?? 'Pizza Hub',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFFB8B8B8),
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => controller.removeItem(item),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: const Color(0xFFB8B8B8),
                                  size: 22.sp,
                                ),
                              ),
                            ),
                            Container(
                              width: 1.w,
                              height: 20.h,
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              color: const Color(0xFFE0E0E0),
                            ),
                            GestureDetector(
                              onTap: () => controller.toggleFavorite(item),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                child: Icon(
                                  item.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      item.isFavorite
                                          ? const Color(0xFFFF6B35)
                                          : const Color(0xFFB8B8B8),
                                  size: 22.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.price.toStringAsFixed(3)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF6B35),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (item.oldPrice != null && item.oldPrice! > item.price)
                    Text(
                      '${item.oldPrice!.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFB8B8B8),
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  SizedBox(width: 6.w),
                  Text(
                    'D',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFB8B8B8),
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.decreaseQuantity(item),
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.remove,
                          color: const Color(0xFFFF6B35),
                          size: 18.sp,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.increaseQuantity(item),
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _scrollToCartItems, // ← Scroll vers Cart Items
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF6B35)),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: const Color(0xFFFF6B35),
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Cart Items (${controller.itemCount})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF6B35),
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => Row(
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
                        '${controller.total.toInt()}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      Text(
                        '.${((controller.total - controller.total.toInt()) * 1000).toInt().toString().padLeft(3, '0')}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 24.sp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: controller.proceedToCheckout,
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
        ],
      ),
    );
  }
}

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}
