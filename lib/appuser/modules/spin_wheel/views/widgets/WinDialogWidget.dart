import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WinDialogWidget extends StatefulWidget {
  final int wonAmount;
  final VoidCallback onClaim;

  const WinDialogWidget({
    Key? key,
    required this.wonAmount,
    required this.onClaim,
  }) : super(key: key);

  @override
  State<WinDialogWidget> createState() => _WinDialogWidgetState();
}

class _WinDialogWidgetState extends State<WinDialogWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _pulseAnimation;

  // Positions des cercles flottants (augmentées à 8)
  final List<Offset> circlePositions = [
    Offset(0.25, 0.15), // Haut gauche
    Offset(0.15, 0.45), // Milieu gauche
    Offset(0.75, 0.55), // Milieu droite
    Offset(0.85, 0.15), // Haut droite
    Offset(0.5, 0.1), // Haut centre
    Offset(0.1, 0.65), // Bas gauche
    Offset(0.9, 0.7), // Bas droite
    Offset(0.5, 0.75), // Bas centre
  ];

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Interval(0.5, 1.0, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
    _rotateController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient background subtil
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFFF6B35).withOpacity(0.03),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Cercles flottants animés
          ..._buildFloatingCircles(),

          // Contenu principal
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),

                  // Grand cercle orange avec checkmark + effets
                  _buildMainCircle(),

                  SizedBox(height: 60.h),

                  // Texte "Congrats!" avec ombre
                  _buildCongratsText(),

                  SizedBox(height: 16.h),

                  // Badge du montant
                  _buildAmountBadge(),

                  SizedBox(height: 12.h),

                  // Message de félicitations
                  _buildMessage(),

                  Spacer(),

                  // Bouton Claim amélioré
                  _buildClaimButton(),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCircle() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8C42),
                    Color(0xFFFF6B35),
                    Color(0xFFFF5722),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B35).withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 10,
                    offset: Offset(0, 25),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Effet de brillance
                  Positioned(
                    top: 20.h,
                    right: 20.w,
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Checkmark avec rotation
                  Center(
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0, end: 0.1).animate(
                        CurvedAnimation(
                          parent: _rotateController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: ScaleTransition(
                        scale: _checkAnimation,
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 110.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCongratsText() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          // Ombre du texte
          Text(
            'Congrats!',
            style: TextStyle(
              fontSize: 56.sp,
              fontWeight: FontWeight.w900,
              foreground:
                  Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 8
                    ..color = Color(0xFFFF6B35).withOpacity(0.1),
              letterSpacing: -2,
            ),
          ),
          // Texte principal
          Text(
            'Congrats!',
            style: TextStyle(
              fontSize: 56.sp,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF6B35),
              letterSpacing: -2,
              shadows: [
                Shadow(
                  color: Color(0xFFFF6B35).withOpacity(0.3),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBadge() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B35).withOpacity(0.4),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.diamond, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              '${widget.wonAmount}',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'diamants',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.w),
        child: Text(
          'Congratulations! You have won an amazing prize',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey.shade600,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingCircles() {
    return List.generate(8, (index) {
      return AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final position = circlePositions[index];

          // Animation différente pour chaque cercle
          final offset = sin(_floatingController.value * 2 * pi + index) * 25;
          final rotation = _floatingController.value * 2 * pi + index;

          // Tailles et opacités variées
          final sizes = [35.w, 22.w, 28.w, 18.w, 30.w, 20.w, 25.w, 16.w];
          final opacities = [0.7, 0.4, 0.6, 0.3, 0.5, 0.35, 0.55, 0.25];

          return Positioned(
            left: position.dx * Get.width - sizes[index] / 2,
            top: position.dy * Get.height + offset,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: sizes[index],
                height: sizes[index],
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFF8C42).withOpacity(opacities[index]),
                      Color(0xFFFF6B35).withOpacity(opacities[index] * 0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildClaimButton() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B35).withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Bouton avec gradient

            // Effet de brillance animé
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(
                            0.2 * _pulseController.value,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            InkWell(
              onTap: () {
                print('*************');
                widget.onClaim();
              },
              child: Container(
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Claim Reward',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
