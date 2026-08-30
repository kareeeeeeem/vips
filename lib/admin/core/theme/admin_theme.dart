import 'package:flutter/material.dart';

/// Design tokens for the admin console.
///
/// The consumer app is orange (`AppColors.AppPrimaryColor`) and the merchant
/// app is green — the console gets its own navy so an operator can tell at a
/// glance which of the three apps is on screen. Everything else (radii,
/// spacing, the neutral greys) is kept identical to the merchant app's
/// palette so shared screen patterns look like they belong together.
class AdminColors {
  AdminColors._();

  static const Color primary     = Color(0xFF00205C); // VIPs navy
  static const Color primaryDark = Color(0xFF00143B);
  static const Color accent      = Color(0xFFFA6B25); // VIPs orange

  static const Color background  = Color(0xFFF9FAFB);
  static const Color surface     = Colors.white;
  static const Color border      = Color(0xFFE5E7EB);
  static const Color divider     = Color(0xFFF3F4F6);

  static const Color textPrimary   = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted     = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger  = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);
  static const Color purple  = Color(0xFF8B5CF6);

  /// Colour for an order status. Covers the whole `Order.status` enum from
  /// `models/Order.js` — both 'canceled' and 'cancelled' spellings included,
  /// since real data contains both.
  static Color orderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'confirmed':
      case 'processing':
      case 'ready':
        return info;
      case 'handover':
      case 'picked_up':
        return purple;
      case 'delivered':
        return success;
      case 'canceled':
      case 'cancelled':
        return danger;
      case 'refund_requested':
        return const Color(0xFFEA580C);
      case 'refunded':
        return textSecondary;
      default:
        return textMuted;
    }
  }

  /// Colour for a `BusinessRegistration.status`, plus the synthetic 'none'
  /// the merchants list uses for a merchant that never registered.
  static Color approvalStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return success;
      case 'pending':
      case 'under_review':
        return warning;
      case 'rejected':
        return danger;
      default:
        return textMuted;
    }
  }
}

/// Turns an enum-ish backend value ('refund_requested') into a label
/// ('Refund Requested'). Used everywhere a raw status reaches the screen.
String adminLabel(String raw) {
  if (raw.isEmpty) return '—';
  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class AdminTheme {
  AdminTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AdminColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminColors.primary,
          primary: AdminColors.primary,
        ).copyWith(surface: AdminColors.surface),
        appBarTheme: const AppBarTheme(
          backgroundColor: AdminColors.surface,
          foregroundColor: AdminColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        dividerColor: AdminColors.divider,
      );
}
