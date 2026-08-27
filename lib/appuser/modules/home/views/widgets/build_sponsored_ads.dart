import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

/// Live merchant ad campaigns (GET /content/ads). Merchants could create and
/// pay to boost campaigns, but no screen anywhere ever showed one to a
/// customer, so every campaign's impressions and clicks stayed at zero and
/// the boost money bought nothing. Each card records a real impression once
/// per session and a real click on tap.
class BuildSponsoredAds extends GetView<HomeController> {
  const BuildSponsoredAds({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ads = controller.sponsoredAds;
      if (ads.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    'Sponsored',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.campaign_outlined,
                      size: 16.sp, color: const Color(0xFF9CA3AF)),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 140.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: ads.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  controller.trackAdImpression((ad['_id'] ?? '').toString());
                  return _adCard(ad);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _adCard(Map<String, dynamic> ad) {
    final image = (ad['imageUrl'] ?? '').toString();
    final title = (ad['title'] ?? '').toString();
    final store = (ad['storeName'] ?? '').toString();
    final description = (ad['description'] ?? '').toString();

    return GestureDetector(
      onTap: () => controller.openSponsoredAd(ad),
      child: Container(
        width: 240.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 90.w,
              height: double.infinity,
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallback(),
                    )
                  : _fallback(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (store.isNotEmpty)
                      Text(
                        store,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    SizedBox(height: 2.h),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.campaign_outlined, color: Color(0xFF9CA3AF)),
      );
}
