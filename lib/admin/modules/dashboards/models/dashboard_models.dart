import 'package:flutter/material.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../services/admin_api_service.dart';

/// Shared shapes for the five analytical dashboards.

// ── The time window ─────────────────────────────────────────

/// A preset reporting window. `custom` carries its own [DateTimeRange].
///
/// These keys are sent as `?period=` and are the same set the backend's
/// `dashboardWindow` understands, so an option that appears on screen cannot
/// be one the server silently falls back out of.
enum DashboardPeriod { today, week, month, year, custom }

extension DashboardPeriodX on DashboardPeriod {
  String get key => switch (this) {
        DashboardPeriod.today => 'today',
        DashboardPeriod.week => 'week',
        DashboardPeriod.month => 'month',
        DashboardPeriod.year => 'year',
        DashboardPeriod.custom => 'custom',
      };

  String get label => switch (this) {
        DashboardPeriod.today => 'Today',
        DashboardPeriod.week => 'Last 7 days',
        DashboardPeriod.month => 'Last 30 days',
        DashboardPeriod.year => 'Last 12 months',
        DashboardPeriod.custom => 'Custom',
      };

  /// The short form used on the filter chips, where space is tight.
  String get chipLabel => switch (this) {
        DashboardPeriod.today => 'Today',
        DashboardPeriod.week => 'Week',
        DashboardPeriod.month => 'Month',
        DashboardPeriod.year => 'Year',
        DashboardPeriod.custom => 'Custom',
      };

  static DashboardPeriod fromKey(String key) => DashboardPeriod.values.firstWhere(
        (p) => p.key == key,
        orElse: () => DashboardPeriod.month,
      );
}

// ── Charts ──────────────────────────────────────────────────

enum DashboardChartType { line, bar, pie }

/// One point on a chart: a bucket label and its value.
///
/// [count] carries a secondary figure (orders behind a revenue bar) so a
/// tooltip can say "D 450 across 12 orders" without a second series.
class ChartPoint {
  final String label;
  final double value;
  final int count;

  const ChartPoint(this.label, this.value, {this.count = 0});

  /// Reads `{date|period|label|status|category|segment, value|count|amount}`
  /// off a backend row. The dashboards return several of these spellings
  /// because the underlying reports do; accepting them all here keeps the
  /// view code from re-deriving the mapping five times.
  factory ChartPoint.fromJson(
    Map<String, dynamic> json, {
    String labelKey = 'date',
    String valueKey = 'value',
    String countKey = 'orders',
  }) {
    final rawLabel = json[labelKey] ??
        json['date'] ??
        json['period'] ??
        json['label'] ??
        json['status'] ??
        json['category'] ??
        json['segment'];
    final rawValue = json[valueKey] ?? json['value'] ?? json['count'] ?? json['amount'];
    return ChartPoint(
      adminString(rawLabel, '—'),
      adminDouble(rawValue),
      count: adminInt(json[countKey] ?? json['count']),
    );
  }
}

/// The palette pie slices and multi-series charts cycle through.
///
/// Fixed order, so the same category keeps the same colour between reloads —
/// a legend that reshuffles on refresh is unreadable.
const List<Color> kDashboardPalette = [
  AdminColors.primary,
  AdminColors.accent,
  AdminColors.info,
  AdminColors.success,
  AdminColors.purple,
  AdminColors.warning,
  AdminColors.danger,
  Color(0xFF0EA5E9),
  Color(0xFF14B8A6),
  Color(0xFFA855F7),
];

Color dashboardSliceColor(int index) =>
    kDashboardPalette[index % kDashboardPalette.length];

// ── Tables ──────────────────────────────────────────────────

/// One column of a [DashboardTable].
class DashboardColumn {
  final String label;
  final String key;

  /// Right-aligned and rendered in the tabular figure style.
  final bool numeric;

  /// How to turn the raw JSON value into text. Defaults to a plain string,
  /// which is why money and percentage columns must pass one.
  final String Function(dynamic value)? format;

  /// Relative width. Text columns get more room than numbers.
  final int flex;

  const DashboardColumn(
    this.label,
    this.key, {
    this.numeric = false,
    this.format,
    this.flex = 1,
  });

  String render(dynamic value) =>
      format != null ? format!(value) : adminString(value, '—');
}
