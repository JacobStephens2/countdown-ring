import 'package:countdown_ring/countdown_ring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime.utc(2026, 1, 1, 12, 0, 0);

  WallClockTimer twoMinutes() =>
      WallClockTimer.start(const Duration(minutes: 2), now: start);

  test('start sets a deadline of now + duration', () {
    final t = twoMinutes();
    expect(t.startedAt, start);
    expect(t.endsAt, start.add(const Duration(minutes: 2)));
    expect(t.total, const Duration(minutes: 2));
  });

  test('remaining is derived from the deadline and goes negative', () {
    final t = twoMinutes();
    expect(t.remaining(start.add(const Duration(seconds: 30))),
        const Duration(seconds: 90));
    expect(t.remaining(start.add(const Duration(minutes: 3))),
        const Duration(minutes: -1));
  });

  test('remainingClamped floors at zero', () {
    final t = twoMinutes();
    expect(t.remainingClamped(start.add(const Duration(minutes: 3))),
        Duration.zero);
  });

  test('fraction runs 1 -> 0 across the span', () {
    final t = twoMinutes();
    expect(t.fraction(start), 1.0);
    expect(t.fraction(start.add(const Duration(minutes: 1))), closeTo(0.5, 1e-9));
    expect(t.fraction(start.add(const Duration(minutes: 2))), 0.0);
    expect(t.fraction(start.add(const Duration(minutes: 5))), 0.0);
  });

  test('isExpired flips at the deadline', () {
    final t = twoMinutes();
    expect(t.isExpired(start.add(const Duration(seconds: 119))), isFalse);
    expect(t.isExpired(start.add(const Duration(minutes: 2))), isTrue);
  });

  test('adjusted extends and shortens the deadline', () {
    final t = twoMinutes();
    final extended = t.adjusted(const Duration(seconds: 30), now: start);
    expect(extended.endsAt, start.add(const Duration(seconds: 150)));
    final shortened = t.adjusted(const Duration(seconds: -30), now: start);
    expect(shortened.endsAt, start.add(const Duration(seconds: 90)));
  });

  test('adjusted never lands the deadline before now', () {
    final t = twoMinutes();
    final now = start.add(const Duration(seconds: 119));
    final shortened = t.adjusted(const Duration(minutes: -5), now: now);
    expect(shortened.endsAt, now);
  });

  test('value equality', () {
    expect(twoMinutes(), twoMinutes());
    expect(twoMinutes().hashCode, twoMinutes().hashCode);
  });
}
