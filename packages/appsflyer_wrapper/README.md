# appsflyer_wrapper

A wrapper for the `appsflyer_sdk` to simplify integration and usage in Flutter applications.

## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  appsflyer_wrapper: ^1.0.0
```

Then run:

``` bash
flutter pub get
```

## Usage

```dart
import 'package:appsflyer_wrapper/appsflyer_wrapper.dart';

/// Implemented in the calling party's project
class MyAJConfig implements AFConfigInterface {
  @override
  bool get isRelease => false;

  @override
  String get appleId => "xxxxxxxxxx";

  @override
  String get appsflyerAndroidKey => "xxxxxxxxx";

  @override
  String get appsflyerIOSKey => "xxxxxxxxxxxxxxxxxxxxxx";

  @override
  Future<bool> shouldUploadAttributionData() async {
    return true;
  }

  @override
  Future<bool> uploadAttributionData(AppsflyerArgs data) async {
    // Call the network service to upload data
    // try {
    //   final response = await http.post(
    //     Uri.parse('your_api_endpoint'),
    //     body: jsonEncode(data),
    //   );
    //   return response.statusCode == 200;
    // } catch (e) {
    //   return false;
    // }
    return true;
  }
}

class MyAJError implements AFErrorInterface {
  @override
  void onError({
    String? event,
    String? source,
    String? errorMsg,
  }) async {
    // Report the error to the server
  }
}

/// usage
void main() {
  final ajService = AFWrapperFactory.create(
    config: MyAJConfig(),
    error: MyAJError(),
  );

  // Initialization, be mindful of the dependency of configuration parameters
  ajService.initialize();

  // Report the purchase event after the purchase is successful.
  ajService.uploadPurchaseEvent(9.99);
}

```

## Example

See the example directory for a complete sample app.

## License

The project is under the MIT license.