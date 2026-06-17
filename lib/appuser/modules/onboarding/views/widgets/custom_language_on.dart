import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../design_system/atoms/app_colors.dart';

class CustomLanguageOn extends StatefulWidget {
  const CustomLanguageOn({super.key});

  @override
  State<CustomLanguageOn> createState() => _CustomLanguageOnState();
}

class _CustomLanguageOnState extends State<CustomLanguageOn>
    with SingleTickerProviderStateMixin {
  int selectedLanguage = 0;
  late AnimationController _animationController;

  final List<LanguageOption> languages = [
    const LanguageOption(
      icon: AppIcons.US,
      name: 'English',
      nativeName: 'English',
      code: 'en',
    ),
    const LanguageOption(
      icon: AppIcons.AR,
      name: 'Arabic',
      nativeName: 'العربية',
      code: 'ar',
    ),
    const LanguageOption(
      icon: AppIcons.france,
      name: 'French',
      nativeName: 'Français',
      code: 'fr',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          languages.asMap().entries.map((entry) {
            return _buildLanguageItem(entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildLanguageItem(int index, LanguageOption language) {
    final isSelected = selectedLanguage == index;
    final isLast = index == languages.length - 1;

    return Container(
      height: 58,
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _selectLanguage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutQuart,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.AppPrimaryColor.withOpacity(0.06)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color:
                    isSelected
                        ? AppColors.AppPrimaryColor.withOpacity(0.2)
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Modern Radio Indicator
                _buildModernRadio(isSelected),

                SizedBox(width: 12.w),

                // Flag Container
                Container(
                  width: 28.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: SvgPicture.asset(language.icon, fit: BoxFit.cover),
                  ),
                ),

                SizedBox(width: 12.w),

                // Language Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: 'SF Pro Display',
                          color:
                              isSelected
                                  ? AppColors.AppPrimaryColor
                                  : const Color(0xFF1E293B),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection Indicator
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(
                      color: AppColors.AppPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernRadio(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isSelected ? AppColors.AppPrimaryColor : const Color(0xFFCBD5E1),
          width: isSelected ? 5.w : 2.w,
        ),
        color: Colors.white,
      ),
    );
  }

  void _selectLanguage(int index) {
    if (selectedLanguage != index) {
      setState(() {
        selectedLanguage = index;
      });

      // Light haptic feedback
      // HapticFeedback.lightImpact();

      // Callback pour notifier le parent
      // widget.onLanguageSelected?.call(languages[index]);
    }
  }
}

// Model optimisé
class LanguageOption {
  final String icon;
  final String name;
  final String nativeName;
  final String code;

  const LanguageOption({
    required this.icon,
    required this.name,
    required this.nativeName,
    required this.code,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
