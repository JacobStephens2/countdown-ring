# Changelog

## 0.1.0

Initial release. Extracted and generalized from the Quadrille rest timer.

- `CountdownRing` - a themable circular countdown widget (`CustomPainter`).
- `WallClockTimer` - a deadline-anchored, immutable timer model that survives
  backgrounding and process death.
- `CountdownDurationFormat` extension (`compactLabel`, `clockLabel`) and
  `parseDuration` for compact interval notation.
