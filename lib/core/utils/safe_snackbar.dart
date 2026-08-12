import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Safe wrapper around [Get.snackbar] that defers to the next frame so it
/// never throws "No Overlay widget found" when called from Dio interceptors,
/// onInit(), or async callbacks that fire before the route is fully built.
void safeSnackbar(
  String title,
  String message, {
  SnackPosition? snackPosition,
  Color? backgroundColor,
  Color? colorText,
  Duration? duration,
  bool isDismissible = true,
  Widget? icon,
  double? maxWidth,
  EdgeInsets? margin,
  EdgeInsets? padding,
  double? borderRadius,
  Color? borderColor,
  double? barBlur,
  double overlayBlur = 0.0,
  Color? overlayColor,
  bool? showProgressIndicator,
  SnackStyle? snackStyle,
  Widget? titleText,
  Widget? messageText,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Get.context != null && Get.overlayContext != null) {
      try {
        Get.snackbar(
          title,
          message,
          snackPosition: snackPosition,
          backgroundColor: backgroundColor,
          colorText: colorText,
          duration: duration,
          isDismissible: isDismissible,
          icon: icon,
          maxWidth: maxWidth,
          margin: margin,
          padding: padding,
          borderRadius: borderRadius,
          borderColor: borderColor,
          barBlur: barBlur,
          overlayBlur: overlayBlur,
          overlayColor: overlayColor,
          showProgressIndicator: showProgressIndicator,
          snackStyle: snackStyle,
          titleText: titleText,
          messageText: messageText,
        );
      } catch (e) {
        debugPrint('[safeSnackbar] Error: $e');
      }
    }
  });
}
