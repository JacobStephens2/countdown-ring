import 'package:flutter/foundation.dart';

/// A countdown anchored to an absolute deadline rather than to a tick count.
///
/// The whole point: store an absolute [endsAt] timestamp and recompute the
/// remaining time from "now" on every frame. A timer built this way stays
/// correct across a backgrounded app, a screen-off device, or the process
/// being killed and relaunched mid-countdown, because nothing depends on a
/// `Timer` having fired the expected number of times. This is the model the
/// Quadrille rest timer is built on; pair it with an OS-level local
/// notification scheduled at [endsAt] for a reliable "time's up" signal.
///
/// The type is an immutable value: [adjusted] returns a new instance rather
/// than mutating. It is storage-agnostic, so persist [startedAt] / [endsAt]
/// however you like (a database row, shared preferences, a file) and rebuild
/// it on launch.
@immutable
class WallClockTimer {
  const WallClockTimer({required this.startedAt, required this.endsAt});

  /// Start a timer of [duration] anchored at [now] (defaults to the wall
  /// clock). The deadline is `now + duration`.
  factory WallClockTimer.start(Duration duration, {DateTime? now}) {
    final begin = now ?? DateTime.now();
    return WallClockTimer(startedAt: begin, endsAt: begin.add(duration));
  }

  /// When the countdown began.
  final DateTime startedAt;

  /// The absolute deadline. Remaining time is always derived from this.
  final DateTime endsAt;

  /// The full span from start to deadline.
  Duration get total => endsAt.difference(startedAt);

  /// Time left as of [now] (defaults to the wall clock). Goes negative once
  /// the deadline has passed, so callers can show an overrun; use
  /// [remainingClamped] to floor at zero.
  Duration remaining([DateTime? now]) =>
      endsAt.difference(now ?? DateTime.now());

  /// Time left as of [now], floored at [Duration.zero].
  Duration remainingClamped([DateTime? now]) {
    final r = remaining(now);
    return r.isNegative ? Duration.zero : r;
  }

  /// Fraction of the total span still remaining, in 0..1. Returns 0 once
  /// expired and 1 for a zero-length timer. Drive a ring or progress bar with
  /// this.
  double fraction([DateTime? now]) {
    final totalMs = total.inMilliseconds;
    if (totalMs <= 0) return isExpired(now) ? 0.0 : 1.0;
    final left = remaining(now).inMilliseconds;
    return (left / totalMs).clamp(0.0, 1.0);
  }

  /// Whether the deadline has passed as of [now].
  bool isExpired([DateTime? now]) =>
      !(now ?? DateTime.now()).isBefore(endsAt);

  /// Returns a copy with the deadline shifted by [delta] (positive to extend,
  /// negative to shorten). The new deadline is clamped so it never lands
  /// before [now], and [total] grows or shrinks to match.
  WallClockTimer adjusted(Duration delta, {DateTime? now}) {
    final clock = now ?? DateTime.now();
    var newEnd = endsAt.add(delta);
    if (newEnd.isBefore(clock)) newEnd = clock;
    return WallClockTimer(startedAt: startedAt, endsAt: newEnd);
  }

  @override
  bool operator ==(Object other) =>
      other is WallClockTimer &&
      other.startedAt == startedAt &&
      other.endsAt == endsAt;

  @override
  int get hashCode => Object.hash(startedAt, endsAt);

  @override
  String toString() => 'WallClockTimer(startedAt: $startedAt, endsAt: $endsAt)';
}
