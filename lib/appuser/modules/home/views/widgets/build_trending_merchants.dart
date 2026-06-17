import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

class BuildTrendingMerchants extends GetView<HomeController> {
  const BuildTrendingMerchants({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec icône et titre
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                // Icône trending
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: 20.sp,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'trending_merchants'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Scroll horizontal des merchants
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: controller.trendingMerchants.length,
              itemBuilder: (context, index) {
                final merchant = controller.trendingMerchants[index];
                return Container(
                  width: 80.w,
                  margin: EdgeInsets.only(right: 8.w),
                  child: _buildMerchantCard(
                    merchant: merchant,
                    onTap: () => controller.navigateToMerchant(merchant),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantCard({
    required Map<String, dynamic> merchant,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Container du logo
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Image.network(
                  merchant['logo'],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                        strokeWidth: 2,
                        color: const Color(0xFF3B82F6),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.store,
                          color: Colors.grey[400],
                          size: 24.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Nom du merchant
          SizedBox(
            width: 80.w,
            child: Text(
              merchant['name'],
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                fontFamily: 'SF Pro Text',
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
