import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildHeroBanner extends StatefulWidget {
  const BuildHeroBanner({Key? key}) : super(key: key);

  @override
  State<BuildHeroBanner> createState() => _BuildHeroBannerState();
}

class _BuildHeroBannerState extends State<BuildHeroBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<HeroBannerItem> banners = [
    HeroBannerItem(
      badge: 'NEW ARRIVAL',
      title: 'Winter\nCollection',
      subtitle: 'Up to 50% off',
      buttonText: 'Explore',
      image:
          'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800&q=80',
    ),
    HeroBannerItem(
      badge: 'HOT DEAL',
      title: 'Summer\nSale',
      subtitle: 'Up to 70% off',
      buttonText: 'Shop Now',
      image:
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&q=80',
    ),
    HeroBannerItem(
      badge: 'TRENDING',
      title: 'Spring\nFashion',
      subtitle: 'New Arrivals',
      buttonText: 'Discover',
      image:
          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.1);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_currentPage < banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180.h,
          margin: EdgeInsets.symmetric(vertical: 8.h),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    // Effet 3D avec rotation
                    double angle = value * 0.3;
                    return Transform(
                      transform:
                          Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateY(angle),
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: (1 - (value.abs() * 0.3)).clamp(0.7, 1.0),
                        child: Opacity(
                          opacity: (1 - (value.abs() * 0.5)).clamp(0.5, 1.0),
                          child: child,
                        ),
                      ),
                    );
                  }
                  return child!;
                },
                child: _buildBannerCard(banners[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(HeroBannerItem banner) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(banner.image, fit: BoxFit.cover),
                  // Overlay gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          Positioned(
            left: 24.w,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    banner.badge,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Titre
                Text(
                  banner.title,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                // Sous-titre
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 16.h),
                // Bouton
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        banner.buttonText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1a1a1a),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.arrow_forward,
                        size: 14.sp,
                        color: Color(0xFF1a1a1a),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroBannerItem {
  final String badge;
  final String title;
  final String subtitle;
  final String buttonText;
  final String image;

  HeroBannerItem({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.image,
  });
}
