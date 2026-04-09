import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/app/modules/home/controllers/home_controller.dart';

class BuildBillPayments extends GetView<HomeController> {
  const BuildBillPayments({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF06B6D4).withOpacity(0.2),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          // Header avec titre et bouton "voir plus"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Icône fire + titre
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 20.sp,
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Bill Payments'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ],
                ),

                Spacer(),

                // Bouton voir plus
                GestureDetector(
                  onTap: () => controller.navigateToAllHotDeals(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'view_all'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Pay all your bills in one place - instant payments, zero hassle, maximum convenience!",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),

          // Liste horizontale des deals
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.billTypes.length,
              itemBuilder: (context, index) {
                final billType = controller.billTypes[index];
                return Container(
                  width: 60.w,
                  margin: EdgeInsets.only(right: 16.w),
                  child: _buildBillTypeCard(
                    billType: billType,
                    onTap: () => controller.navigateToBillType(billType),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTypeCard({
    required Map<String, dynamic> billType,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Container avec image
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child:
                  billType['imageUrl'] != null
                      ? Image.network(
                        billType['imageUrl'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                              strokeWidth: 2,
                              color: const Color(0xFF06B6D4),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(
                              billType['color'] ?? 0xFF06B6D4,
                            ).withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                billType['icon'] ?? Icons.receipt,
                                color: Color(billType['color'] ?? 0xFF06B6D4),
                                size: 32.sp,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Color(
                          billType['color'] ?? 0xFF06B6D4,
                        ).withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            billType['icon'] ?? Icons.receipt,
                            color: Color(billType['color'] ?? 0xFF06B6D4),
                            size: 32.sp,
                          ),
                        ),
                      ),
            ),
          ),

          SizedBox(height: 8.h),

          // Texte du type de facture
          Text(
            billType['name'],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
              fontFamily: 'SF Pro Text',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
