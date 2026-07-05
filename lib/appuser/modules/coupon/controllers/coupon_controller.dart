import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/coupon_details_sheet.dart';
import '../views/widgets/coupon_sheet.dart';
import '../views/widgets/package_sheet.dart';

class CouponController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Tab Controller
  late TabController tabController;

  // Observables
  final RxInt currentTabIndex = 0.obs;
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxList<Package> packages = <Package>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });
    loadData();
  }

  // Charger les données
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/rewards/coupons');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        coupons.value =
            data.map((c) {
              final isExpired = DateTime.parse(
                c['expiryDate'],
              ).isBefore(DateTime.now());
              return Coupon(
                id: c['_id'],
                code: c['code'],
                discount: (c['discount'] as num).toDouble(),
                type: CouponType.percentage, // Defaulting as example
                status:
                    isExpired
                        ? CouponStatus.expired
                        : (c['isActive']
                            ? CouponStatus.active
                            : CouponStatus.inactive),
                expiryDate: DateTime.parse(c['expiryDate']),
                usageCount: 0, // Placeholder
                maxUsage: 100, // Placeholder
              );
            }).toList();
      }
    } catch (e) {
      print('Error fetching coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Ouvrir le date picker
  void openDatePicker() {
    Get.snackbar(
      'Date Picker',
      'Opening date picker...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  // Créer un coupon
  void showCreateCouponSheet() {
    Get.bottomSheet(
      CreateCouponSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Créer un package
  void showCreatePackageSheet() {
    Get.bottomSheet(
      CreatePackageSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Voir les détails d'un coupon
  void viewCouponDetails(Coupon coupon) {
    Get.bottomSheet(
      CouponDetailsSheet(coupon: coupon),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Actions sur un coupon
  void editCoupon(Coupon coupon) {
    Get.snackbar(
      'Edit',
      'Editing coupon ${coupon.code}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  void deleteCoupon(Coupon coupon) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon d'avertissement
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 48.sp,
                  color: Colors.red.shade400,
                ),
              ),

              SizedBox(height: 24.h),

              // Titre
              Text(
                'Delete Coupon?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 12.h),

              // Message
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Are you sure you want to delete\n'),
                    TextSpan(
                      text: coupon.code,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(text: '?\nThis action cannot be undone.'),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        coupons.remove(coupon);
                        Get.back();
                        Get.snackbar(
                          'Deleted',
                          'Coupon deleted successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                          icon: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade200,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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

  void toggleCouponStatus(Coupon coupon) {
    final index = coupons.indexWhere((c) => c.id == coupon.id);
    if (index != -1) {
      coupons[index] = coupon.copyWith(
        status:
            coupon.status == CouponStatus.active
                ? CouponStatus.inactive
                : CouponStatus.active,
      );
      coupons.refresh();
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

// Modèles
class Coupon {
  final String id;
  final String code;
  final double discount;
  final CouponType type;
  final CouponStatus status;
  final DateTime expiryDate;
  final int usageCount;
  final int maxUsage;

  Coupon({
    required this.id,
    required this.code,
    required this.discount,
    required this.type,
    required this.status,
    required this.expiryDate,
    required this.usageCount,
    required this.maxUsage,
  });

  Coupon copyWith({
    String? id,
    String? code,
    double? discount,
    CouponType? type,
    CouponStatus? status,
    DateTime? expiryDate,
    int? usageCount,
    int? maxUsage,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discount: discount ?? this.discount,
      type: type ?? this.type,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      usageCount: usageCount ?? this.usageCount,
      maxUsage: maxUsage ?? this.maxUsage,
    );
  }

  double get usagePercentage => (usageCount / maxUsage) * 100;
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
}

enum CouponType { percentage, fixed }

enum CouponStatus { active, inactive, expired }

class Package {
  final String id;
  final String name;
  final double price;
  final int duration;
  final List<String> features;
  final bool isPopular;

  Package({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
  });
}
