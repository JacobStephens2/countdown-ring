# countdown_ring

A circular countdown ring for Flutter, plus the two small pieces that make a countdown actually reliable: a wall-clock timer model that survives backgrounding and process death, and compact duration formatting/parsing. Extracted and generalized from the rest timer of [Quadrille](https://quadrille.app).

The interesting part is not the ring - it is the timing model behind it. Most countdowns tick a `Timer` and decrement a counter, which drifts the moment the app is backgrounded, the screen sleeps, or the OS kills the process mid-count. `WallClockTimer` instead stores an absolute `endsAt` timestamp and recomputes the remaining time from "now" on every frame, so the display is correct no matter what happened between ticks. A missed tick costs you a dropped frame, never a wrong number.

## Install

Not yet on pub.dev. Add it from GitHub:

```yaml
dependencies:
  countdown_ring:
    git:
      url: https://github.com/JacobStephens2/countdown_ring.git
```

## The ring

`CountdownRing` is purely presentational - feed it `remaining` and `fraction` and it draws a track plus a draining arc, with an `MM:SS` label that flips to a check icon at zero. Colors default to the ambient `ColorScheme`, so it fits a Material theme with no configuration, and every visual is overridable (`trackColor`, `progressColor`, `labelStyle`, `completedIcon`, `size`, `strokeWidthFactor`).

```dart
CountdownRing(
  remaining: const Duration(seconds: 84), // shows 01:24
  fraction: 0.7,                           // arc is 70% of the way around
  size: 120,
)
```

## The timer model

`WallClockTimer` is an immutable value anchored to a deadline. It is storage-agnostic: persist `startedAt` / `endsAt` however you like (a database row, shared preferences, a file) and rebuild it on launch.

```dart
final timer = WallClockTimer.start(const Duration(minutes: 2));

timer.remaining();          // Duration left, goes negative on overrun
timer.remainingClamped();   // same, floored at zero
timer.fraction();           // 1.0 -> 0.0 across the span, for the ring
timer.isExpired();          // deadline passed?
timer.adjusted(const Duration(seconds: 30)); // a new timer, +30s, clamped to >= now
```

Drive the ring by ticking a few times a second purely to repaint - the value shown always comes from the deadline, so the tick rate only affects smoothness, not correctness:

```dart
Timer.periodic(const Duration(milliseconds: 200), (_) {
  setState(() {}); // CountdownRing reads timer.remainingClamped() / timer.fraction()
});
```

For a truly reliable "time's up" signal across a killed process, schedule an OS-level local notification at `timer.endsAt` (for example with `flutter_local_notifications`) rather than relying on a foreground `Timer` to fire.

See [`example/`](example/) for a complete runnable app with start, +/- 15s, and skip controls.

## Duration helpers

```dart
const Duration(seconds: 90).compactLabel;  // "90s"
const Duration(minutes: 2).compactLabel;   // "2'"
const Duration(seconds: 150).compactLabel; // "2.5'"
const Duration(seconds: 84).clockLabel;    // "01:24"

parseDuration('90s');  // Duration(seconds: 90)
parseDuration("2.5'"); // Duration(seconds: 150)
parseDuration('1:30'); // Duration(seconds: 90)
parseDuration('1m30s');// Duration(seconds: 90)
parseDuration('soon'); // null
```

## Development

```sh
flutter pub get
flutter analyze
flutter test
```

Tests cover the duration helpers, the `WallClockTimer` math (with an injected clock so they are deterministic), and the ring's rendered states. CI runs analyze + test on every push.

## License

MIT. See [`LICENSE`](LICENSE).
