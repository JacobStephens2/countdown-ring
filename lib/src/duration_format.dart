/// Formatting and parsing helpers for short countdown/interval durations.
///
/// Everything is expressed in whole seconds. Two display forms are provided:
/// a compact label (`90s`, `2'`, `2.5'`) and a clock label (`MM:SS`).
library;

/// Display labels for a [Duration].
extension CountdownDurationFormat on Duration {
  /// Compact label. Sub-two-minute intervals stay in seconds (`60s`, `90s`);
  /// two minutes and up collapse to minutes with an apostrophe on whole and
  /// half-minute boundaries (`2'`, `2.5'`, `3'`). Anything else falls back to
  /// seconds. Zero renders as `0s`.
  String get compactLabel {
    final totalSeconds = inSeconds;
    if (totalSeconds == 0) return '0s';
    if (totalSeconds >= 120) {
      if (totalSeconds % 60 == 0) return "${totalSeconds ~/ 60}'";
      if (totalSeconds % 30 == 0) {
        return "${(totalSeconds / 60).toStringAsFixed(1)}'";
      }
    }
    return '${totalSeconds}s';
  }

  /// `MM:SS` clock label for a live countdown (`01:24`). Negative durations
  /// keep a leading `-` so an overrun reads `-00:03`.
  String get clockLabel {
    final negative = isNegative;
    final s = inSeconds.abs();
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '${negative ? '-' : ''}$mm:$ss';
  }
}

/// Parses an interval written in compact notation. Accepts `90s`, `90`, `2'`,
/// `2.5'`, `1:30`, or `1m30s`. Returns `null` when the input is unparseable.
Duration? parseDuration(String raw) {
  final text = raw.trim().toLowerCase();
  if (text.isEmpty) return null;

  // MM:SS form.
  final clock = RegExp(r'^(\d+):(\d{1,2})$').firstMatch(text);
  if (clock != null) {
    return Duration(
      minutes: int.parse(clock.group(1)!),
      seconds: int.parse(clock.group(2)!),
    );
  }

  // Minutes with apostrophe (2', 2.5').
  final mins = RegExp(r"^(\d+(?:\.\d+)?)\s*'$").firstMatch(text);
  if (mins != null) {
    return Duration(seconds: (double.parse(mins.group(1)!) * 60).round());
  }

  // Seconds (90s, 90).
  final secs = RegExp(r'^(\d+)\s*s?$').firstMatch(text);
  if (secs != null) {
    return Duration(seconds: int.parse(secs.group(1)!));
  }

  // Combined 1m30s.
  final combined =
      RegExp(r'^(?:(\d+)\s*m)?\s*(?:(\d+)\s*s)?$').firstMatch(text);
  if (combined != null &&
      (combined.group(1) != null || combined.group(2) != null)) {
    return Duration(
      minutes: int.tryParse(combined.group(1) ?? '') ?? 0,
      seconds: int.tryParse(combined.group(2) ?? '') ?? 0,
    );
  }

  return null;
}
