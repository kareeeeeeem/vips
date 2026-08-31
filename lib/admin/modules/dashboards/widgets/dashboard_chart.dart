import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';
import '../models/dashboard_models.dart';

/// Line, bar and pie charts for the analytical dashboards.
///
/// Painted with `CustomPaint` rather than pulled from a chart package: this
/// pubspec is shared by the customer and merchant apps, and adding a
/// dependency for three chart shapes would put it into two shipping builds
/// that never draw a chart. The console's existing `AdminMiniBarChart` was
/// written on the same reasoning.
class DashboardChart extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<ChartPoint> data;
  final DashboardChartType type;
  final Color color;
  final String Function(double) formatValue;
  final double? height;
  final Widget? trailing;

  /// Shown in place of the plot when there is nothing to draw.
  final String emptyMessage;

  const DashboardChart({
    super.key,
    required this.title,
    required this.data,
    required this.type,
    required this.formatValue,
    this.subtitle,
    this.color = AdminColors.primary,
    this.height,
    this.trailing,
    this.emptyMessage = 'No data in this period',
  });

  @override
  State<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  /// The point under the pointer, or null when nothing is being inspected.
  int? _active;

  @override
  void didUpdateWidget(DashboardChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A refresh can return a shorter series while a point is selected; without
    // this the readout would index past the end of the new list.
    if (_active != null && _active! >= widget.data.length) _active = null;
  }

  @override
  Widget build(BuildContext context) {
    final plotHeight = widget.height ?? 190.h;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          if (widget.data.isEmpty)
            SizedBox(
              height: plotHeight,
              child: Center(
                child: Text(
                  widget.emptyMessage,
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
                ),
              ),
            )
          else if (widget.type == DashboardChartType.pie)
            _buildPie(plotHeight)
          else
            _buildPlot(plotHeight),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final active = _active != null && _active! < widget.data.length
        ? widget.data[_active!]
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              // The readout doubles as the tooltip: hovering or dragging over
              // the plot names the exact bucket, which a painted tooltip
              // cannot do legibly at phone width.
              Text(
                active != null
                    ? '${active.label} · ${widget.formatValue(active.value)}'
                        '${active.count > 0 ? ' · ${active.count} orders' : ''}'
                    : (widget.subtitle ?? _defaultSubtitle()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: active != null ? FontWeight.w600 : FontWeight.w400,
                  color: active != null ? widget.color : AdminColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }

  String _defaultSubtitle() {
    if (widget.data.isEmpty) return '';
    final total = widget.data.fold<double>(0, (sum, p) => sum + p.value);
    final peak = widget.data.map((p) => p.value).reduce(math.max);
    return widget.type == DashboardChartType.pie
        ? 'Total ${widget.formatValue(total)}'
        : 'Total ${widget.formatValue(total)} · peak ${widget.formatValue(peak)}';
  }

  // ── Line and bar ──────────────────────────────────────────

  Widget _buildPlot(double height) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        void track(Offset local) {
          if (widget.data.length < 2) {
            setState(() => _active = widget.data.isEmpty ? null : 0);
            return;
          }
          final step = width / widget.data.length;
          final index = (local.dx / step).floor().clamp(0, widget.data.length - 1);
          if (index != _active) setState(() => _active = index);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              onHover: (event) => track(event.localPosition),
              onExit: (_) => setState(() => _active = null),
              child: GestureDetector(
                // Tap and drag, so the same readout works on a touch screen
                // where there is no hover to report.
                onTapDown: (d) => track(d.localPosition),
                onHorizontalDragUpdate: (d) => track(d.localPosition),
                onHorizontalDragEnd: (_) => setState(() => _active = null),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    painter: widget.type == DashboardChartType.line
                        ? _LinePainter(widget.data, widget.color, _active)
                        : _BarPainter(widget.data, widget.color, _active),
                  ),
                ),
              ),
            ),
            SizedBox(height: 7.h),
            _buildAxisLabels(),
          ],
        );
      },
    );
  }

  Widget _buildAxisLabels() {
    final first = widget.data.first.label;
    final last = widget.data.last.label;
    final middle = widget.data.length > 2
        ? widget.data[widget.data.length ~/ 2].label
        : null;

    Widget label(String text, TextAlign align) => Expanded(
          child: Text(
            text,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5.sp, color: AdminColors.textMuted),
          ),
        );

    return Row(
      children: [
        label(first, TextAlign.start),
        if (middle != null) label(middle, TextAlign.center),
        label(last, TextAlign.end),
      ],
    );
  }

  // ── Pie ───────────────────────────────────────────────────

  Widget _buildPie(double height) {
    final total = widget.data.fold<double>(0, (sum, p) => sum + p.value);
    if (total <= 0) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Every slice is zero in this period',
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
          ),
        ),
      );
    }

    // Only slices with a value are drawn or listed: a zero-width wedge is
    // invisible in the ring but would still take a row in the legend and read
    // as a category that is somehow present.
    final slices = <MapEntry<int, ChartPoint>>[
      for (var i = 0; i < widget.data.length; i++)
        if (widget.data[i].value > 0) MapEntry(i, widget.data[i]),
    ];

    final ring = math.min(height, 160.h);

    return LayoutBuilder(
      builder: (context, constraints) {
        final legend = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in slices.take(8))
              Padding(
                padding: EdgeInsets.only(bottom: 7.h),
                child: Row(
                  children: [
                    Container(
                      width: 9.w,
                      height: 9.w,
                      decoration: BoxDecoration(
                        color: dashboardSliceColor(entry.key),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(
                        entry.value.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${(entry.value.value / total * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            if (slices.length > 8)
              Text(
                '+${slices.length - 8} more',
                style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted),
              ),
          ],
        );

        final chart = SizedBox(
          width: ring,
          height: ring,
          child: CustomPaint(
            painter: _PiePainter(
              slices.map((e) => e.value.value).toList(),
              slices.map((e) => dashboardSliceColor(e.key)).toList(),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.formatValue(total),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        );

        // Side by side when there is room, stacked when there is not — the
        // legend is the half that becomes unreadable first in a narrow row.
        if (constraints.maxWidth < 380) {
          return Column(
            children: [chart, SizedBox(height: 14.h), legend],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            chart,
            SizedBox(width: 16.w),
            Expanded(child: legend),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAINTERS
// ═══════════════════════════════════════════════════════════

/// Shared scaling. An all-zero series would divide by zero and paint NaN
/// geometry, which throws inside the render pass rather than drawing nothing.
double _safeMax(List<ChartPoint> data) {
  final max = data.map((p) => p.value).fold<double>(0, math.max);
  return max <= 0 ? 1 : max;
}

void _paintGrid(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = AdminColors.divider
    ..strokeWidth = 1;
  for (var i = 0; i <= 4; i++) {
    final y = size.height * (i / 4);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
}

class _LinePainter extends CustomPainter {
  final List<ChartPoint> data;
  final Color color;
  final int? active;

  _LinePainter(this.data, this.color, this.active);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;
    _paintGrid(canvas, size);

    final max = _safeMax(data);
    final step = data.length == 1 ? 0.0 : size.width / (data.length - 1);

    Offset pointAt(int i) => Offset(
          data.length == 1 ? size.width / 2 : i * step,
          size.height - (data[i].value / max) * (size.height - 6) - 3,
        );

    final points = [for (var i = 0; i < data.length; i++) pointAt(i)];

    final fill = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fill.lineTo(p.dx, p.dy);
    }
    fill.lineTo(points.last.dx, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.02)],
        ).createShader(Offset.zero & size),
    );

    final stroke = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      stroke.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      stroke,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Dots only on a short series: at 30 points they merge into the line and
    // at 365 they are a solid band.
    if (data.length <= 14) {
      for (final p in points) {
        canvas.drawCircle(p, 3, Paint()..color = AdminColors.surface);
        canvas.drawCircle(
          p,
          3,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    if (active != null && active! < points.length) {
      final p = points[active!];
      canvas.drawLine(
        Offset(p.dx, 0),
        Offset(p.dx, size.height),
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(p, 5, Paint()..color = AdminColors.surface);
      canvas.drawCircle(p, 4.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.data != data || old.active != active || old.color != color;
}

class _BarPainter extends CustomPainter {
  final List<ChartPoint> data;
  final Color color;
  final int? active;

  _BarPainter(this.data, this.color, this.active);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;
    _paintGrid(canvas, size);

    final max = _safeMax(data);
    final slot = size.width / data.length;
    // Bars thin out as the series grows; below a pixel the gap eats them
    // entirely and the chart paints blank.
    final barWidth = math.max(slot * 0.62, 1.5);
    final radius = Radius.circular(math.min(3, barWidth / 2));

    for (var i = 0; i < data.length; i++) {
      final ratio = data[i].value / max;
      final height = math.max(ratio * (size.height - 4), data[i].value > 0 ? 2.0 : 0.0);
      final left = i * slot + (slot - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        topLeft: radius,
        topRight: radius,
      );
      final isActive = active == i;
      canvas.drawRRect(
        rect,
        Paint()
          ..color = data[i].value == 0
              ? AdminColors.divider
              : color.withValues(alpha: isActive ? 1 : 0.4 + ratio * 0.5),
      );
    }

    if (active != null && active! < data.length) {
      final left = active! * slot;
      canvas.drawRect(
        Rect.fromLTWH(left, 0, slot, size.height),
        Paint()..color = color.withValues(alpha: 0.06),
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.data != data || old.active != active || old.color != color;
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PiePainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total <= 0 || size.width <= 0) return;

    final radius = math.min(size.width, size.height) / 2;
    final centre = Offset(size.width / 2, size.height / 2);
    // A donut rather than a full pie: the hole carries the total, which is
    // the number an operator actually reads off a share chart.
    final thickness = radius * 0.34;
    final rect = Rect.fromCircle(center: centre, radius: radius - thickness / 2);

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        // A hairline gap between slices, never wider than the slice itself,
        // so a 0.2% wedge is not drawn as negative sweep.
        math.max(sweep - math.min(0.012, sweep / 2), 0.001),
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) =>
      old.values != values || old.colors != colors;
}
