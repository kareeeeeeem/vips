import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

import 'theme/admin_theme.dart';

/// One place for every console notification.
///
/// Always shows a written message, never a raw exception: the caught error
/// belongs in `debugPrint`, and the operator gets something they can act on.
void adminToast(String title, String message, {required bool isError}) {
  safeSnackbar(
    title,
    message.isEmpty ? (isError ? 'Something went wrong.' : 'Done.') : message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? AdminColors.danger : AdminColors.success,
    colorText: Colors.white,
    duration: Duration(seconds: isError ? 4 : 2),
  );
}
