import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/routes/app_pages.dart';
import 'package:vip/core/services/api_service.dart';

// Real active promotions from GET /content/promotions (same endpoint
// PromotionsController already uses) — this used to show 3 hardcoded stock
// photos with fabricated "Winter Collection / 50% off" style claims that
// had nothing to do with any real promotion the backend actually has.
class BuildHeroBanner extends StatefulWidget {
  const BuildHeroBanner({super.key});

  @override
  State<BuildHeroBanner> createState() => _BuildHeroBannerState();
}

class _BuildHeroBannerState extends State<BuildHeroBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _loading = true;
  List<Map<String, dynamic>> _promotions = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.1);
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    try {
      final response = await ApiService().get('/content/promotions');
      if (response.success && response.data is List) {
        final raw = (response.data as List).whereType<Map>();
        if (mounted) {
          setState(() {
            _promotions = raw.map((p) => Map<String, dynamic>.from(p)).take(5).toList();
            _loading = false;
          });
        }
        if (_promotions.length > 1) _startAutoScroll();
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!mounted || _promotions.isEmpty) return;
      _currentPage = (_currentPage + 1) % _promotions.length;
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
    // No fabricated placeholder when there's nothing real to show — an
    // empty section is honest, a fake one isn't.
    if (_loading || _promotions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: _promotions.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                double angle = value * 0.3;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
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
            child: _buildBannerCard(_promotions[index]),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> promo) {
    final title = (promo['title'] ?? '').toString();
    final subtitle = (promo['subtitle'] ?? '').toString();
    final discount = (promo['discount'] as num?) ?? 0;
    final imageUrl = (promo['imageUrl'] ?? '').toString();
    final badge = discount > 0 ? '${discount.toInt()}% OFF' : 'PROMO';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1a1a1a)),
                        )
                      : Container(color: const Color(0xFF1a1a1a)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24.w,
            top: 0,
            bottom: 0,
            right: 24.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.PROMOTIONS),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Offer',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1a1a1a),
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.arrow_forward, size: 14.sp, color: Color(0xFF1a1a1a)),
                      ],
                    ),
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
