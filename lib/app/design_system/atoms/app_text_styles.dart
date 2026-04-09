import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'design_constants.dart';

extension ColorExt on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
}

class AppTextStyles {
  static TextStyle bodyXSRegular = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodySRegular = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyMRegular = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyXXSBold = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyXSBold = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodySBold = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyMBold = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyLRegular = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyXLRegular = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyXSLight = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyMLight = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w300,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodySBoldUnderline = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyMBoldUnderline = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle bodyXSBoldUnderline = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle titleS = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle titleM = TextStyle(
    fontSize: 21.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle titleL = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle titleXl = TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle titleXXXL = TextStyle(
    fontSize: 48.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle disableDatePickerTextStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
    fontFamily: DesignConstants.defaultAppFont,
  );
  static TextStyle helveticaNeueBold16 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    fontFamily: DesignConstants.helveticaNeueFont,
    height: 1.2,
  );
  static TextStyle helveticaNeueRegular14 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: DesignConstants.helveticaNeueFont,
    height: 1.2,
  );
  static TextStyle helveticaNeueSemiBold12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    fontFamily: DesignConstants.helveticaNeueFont,
    height: 1.2,
  );
}
