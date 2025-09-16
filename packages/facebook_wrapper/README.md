# facebook_wrapper

A wrapper for the `fb_sdk_flutter` to simplify integration and usage in Flutter applications.

## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  facebook_wrapper: ^1.0.0
```

Then run:

``` bash
flutter pub get
```

## Usage

```dart
import 'package:facebook_wrapper/facebook_wrapper.dart';

/// Implemented in the calling party's project
class MyFBConfig implements FacebookConfigInterface {
  @override
  String get defaultId => "";

  @override
  String get defaultToken => "";

  @override
  Future<String?> get serverId => Future.value("");

  @override
  Future<String?> get serverToken => Future.value("");
}

class MyFBError implements FacebookErrorInterface {
  @override
  void onError({
    String? event,
    String? source,
    String? errorMsg,
  }) async {
    // Report the error to the server
  }
}

/// Usage
void main() {
  final fbService = FacebookWrapperFactory.create(
    config: MyFBConfig(),
    error: MyFBError(),
  );

  // Initialization, be mindful of the dependency of configuration parameters
  fbService.initialize();

  // Report the purchase event after the purchase is successful.
  fbService.uploadPurchaseEvent(1.99);
}

```

## Example

See the example directory for a complete sample app.

## License

The project is under the MIT license.