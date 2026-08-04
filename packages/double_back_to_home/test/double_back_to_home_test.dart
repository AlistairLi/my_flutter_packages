import 'package:double_back_to_home/double_back_to_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calls onFirstBack after the first Android back press', (
    WidgetTester tester,
  ) async {
    await _withPlatform(TargetPlatform.android, () async {
      var promptCount = 0;
      await tester.pumpWidget(
        _TestApp(onFirstBack: () => promptCount++),
      );

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(promptCount, 1);
    });
  });

  testWidgets('does not prompt again on an immediate second back press', (
    WidgetTester tester,
  ) async {
    await _withPlatform(TargetPlatform.android, () async {
      var promptCount = 0;
      await tester.pumpWidget(
        _TestApp(onFirstBack: () => promptCount++),
      );

      await tester.binding.handlePopRoute();
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(promptCount, 1);
    });
  });

  testWidgets('prompts again after the interval expires', (
    WidgetTester tester,
  ) async {
    await _withPlatform(TargetPlatform.android, () async {
      var promptCount = 0;
      const interval = Duration(milliseconds: 1600);
      await tester.pumpWidget(
        _TestApp(
          interval: interval,
          onFirstBack: () => promptCount++,
        ),
      );

      await tester.binding.handlePopRoute();
      await tester.pump(interval);
      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(promptCount, 2);
    });
  });

  testWidgets('does not intercept back navigation on iOS', (
    WidgetTester tester,
  ) async {
    await _withPlatform(TargetPlatform.iOS, () async {
      var promptCount = 0;
      await tester.pumpWidget(
        _TestApp(onFirstBack: () => promptCount++),
      );

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(promptCount, 0);
    });
  });
}

Future<void> _withPlatform(
  TargetPlatform platform,
  Future<void> Function() body,
) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.onFirstBack,
    this.interval = const Duration(milliseconds: 1600),
  });

  final VoidCallback onFirstBack;
  final Duration interval;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DoubleBackToHome(
        interval: interval,
        onFirstBack: onFirstBack,
        child: const Scaffold(body: Text('Home')),
      ),
    );
  }
}
