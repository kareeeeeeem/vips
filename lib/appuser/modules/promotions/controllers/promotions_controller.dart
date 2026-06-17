import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../QR_scanner/views/q_r_scanner_view.dart';

enum PromotionType { orderOffer, shippingOffer }

class Promotion {
  final String id;
  final String title;
  final String brandName;
  final String? brandLogo;
  final String validUntil;
  final PromotionType type;
  final String? description;
  final double? discountPercentage;
  final double? discountAmount;
  bool isSelected;

  Promotion({
    required this.id,
    required this.title,
    required this.brandName,
    this.brandLogo,
    required this.validUntil,
    required this.type,
    this.description,
    this.discountPercentage,
    this.discountAmount,
    this.isSelected = false,
  });
}

class PromotionsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Tab Controller
  late TabController tabController;

  // Selected tab
  var selectedTab = 0.obs;

  // Promotions lists
  var orderOffers = <Promotion>[].obs;
  var shippingOffers = <Promotion>[].obs;
  var selectedPromotions = <String>[].obs;

  // Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      selectedTab.value = tabController.index;
    });
    _loadPromotions();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void _loadPromotions() {
    isLoading.value = true;

    // Simuler le chargement depuis une API
    Future.delayed(const Duration(milliseconds: 500), () {
      // Order Offers avec images réseau
      orderOffers.value = [
        Promotion(
          id: '1',
          title: 'D 10',
          brandName: 'McDonalds',
          brandLogo:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/McDonald%27s_Golden_Arches.svg/1200px-McDonald%27s_Golden_Arches.svg.png',
          validUntil: '01 February 2025',
          type: PromotionType.orderOffer,
          description: 'Get D 10 discount on your order',
          discountAmount: 10.0,
        ),
        Promotion(
          id: '2',
          title: '25% OFF',
          brandName: 'KFC',
          brandLogo:
              'https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/KFC_logo.svg/1200px-KFC_logo.svg.png',
          validUntil: '03 March 2025',
          type: PromotionType.orderOffer,
          description: '25% discount on all menu items',
          discountPercentage: 25.0,
        ),
        Promotion(
          id: '3',
          title: '1 Free Coffee',
          brandName: 'Starbucks',
          brandLogo:
              'https://upload.wikimedia.org/wikipedia/en/thumb/d/d3/Starbucks_Corporation_Logo_2011.svg/1200px-Starbucks_Corporation_Logo_2011.svg.png',
          validUntil: '11 September',
          type: PromotionType.orderOffer,
          description: 'Get one free coffee with any purchase',
        ),
        Promotion(
          id: '4',
          title: 'Pay 1 take 2',
          brandName: 'Vapiano',
          brandLogo: 'https://companieslogo.com/img/orig/vapiano-logo.png',
          validUntil: '03 October 2025',
          type: PromotionType.orderOffer,
          description: 'Buy one get one free on all pasta dishes',
        ),
        Promotion(
          id: '5',
          title: '30% OFF',
          brandName: 'Burger King',
          brandLogo:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Burger_King_logo_%281999%29.svg/2024px-Burger_King_logo_%281999%29.svg.png',
          validUntil: '15 March 2025',
          type: PromotionType.orderOffer,
          description: '30% discount on Whopper meals',
          discountPercentage: 30.0,
        ),
      ];

      // Shipping Offers
      shippingOffers.value = [
        Promotion(
          id: 's1',
          title: 'FREE DELIVERY',
          brandName: 'All Restaurants',
          brandLogo: 'https://cdn-icons-png.flaticon.com/512/3097/3097169.png',
          validUntil: '31 December 2025',
          type: PromotionType.shippingOffer,
          description: 'Free delivery on orders above D 20',
        ),
        Promotion(
          id: 's2',
          title: 'D 5 OFF Delivery',
          brandName: 'Pizza Hut',
          brandLogo:
              'https://upload.wikimedia.org/wikipedia/en/thumb/d/d2/Pizza_Hut_logo.svg/1200px-Pizza_Hut_logo.svg.png',
          validUntil: '20 April 2025',
          type: PromotionType.shippingOffer,
          description: 'D 5 discount on delivery fees',
          discountAmount: 5.0,
        ),
        Promotion(
          id: 's3',
          title: '50% OFF Delivery',
          brandName: 'Dominos',
          brandLogo:
              'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Dominos_pizza_logo.svg/1200px-Dominos_pizza_logo.svg.png',
          validUntil: '30 June 2025',
          type: PromotionType.shippingOffer,
          description: 'Half price delivery on all orders',
          discountPercentage: 50.0,
        ),
      ];

      isLoading.value = false;
    });
  }

  // Get promotions based on selected tab
  List<Promotion> get currentPromotions {
    return selectedTab.value == 0 ? orderOffers : shippingOffers;
  }

  // Toggle promotion selection
  void togglePromotionSelection(String promotionId) {
    if (selectedPromotions.contains(promotionId)) {
      selectedPromotions.remove(promotionId);
    } else {
      selectedPromotions.add(promotionId);
    }

    // Update promotion isSelected status
    for (var promo in orderOffers) {
      if (promo.id == promotionId) {
        promo.isSelected = !promo.isSelected;
      }
    }
    for (var promo in shippingOffers) {
      if (promo.id == promotionId) {
        promo.isSelected = !promo.isSelected;
      }
    }

    orderOffers.refresh();
    shippingOffers.refresh();
  }

  // Add new promotion (scanner ou manuel)
  void addNewPromotion() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              'Add Promotion',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro Display',
              ),
            ),

            SizedBox(height: 24.h),

            // Scan QR Code option
            _buildAddOption('Scan QR Code', Icons.qr_code_scanner, () {
              Get.back();
              scanQRCode();
            }),

            SizedBox(height: 12.h),

            // Enter code manually option
            _buildAddOption('Enter Code Manually', Icons.keyboard, () {
              Get.back();
              enterCodeManually();
            }),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildAddOption(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: const Color(0xFFFF6B35), size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro Display',
                  ),
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

  // Scan QR Code
  void scanQRCode() {
    Get.to(() => QRScannerView());
  }

  // Enter code manually
  void enterCodeManually() {
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
                'Enter Promo Code',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: 'PROMO CODE',
                  hintStyle: TextStyle(
                    color: const Color(0xFFD1D5DB),
                    letterSpacing: 2,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: const Color(0xFFFF6B35),
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (code) {
                  Get.back();
                  applyPromoCode(code);
                },
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // TODO: Valider le code
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  // Apply promo code
  void applyPromoCode(String code) {
    // TODO: Valider le code avec l'API
    Get.snackbar(
      'Promo Code Applied',
      'Code "$code" has been applied successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  // Apply selected promotions
  void applyPromotions() {
    if (selectedPromotions.isEmpty) {
      return;
    }

    Get.back(result: selectedPromotions);
  }

  // Go back
  void goBack() {
    Get.back();
  }

  // View promotion details
  void viewPromotionDetails(Promotion promotion) {
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
              // Brand logo
              if (promotion.brandLogo != null)
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.network(
                      promotion.brandLogo!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              SizedBox(height: 20.h),

              // Title
              Text(
                promotion.title,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro Display',
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              // Brand name
              Text(
                promotion.brandName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'SF Pro Display',
                ),
              ),

              SizedBox(height: 16.h),

              // Description
              if (promotion.description != null)
                Text(
                  promotion.description!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                  ),
                  textAlign: TextAlign.center,
                ),

              SizedBox(height: 16.h),

              // Valid until
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Valid until ${promotion.validUntil}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Got it',
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
}
