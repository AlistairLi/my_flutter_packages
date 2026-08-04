import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Called when launching the Android home screen fails.
typedef DoubleBackToHomeErrorCallback = void Function(
    Object error,
    StackTrace stackTrace,
    );

/// Sends an Android app to the home screen after two back presses.
///
/// On Android, the first back press invokes [onFirstBack]. A second press
/// within [interval] launches the system home screen without terminating the
/// app process. On iOS and other platforms, this widget leaves the native back
/// navigation behavior unchanged.
class DoubleBackToHome extends StatefulWidget {
  /// Creates a double-back-to-home handler around [child].
  const DoubleBackToHome({
    super.key,
    required this.child,
    required this.onFirstBack,
    this.interval = const Duration(milliseconds: 1600),
    this.onError,
    this.enabled = true,
  }) : assert(interval > Duration.zero, 'interval must be greater than zero');

  /// The widget below this widget in the tree.
  final Widget child;

  /// Called after the first Android back press.
  ///
  /// The package does not display UI itself. Use this callback to show a toast,
  /// snack bar, or another localized prompt.
  final VoidCallback onFirstBack;

  /// The maximum duration allowed between the two back presses.
  final Duration interval;

  /// Called if launching the Android home screen fails.
  final DoubleBackToHomeErrorCallback? onError;

  /// Whether double-back handling is enabled on Android.
  ///
  /// When false, native back navigation is left unchanged.
  final bool enabled;

  @override
  State<DoubleBackToHome> createState() => _DoubleBackToHomeState();
}

class _DoubleBackToHomeState extends State<DoubleBackToHome> {
  static const AndroidIntent _homeIntent = AndroidIntent(
    action: 'android.intent.action.MAIN',
    category: 'android.intent.category.HOME',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );

  Timer? _secondBackTimer;

  bool get _shouldHandleBack {
    return widget.enabled &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  void didUpdateWidget(covariant DoubleBackToHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((!widget.enabled && oldWidget.enabled) ||
        widget.interval != oldWidget.interval) {
      _clearSecondBackTimer();
    }
  }

  @override
  void dispose() {
    _clearSecondBackTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldHandleBack) {
      return widget.child;
    }

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: widget.child,
    );
  }

  void _onPopInvoked(bool didPop, Object? result) {
    if (didPop) {
      return;
    }

    if (_secondBackTimer == null) {
      _secondBackTimer = Timer(widget.interval, _clearSecondBackTimer);
      widget.onFirstBack();
      return;
    }

    _clearSecondBackTimer();
    unawaited(_moveToHome());
  }

  void _clearSecondBackTimer() {
    _secondBackTimer?.cancel();
    _secondBackTimer = null;
  }

  Future<void> _moveToHome() async {
    try {
      await _homeIntent.launch();
    } catch (error, stackTrace) {
      if (mounted) {
        widget.onError?.call(error, stackTrace);
      }
    }
  }
}
