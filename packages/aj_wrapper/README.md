# aj_wrapper

A wrapper for the adjust_sdk to simplify integration and usage in Flutter applications.

## Installation

Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  aj_wrapper: ^1.0.0
```

Then run:

``` bash
flutter pub get
```

## Usage

```dart
import 'package:aj_wrapper/aj_wrapper.dart';

/// Implemented in the calling party's project
class MyAJStorage implements AJStorageInterface {
  @override
  Future<bool> saveString(String key, String value) async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.setString(key, value);
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(key);
    return "";
  }

  @override
  Future<bool> remove(String key) async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.remove(key);
    return true;
  }
}

class MyAJConfig implements AJConfigInterface {
  @override
  bool get isRelease => false;

  @override
  String get appToken => "your_app_token";

  @override
  String get purchaseToken => "your_purchase_token";

  @override
  Future<bool> shouldUploadAttributionData() async {
    return true;
  }

  @override
  Future<bool> uploadAttributionData(AdjustAttribution data) async {
    // Call your network service to upload the data.
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

class MyAJError implements AJErrorInterface {
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
  final ajService = AJWrapperFactory.create(
    storage: MyAJStorage(),
    config: MyAJConfig(),
    error: MyAJError(),
  );

  // Initialization, be mindful of the dependency of configuration parameters
  ajService.initialize();

  // Report data after logging in
  ajService.uploadAdjustData();

  // Report the purchase event after the purchase is successful.
  ajService.uploadPurchaseEvent(0.99);
}
```

## Example

See the example directory for a complete sample app.

## License

The project is under the MIT license.