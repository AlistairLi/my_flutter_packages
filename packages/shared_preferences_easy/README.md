# shared_preferences_easy

A simple wrapper for shared_preferences with enhanced type safety and easier usage.

## Features

- Simple shared_preferences wrapper
- Type-safe data storage and retrieval
- Supports String, int, double, bool, and List<String> types
- Automatic type conversion
- Easy initialization and usage

## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  shared_preferences_easy: ^1.0.0
```

Then run:

``` bash
flutter pub get
```

## Usage

```dart
import 'package:shared_preferences_easy/shared_preferences_easy.dart';

void main() async {
  // When the application starts, initialize PreferenceUtils
  await PreferenceUtils.init();
}

class SpUtil {
  SpUtil._();

  static Future<bool> putString(String key, String? value) {
    return PreferenceUtils.set(key, value);
  }

  static String? getString(String key) {
    return PreferenceUtils.get<String>(key);
  }
}
```

## Example

See the example directory for a complete sample app.

## License

The project is under the MIT license.