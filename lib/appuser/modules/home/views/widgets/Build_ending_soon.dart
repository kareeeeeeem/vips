import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Section Ending Soon
class BuildEndingSoon extends StatelessWidget {
  const BuildEndingSoon({
    super.key,
    required this.deals,
    required this.onDealTap,
    required this.onViewAll,
    required this.onAddToBasket,
    required this.onToggleFavorite,
  });

  final List<Map<String, dynamic>> deals;
  final Function(Map<String, dynamic>) onDealTap;
  final VoidCallback onViewAll;
  final Function(Map<String, dynamic>) onAddToBasket;
  final Function(Map<String, dynamic>) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEC4899).withOpacity(0.15), // Rose fuchsia
            const Color(0xFFF43F5E).withOpacity(0.15), // Rose rouge
          ],
        ),
      ),
      child: Column(
        children: [
          // Header avec titre et bouton "voir plus"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Icône timer + titre
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.timer,
                        size: 20.sp,
                        color: const Color(0xFFEC4899),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ending_soon'.tr,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                        Text(
                          'less_than_24h'.tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFEC4899),
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Spacer(),

                // Bouton voir plus
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
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

          SizedBox(height: 16.h),

          // Liste horizontale des deals avec timer
          SizedBox(
            height: 260.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return Container(
                  width: 180.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: BuildOfferCardWithTimer(
                    deal: deal,
                    onTap: () => onDealTap(deal),
                    onAddToBasket: () => onAddToBasket(deal),
                    isFavorite: deal['isFavorite'] ?? false,
                    onToggleFavorite: () => onToggleFavorite(deal),
                    endTime: deal['endTime'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Carte d'offre avec Timer
class BuildOfferCardWithTimer extends StatefulWidget {
  const BuildOfferCardWithTimer({
    super.key,
    required this.deal,
    required this.onTap,
    required this.onAddToBasket,
    required this.onToggleFavorite,
    required this.endTime,
    this.isFavorite = false,
  });

  final Map<String, dynamic> deal;
  final VoidCallback onTap;
  final VoidCallback onAddToBasket;
  final VoidCallback onToggleFavorite;
  final DateTime endTime;
  final bool isFavorite;

  @override
  State<BuildOfferCardWithTimer> createState() =>
      _BuildOfferCardWithTimerState();
}

class _BuildOfferCardWithTimerState extends State<BuildOfferCardWithTimer> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    setState(() {
      _remainingTime = widget.endTime.difference(DateTime.now());
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFF3B30).withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3B30).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge de réduction
            Stack(
              children: [
                // Image principale
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14.r),
                    topRight: Radius.circular(14.r),
                  ),
                  child: Container(
                    height: 120.h,
                    width: double.infinity,
                    child: Image.network(
                      widget.deal['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 32.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Badge de réduction
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${widget.deal['discount']}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                  ),
                ),

                // Bouton Favori en haut à droite
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: widget.onToggleFavorite,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            widget.isFavorite
                                ? const Color(0xFFFF3B30)
                                : const Color(0xFF64748B),
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenu de la carte
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timer avec icône
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12.sp,
                                color: const Color(0xFFFF3B30),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _formatTime(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF3B30),
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Titre
                        Text(
                          widget.deal['title'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1E293B),
                            fontFamily: 'SF Pro Text',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4.h),

                        // Description
                        Text(
                          widget.deal['description'],
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                            fontFamily: 'SF Pro Text',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Spacer(),

                        // Prix
                        Row(
                          children: [
                            Text(
                              '${widget.deal['currentPrice']}',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'egp'.tr,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bouton Add to Basket
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: widget.onAddToBasket,
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF3B30), Color(0xFFFF6B35)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(14.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3B30).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 18.sp,
                        ),
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
