import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../QR_scanner/views/q_r_scanner_view.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum PromotionType { orderOffer, shippingOffer }

class Promotion {
  final String id;
  final String code;
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
    required this.code,
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

  final codeController = TextEditingController();

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
    codeController.dispose();
    super.onClose();
  }

  Future<void> _loadPromotions() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/content/promotions');
      if (response.success && response.data != null) {
        final List<dynamic> raw = response.data;
        final all = raw.map((p) => Promotion(
          // Real records only have Mongo's `_id` — `id` was never a field
          // the backend returns, so every promotion collapsed onto the
          // same empty-string id and selecting one silently selected all
          // of them together.
          id: (p['_id'] ?? p['id'] ?? '').toString(),
          code: (p['code'] ?? '').toString(),
          title: p['title'] ?? '',
          brandName: p['subtitle'] ?? '',
          validUntil: p['expiresAt'] != null
              ? DateTime.parse(p['expiresAt']).toString().substring(0, 10)
              : '',
          type: p['type'] == 'shipping' ? PromotionType.shippingOffer : PromotionType.orderOffer,
          description: p['subtitle'],
          discountPercentage: (p['discount'] ?? 0) > 0 ? (p['discount'] as num).toDouble() : null,
        )).toList();

        orderOffers.value = all.where((p) => p.type == PromotionType.orderOffer).toList();
        shippingOffers.value = all.where((p) => p.type == PromotionType.shippingOffer).toList();
      }
    } catch (_) {}
    isLoading.value = false;
  }

  // /rewards/apply-coupon only recognizes merchant-created Coupon
  // documents — a different collection from the seeded site-wide
  // Promotion codes shown on this screen (SAVE20, WELCOME15, ...), so it
  // rejected every real promotion as "invalid". /rewards/validate-qr
  // already resolves gift codes, merchant ids, Coupons, and (as of this
  // fix) Promotions too, so it's the correct endpoint for any code typed
  // or tapped here.
  Future<void> applyPromoCode(String code) async {
    if (code.isEmpty) return;
    try {
      final response = await ApiService().post('/rewards/validate-qr', {'code': code});
      if (response.success) {
        safeSnackbar(
          'Promo Code Applied',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
        );
      } else {
        safeSnackbar('Invalid Code', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      safeSnackbar('Error', 'Could not apply code', snackPosition: SnackPosition.BOTTOM);
    }
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
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
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
                controller: codeController,
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
                  if (code.trim().isNotEmpty) {
                    Get.back();
                    applyPromoCode(code.trim());
                    codeController.clear();
                  }
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
                        final code = codeController.text.trim();
                        if (code.isNotEmpty) {
                          Get.back();
                          applyPromoCode(code);
                          codeController.clear();
                        }
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

  // Apply selected promotions. This screen is reached standalone (from
  // Home's Offers filter), not always as a picker another screen awaits a
  // result from, so applying has to actually do something real here
  // rather than just popping with a result nothing may consume.
  Future<void> applyPromotions() async {
    if (selectedPromotions.isEmpty) return;

    final all = [...orderOffers, ...shippingOffers];
    final selected = all.where((p) => selectedPromotions.contains(p.id) && p.code.isNotEmpty).toList();

    isLoading.value = true;
    int applied = 0;
    String? lastError;
    for (final promo in selected) {
      final response = await ApiService().post('/rewards/validate-qr', {'code': promo.code});
      if (response.success) {
        applied++;
      } else {
        lastError = response.message;
      }
    }
    isLoading.value = false;

    if (applied > 0) {
      safeSnackbar(
        'Applied',
        applied == selected.length
            ? '$applied promotion${applied > 1 ? 's' : ''} applied!'
            : '$applied of ${selected.length} promotions applied. ${lastError ?? ''}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      selectedPromotions.clear();
      orderOffers.refresh();
      shippingOffers.refresh();
    } else {
      safeSnackbar('Error', lastError ?? 'Could not apply promotions', snackPosition: SnackPosition.BOTTOM);
    }
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
                        color: Colors.black.withValues(alpha: 0.1),
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

              if (promotion.code.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      applyPromoCode(promotion.code);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Apply This Promo',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Close button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
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
