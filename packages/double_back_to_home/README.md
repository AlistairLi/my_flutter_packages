# double_back_to_home

A small Flutter widget that sends an Android app to the home screen when the
user presses the back button twice within a configurable interval. The app is
moved to the background instead of being terminated.

On iOS, the widget does not intercept navigation because iOS does not provide a
system back button or allow apps to programmatically return to the home screen.

## Features

- Calls an application-provided callback after the first Android back press.
- Opens the Android home screen after the second back press.
- Keeps the app process alive in the background.
- Preserves native iOS and non-Android navigation behavior.
- Uses no state-management or toast dependencies.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  double_back_to_home: ^0.0.1
```

Then run:

```shell
flutter pub get
```

## Usage

Place `DoubleBackToHome` inside the route whose Android back action should be
intercepted. It must be below `MaterialApp` or `CupertinoApp`, not outside it.

```dart
import 'package:double_back_to_home/double_back_to_home.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DoubleBackToHome(
      interval: const Duration(milliseconds: 1600),
      onFirstBack: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Press back again to go home')),
        );
      },
      onError: (error, stackTrace) {
        debugPrint('Could not open the Android home screen: $error');
      },
      child: const Scaffold(
        body: Center(child: Text('Home page')),
      ),
    );
  }
}
```

The package deliberately does not display a toast. Implement `onFirstBack`
with your preferred toast, snack bar, or localized prompt.

## Platform behavior

| Platform | Behavior |
| --- | --- |
| Android | First back press invokes `onFirstBack`; the second opens the home screen. |
| iOS | Back navigation is not intercepted and follows the native route behavior. |
| Other platforms | Back navigation is not intercepted. |

See the complete application in [`example/lib/main.dart`](example/lib/main.dart).
