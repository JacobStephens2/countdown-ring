import 'dart:async';

import 'package:countdown_ring/countdown_ring.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'countdown_ring example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  WallClockTimer? _timer;
  Timer? _ticker;

  void _start(Duration d) {
    setState(() => _timer = WallClockTimer.start(d));
    // Tick a few times a second to redraw; the displayed value is always
    // derived from the absolute deadline, so a missed tick never desyncs it.
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) return;
      setState(() {});
      if (_timer != null && _timer!.isExpired()) _ticker?.cancel();
    });
  }

  void _adjust(Duration delta) {
    final t = _timer;
    if (t == null) return;
    setState(() => _timer = t.adjusted(delta));
  }

  void _skip() {
    _ticker?.cancel();
    setState(() => _timer = null);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _timer;
    return Scaffold(
      appBar: AppBar(title: const Text('countdown_ring')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CountdownRing(
              remaining: t?.remainingClamped() ?? Duration.zero,
              fraction: t?.fraction() ?? 0,
              size: 160,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: () => _start(const Duration(seconds: 30)),
                  child: const Text('Start 30s'),
                ),
                FilledButton.tonal(
                  onPressed: () => _start(const Duration(minutes: 2)),
                  child: const Text("Start 2'"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: t == null ? null : () => _adjust(const Duration(seconds: 15)),
                  child: const Text('+15s'),
                ),
                OutlinedButton(
                  onPressed: t == null ? null : () => _adjust(const Duration(seconds: -15)),
                  child: const Text('-15s'),
                ),
                OutlinedButton(
                  onPressed: t == null ? null : _skip,
                  child: const Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
