import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/checkout_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CheckoutController());
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderTypeSection(),
                    SizedBox(height: 16.h),
                    _buildDeliveryAddressCard(),
                    SizedBox(height: 12.h),
                    _buildPaymentMethodCard(),
                    SizedBox(height: 12.h),
                    _buildPromotionsCard(),
                    SizedBox(height: 24.h),
                    _buildTipSection(),
                    SizedBox(height: 24.h),
                    _buildOrderSummary(),
                    SizedBox(height: 120.h), // Space for bottom section
                  ],
                ),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
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
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
          ),
          SizedBox(width: 24.w), // For symmetry
        ],
      ),
    );
  }

  Widget _buildOrderTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Receive Order Type',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
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
        SizedBox(height: 12.h),

        // VERSION AMÉLIORÉE avec Wrap pour adaptabilité
        Obx(
          () => Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _buildOrderTypeOptionImproved(
                'Delivery',
                '+ D 6',
                OrderType.delivery,
                Icons.delivery_dining,
              ),
              _buildOrderTypeOptionImproved(
                'Takeaway',
                'free',
                OrderType.takeaway,
                Icons.shopping_bag_outlined,
              ),
              _buildOrderTypeOptionImproved(
                'In Store',
                'free',
                OrderType.inStore,
                Icons.store_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeOptionImproved(
    String title,
    String subtitle,
    OrderType type,
    IconData icon,
  ) {
    final isSelected = controller.selectedOrderType.value == type;

    return GestureDetector(
      onTap: () => controller.selectOrderType(type),
      child: Container(
        width: (Get.width - 52.w) / 3, // Calcul dynamique de la largeur
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF6B35) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                size: 20.sp,
              ),
            ),

            SizedBox(height: 8.h),

            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFFFF6B35) : Colors.black,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 4.h),

            // Sous-titre
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color:
                    isSelected
                        ? const Color(0xFFFF6B35).withOpacity(0.8)
                        : const Color(0xFF6B7280),
                fontFamily: 'SF Pro Text',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return GestureDetector(
      onTap: controller.selectDeliveryAddress,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.location_on,
                color: const Color(0xFFFF6B35),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.deliveryType.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Obx(
                    () => Text(
                      controller.deliveryAddress.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
    );
  }

  Widget _buildPaymentMethodCard() {
    return GestureDetector(
      onTap: controller.selectPaymentMethod,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.credit_card,
                color: const Color(0xFFFF6B35),
                size: 20.sp,
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Obx(
                    () => Text(
                      controller.paymentMethod.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
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
    );
  }

  Widget _buildPromotionsCard() {
    return GestureDetector(
      onTap: controller.viewPromotions,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.local_offer,
                color: const Color(0xFFFF6B35),
                size: 20.sp,
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => Wrap(
                      spacing: 6.w,
                      children:
                          controller.activePromotions
                              .map(
                                (promo) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFBBF24),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    promo,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'SF Pro Display',
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
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
    );
  }

  Widget _buildTipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'You may also like! ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'SF Pro Display',
            ),
            children: [
              TextSpan(
                text: 'Give Thanks :',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Column(
            children: [
              _buildTipOption(1.0, '* '),
              _buildTipOption(2.0, '** '),
              _buildTipOption(3.0, '*** '),
              _buildTipOption(4.0, '**** '),
              _buildTipOption(5.0, '***** '),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Text(
                'D',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF6B35),
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(width: 8.w),
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
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontFamily: 'SF Pro Text',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      controller.selectedTip.value = -1;
                      controller.customTip.value = double.tryParse(value) ?? 0;
                    } else {
                      controller.customTip.value = 0;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipOption(double amount, String stars) {
    final isSelected = controller.selectedTip.value == amount;

    return GestureDetector(
      onTap: () => controller.selectTip(amount),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF6B35) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stars,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontFamily: 'SF Pro Text',
              ),
            ),
            Row(
              children: [
                Text(
                  '+ D ${amount.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                SizedBox(width: 8.w),
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
                      width: 2,
                    ),
                  ),
                  child:
                      isSelected
                          ? Center(
                            child: Container(
                              width: 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                          : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Obx(
        () => Column(
          children: [
            _buildSummaryRow('Subtotal', controller.subtotal.value),
            SizedBox(height: 12.h),
            _buildSummaryRow('Delivery Fee', controller.deliveryFee.value),
            SizedBox(height: 12.h),
            _buildSummaryRow(
              'Discount',
              -controller.discount.value,
              isDiscount: true,
            ),
            Divider(height: 24.h, color: const Color(0xFFE5E7EB)),
            _buildSummaryRow(
              'Grand Total',
              controller.grandTotal,
              isGrandTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isGrandTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isGrandTotal ? 16.sp : 14.sp,
            fontWeight: isGrandTotal ? FontWeight.w600 : FontWeight.w400,
            color: Colors.black,
            fontFamily: 'SF Pro Display',
          ),
        ),
        Text(
          '${isDiscount ? '- ' : ''}D ${amount.toStringAsFixed(3)}',
          style: TextStyle(
            fontSize: isGrandTotal ? 18.sp : 14.sp,
            fontWeight: isGrandTotal ? FontWeight.w700 : FontWeight.w500,
            color: isDiscount ? const Color(0xFF22C55E) : Colors.black,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ],
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'VIPs Club! Place Order and Get',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF92400E),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '+',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF92400E),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.circle,
                      color: const Color(0xFFFBBF24),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Obx(
                      () => Text(
                        '${controller.vipPoints.value}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: controller.placeOrder,
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

// Binding
class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
