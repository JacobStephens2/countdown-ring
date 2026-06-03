import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'duration_format.dart';

/// A circular countdown that drains clockwise as a deadline approaches.
///
/// The ring draws a full track plus a progress arc whose sweep is [fraction]
/// (remaining / total, in 0..1). The center shows the remaining time as an
/// `MM:SS` clock label, switching to a check icon once [remaining] reaches
/// zero. Colors default to the ambient [ColorScheme] so the ring fits a
/// Material theme out of the box, and every visual is overridable.
///
/// This widget is purely presentational: feed it [remaining] and [fraction]
/// from whatever drives your countdown. [WallClockTimer] is a convenient
/// source - call `timer.remainingClamped()` and `timer.fraction()` on a tick.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.remaining,
    required this.fraction,
    this.size = 56,
    this.trackColor,
    this.progressColor,
    this.completedColor,
    this.labelStyle,
    this.completedIcon = Icons.check,
    this.strokeWidthFactor = 0.1,
  });

  /// Time left, shown in the center as `MM:SS`. At or below zero the ring is
  /// full and the [completedIcon] replaces the label.
  final Duration remaining;

  /// Remaining / total in 0..1. Values outside the range are clamped.
  final double fraction;

  /// Width and height of the (square) ring.
  final double size;

  /// Color of the full background track. Defaults to
  /// `ColorScheme.surfaceContainerHighest`.
  final Color? trackColor;

  /// Color of the draining progress arc. Defaults to `ColorScheme.primary`.
  final Color? progressColor;

  /// Color of the [completedIcon] when finished. Defaults to [progressColor]
  /// (then `ColorScheme.primary`).
  final Color? completedColor;

  /// Style of the center `MM:SS` label. Defaults to a bold, tabular-figures
  /// style sized relative to [size].
  final TextStyle? labelStyle;

  /// Icon shown in the center once [remaining] hits zero.
  final IconData completedIcon;

  /// Stroke width as a fraction of [size]. 0.1 gives a ring roughly a tenth as
  /// thick as it is wide.
  final double strokeWidthFactor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = remaining <= Duration.zero;
    final progress = progressColor ?? scheme.primary;
    final track = trackColor ?? scheme.surfaceContainerHighest;
    final defaultLabelStyle = TextStyle(
      fontSize: size * 0.26,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: scheme.onSurface,
    );
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: done ? 1 : fraction.clamp(0.0, 1.0),
          track: track,
          progress: progress,
          strokeWidthFactor: strokeWidthFactor,
        ),
        child: Center(
          child: done
              ? Icon(
                  completedIcon,
                  color: completedColor ?? progress,
                  size: size * 0.4,
                )
              : Text(
                  remaining.clockLabel,
                  style: labelStyle ?? defaultLabelStyle,
                ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.progress,
    required this.strokeWidthFactor,
  });

  final double fraction;
  final Color track;
  final Color progress;
  final double strokeWidthFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * strokeWidthFactor;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = progress;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction ||
      old.track != track ||
      old.progress != progress ||
      old.strokeWidthFactor != strokeWidthFactor;
}
