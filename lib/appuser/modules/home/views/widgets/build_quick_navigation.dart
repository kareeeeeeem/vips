import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildQuickNavigation extends StatefulWidget {
  const BuildQuickNavigation({Key? key}) : super(key: key);

  @override
  State<BuildQuickNavigation> createState() => _BuildQuickNavigationState();
}

class _BuildQuickNavigationState extends State<BuildQuickNavigation> {
  int selectedIndex = 1;

  final List<NavItem> items = [
    NavItem('Todays Deal', Icons.calendar_today_outlined),
    NavItem('Flash Deal', Icons.flash_on),
    NavItem('Brands', Icons.lightbulb_outline),
    NavItem('Top', Icons.military_tech_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isToday = index == 0;
          final isFlash = index == 1;

          return SizedBox(
            child: GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 0.h),
                decoration: BoxDecoration(
                  color:
                      isToday
                          ? Color(0xFF1a1a1a)
                          : isFlash
                          ? Color(0xFFFF6B35)
                          : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(5.r),
                  boxShadow:
                      (isToday || isFlash)
                          ? [
                            BoxShadow(
                              color: (isToday
                                      ? Colors.black
                                      : Color(0xFFFF6B35))
                                  .withOpacity(0.25),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ]
                          : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].icon,
                      color:
                          (isToday || isFlash)
                              ? Colors.white
                              : Color(0xFF666666),
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      items[index].label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            (isToday || isFlash)
                                ? Colors.white
                                : Color(0xFF666666),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData icon;
  NavItem(this.label, this.icon);
}
