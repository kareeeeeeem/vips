import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Safe, self-contained replacement for [Get.snackbar].
///
/// GetX's own snackbar system routes every call through `GetQueue`, which
/// processes jobs on an unawaited internal `async` function. When that job
/// finally runs — immediately for the first call, or after the previous
/// snackbar's duration for a queued one — it re-resolves the Overlay from
/// scratch, and during any route transition (splash -> onboarding, login ->
/// home, a Dio interceptor firing right as a screen changes) that lookup can
/// throw "No Overlay widget found". Because the throw happens inside that
/// unawaited async function, no try/catch around `Get.snackbar(...)` here —
/// and no amount of pre-checking `Get.overlayContext` beforehand — can ever
/// catch it; the check and the actual failure are not in the same
/// synchronous window. (Confirmed by reproduction: this used to crash even
/// with an overlay-readiness check immediately before the call, and again
/// after adding a 300ms settle delay — both looked "ready" and still failed.)
///
/// This instead inserts a plain [OverlayEntry] directly and synchronously,
/// so a real try/catch around the one operation that can fail
/// (`OverlayState.insert`) actually works, and removal is on a [Timer] we
/// own rather than GetX's queue.
OverlayEntry? _activeEntry;
Timer? _activeTimer;

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
    final overlayState = Get.key.currentState?.overlay;
    if (overlayState == null) {
      debugPrint('[safeSnackbar] No overlay available, dropping: $title — $message');
      return;
    }

    _activeTimer?.cancel();
    try {
      _activeEntry?.remove();
    } catch (_) {}
    _activeEntry = null;

    final atBottom = snackPosition == SnackPosition.BOTTOM;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: atBottom ? null : MediaQuery.of(context).padding.top + 12,
        bottom: atBottom ? MediaQuery.of(context).padding.bottom + 12 : null,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            bottom: false,
            child: GestureDetector(
              onTap: isDismissible
                  ? () {
                      _activeTimer?.cancel();
                      try {
                        entry.remove();
                      } catch (_) {}
                      if (identical(_activeEntry, entry)) _activeEntry = null;
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colorText ?? Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(color: colorText ?? Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    try {
      overlayState.insert(entry);
      _activeEntry = entry;
    } catch (e) {
      debugPrint('[safeSnackbar] insert failed: $e');
      return;
    }

    _activeTimer = Timer(duration ?? const Duration(seconds: 3), () {
      try {
        entry.remove();
      } catch (_) {}
      if (identical(_activeEntry, entry)) _activeEntry = null;
    });
  });
}
