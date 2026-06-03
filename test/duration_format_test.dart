import 'package:countdown_ring/countdown_ring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compactLabel', () {
    test('zero', () => expect(Duration.zero.compactLabel, '0s'));
    test('seconds under two minutes', () {
      expect(const Duration(seconds: 60).compactLabel, '60s');
      expect(const Duration(seconds: 90).compactLabel, '90s');
      expect(const Duration(seconds: 119).compactLabel, '119s');
    });
    test('whole minutes at or above two', () {
      expect(const Duration(minutes: 2).compactLabel, "2'");
      expect(const Duration(minutes: 3).compactLabel, "3'");
    });
    test('half minutes', () {
      expect(const Duration(seconds: 150).compactLabel, "2.5'");
    });
    test('non-half above two minutes falls back to seconds', () {
      expect(const Duration(seconds: 130).compactLabel, '130s');
    });
  });

  group('clockLabel', () {
    test('pads minutes and seconds', () {
      expect(const Duration(seconds: 84).clockLabel, '01:24');
      expect(const Duration(seconds: 5).clockLabel, '00:05');
      expect(const Duration(minutes: 12, seconds: 3).clockLabel, '12:03');
    });
    test('negative keeps a leading minus', () {
      expect(const Duration(seconds: -3).clockLabel, '-00:03');
    });
  });

  group('parseDuration', () {
    test('seconds', () {
      expect(parseDuration('90s'), const Duration(seconds: 90));
      expect(parseDuration('90'), const Duration(seconds: 90));
    });
    test('minutes with apostrophe', () {
      expect(parseDuration("2'"), const Duration(minutes: 2));
      expect(parseDuration("2.5'"), const Duration(seconds: 150));
    });
    test('MM:SS', () {
      expect(parseDuration('1:30'), const Duration(seconds: 90));
    });
    test('combined', () {
      expect(parseDuration('1m30s'), const Duration(seconds: 90));
    });
    test('unparseable returns null', () {
      expect(parseDuration(''), isNull);
      expect(parseDuration('soon'), isNull);
    });
  });
}
