import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

// Real top-discount deals from HomeController.hotDeals (same source
// BuildBundle uses) — this used to show 4 hardcoded stock-photo cards
// (Fashion/Make Up/Perfume/Beauty) with fabricated discount claims and no
// connection to any real deal, one of which also leaked a third-party
// Flutter template vendor's name ("Active eCommerce") into the badge text.
class BuildPromotionalCarousel extends GetView<HomeController> {
  const BuildPromotionalCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return _PromoCarouselBody(controller: controller);
  }
}

class _PromoCarouselBody extends StatefulWidget {
  const _PromoCarouselBody({required this.controller});
  final HomeController controller;

  @override
  State<_PromoCarouselBody> createState() => _PromoCarouselBodyState();
}

class _PromoCarouselBodyState extends State<_PromoCarouselBody> {
  int _currentPage = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  static const _overlayColors = [
    Color(0xFFFF6B9D),
    Color(0xFF87CEEB),
    Color(0xFFFFB6C1),
    Color(0xFF6B9AC4),
  ];

  @override
  Widget build(BuildContext context) {
    final deals = widget.controller.getBestDiscountDeals();
    if (deals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.w),
      child: Stack(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: deals.length,
            options: CarouselOptions(
              height: 200.h,
              viewportFraction: 0.65,
              enlargeCenterPage: false,
              enlargeFactor: 0.25,
              autoPlay: deals.length > 1,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) => setState(() => _currentPage = index),
            ),
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onTap: () => widget.controller.navigateToHotDeal(deals[index]),
                child: _buildDealCard(deals[index], index),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: Get.width / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                deals.length,
                (index) => GestureDetector(
                  onTap: () => _carouselController.animateToPage(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Color(0xFF667eea) : Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal, int index) {
    final title = (deal['title'] ?? '').toString();
    final discount = (deal['discount'] as num?) ?? 0;
    final image = (deal['image'] ?? '').toString();
    final overlayColor = _overlayColors[index % _overlayColors.length].withValues(alpha: 0.55);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            image.isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                  )
                : Container(color: Colors.grey.shade300),
            Container(decoration: BoxDecoration(color: overlayColor)),
            Positioned(
              right: -50.w,
              top: -50.h,
              child: Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (discount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Text(
                        '${discount.toInt()}% OFF',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
