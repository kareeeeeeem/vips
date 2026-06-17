import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BuildPromotionalCarousel extends StatefulWidget {
  const BuildPromotionalCarousel({Key? key}) : super(key: key);

  @override
  State<BuildPromotionalCarousel> createState() =>
      _BuildPromotionalCarouselState();
}

class _BuildPromotionalCarouselState extends State<BuildPromotionalCarousel> {
  int _currentPage = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<PromoCard> promos = [
    PromoCard(
      title: 'FASHION',
      subtitle: 'Exclusive Collection',
      badge: 'BUY NOW',
      image:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&q=80',
      overlayColor: Color(0xFFFF6B9D).withOpacity(0.65),
    ),
    PromoCard(
      title: 'MAKE UP',
      subtitle: '5% TOTAL',
      badge: 'by Active eCommerce',
      image:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=600&q=80',
      overlayColor: Colors.white.withOpacity(0.75),
      titleColor: Color(0xFF87CEEB),
      subtitleColor: Color(0xFFFF6B9D),
      badgeColor: Color(0xFF666666),
    ),
    PromoCard(
      title: 'PERFUME',
      subtitle: 'Picked collection',
      badge: 'Active eCommerce',
      image:
          'https://images.unsplash.com/photo-1541643600914-78b084683601?w=600&q=80',
      overlayColor: Color(0xFF87CEEB).withOpacity(0.65),
      titleColor: Color(0xFFFF6B9D),
    ),
    PromoCard(
      title: 'BEAUTY',
      subtitle: 'Up to 30% off',
      badge: 'SHOP NOW',
      image:
          'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&q=80',
      overlayColor: Color(0xFFFFB6C1).withOpacity(0.65),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.w),
      padding: EdgeInsets.only(left: 0.w),
      child: Stack(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: promos.length,
            options: CarouselOptions(
              height: 200.h,
              viewportFraction: 0.65,
              enlargeCenterPage: false,
              enlargeFactor: 0.25,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return _buildPromoCard(promos[index]);
            },
          ),

          // Indicateurs de page
          Positioned(
            bottom: 20,
            left: Get.width / 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                promos.length,
                (index) => GestureDetector(
                  onTap: () => _carouselController.animateToPage(index),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? Color(0xFF667eea)
                              : Color(0xFFE0E0E0),
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

  Widget _buildPromoCard(PromoCard promo) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de fond
            Image.network(promo.image, fit: BoxFit.cover),

            // Overlay coloré
            Container(decoration: BoxDecoration(color: promo.overlayColor)),

            // Pattern décoratif
            Positioned(
              right: -50.w,
              top: -50.h,
              child: Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Contenu texte
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    promo.title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 33.sp,
                      fontWeight: FontWeight.w800,
                      color: promo.titleColor ?? Colors.white,
                      height: 1.0,
                      letterSpacing: 2.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    promo.subtitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          promo.subtitleColor ?? Colors.white.withOpacity(0.95),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Spacer(),
                  if (promo.badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        promo.badge!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: promo.badgeColor ?? Colors.white,
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

class PromoCard {
  final String title;
  final String subtitle;
  final String? badge;
  final String image;
  final Color overlayColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? badgeColor;

  PromoCard({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.image,
    required this.overlayColor,
    this.titleColor,
    this.subtitleColor,
    this.badgeColor,
  });
}
