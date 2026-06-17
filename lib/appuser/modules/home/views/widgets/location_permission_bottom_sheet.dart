import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationPermissionBottomSheet extends StatelessWidget {
  final VoidCallback? onAllowActivation;
  final VoidCallback? onNoThanks;

  const LocationPermissionBottomSheet({
    Key? key,
    this.onAllowActivation,
    this.onNoThanks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 50.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 40.h),

          // Location icon
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                color: const Color(0xFFFF6B35),
                size: 50.sp,
              ),
            ),
          ),

          SizedBox(height: 30.h),

          // Title
          Text(
            'Enable locations',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'You must enable the positioning feature to be able to view the offers and services surrounding you more easily',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 40.h),

          // Allow activation button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAllowActivation?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Allow activation',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // No Thanks button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onNoThanks?.call();
            },
            child: Text(
              'No Thanks',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF6B35),
              ),
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // Méthode statique pour afficher facilement la bottom sheet
  static void show(
    BuildContext context, {
    VoidCallback? onAllowActivation,
    VoidCallback? onNoThanks,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LocationPermissionBottomSheet(
        onAllowActivation: onAllowActivation,
        onNoThanks: onNoThanks,
      ),
    );
  }
}