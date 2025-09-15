# webview_wrapper

A Flutter WebView wrapper library with enhanced features including dynamic event configuration, JavaScript communication, and external app handling.


## 主要功能

- **Dynamic Event Configuration**: Supports event configuration at both global and instance levels
- **JavaScript Channel Management**: Automatically handles bidirectional communication between JavaScript and Flutter
- **WebView Controller**: Provides an interface similar to ScrollController, enabling external control of WebView behavior
- **Global Configuration Management**: Supports global configuration at the application level
- **External App Handling**: Supports handling external links (phone calls, emails, maps, etc.) through callback functions


## Installation
Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  webview_wrapper: ^1.0.0
```

Then run:
``` bash
flutter pub get
```

## Usage

```dart
class WebviewUtilExample {
  WebviewUtilExample._();

  static WebViewWrapperController controller1 = WebViewWrapperController();

  // 约定好的事件
  static Map<String, String> webViewEvents = {
    "close": "close",
    "yyy": "yyy",
    "zzz": "zzz",
  };

  static void initialize() {
    WebViewGlobalConfig.setGlobalCustomEvents(webViewEvents);
    WebViewGlobalConfig.setGlobalEventHandlers([
      AppJsEventHandlerExample(supportMethods: webViewEvents.keys),
      IntentHandler(),
    ]);
  }

  static void onRechargeSuccess() {
    controller1.notifyRechargeSuccess(WebViewScene.game);
  }
}

class JsEventHandlerExample extends JSEventHandler {
  final Iterable<String> supportMethods;

  JsEventHandlerExample({required this.supportMethods});

  @override
  bool canHandleJSEvent(String methodName, String message) {
    return supportMethods.contains(methodName);
  }

  @override
  bool handleJSEvent(BuildContext context, String methodName, String message) {
    switch (methodName) {
      case "close":
        Navigator.pop(context);
        return true;
      case "yyy":
        // do something
        return true;
    }
    return false;
  }
}

class IntentHandler extends ExternalLinkEventHandler {
  @override
  bool canHandleUrl(String url) {
    return url.startsWith("intent:") || !url.startsWith("http");
  }

  @override
  bool handleUrl(String url) {
    // launchUrl(Uri.parse(url));
    return true;
  }
}
```


## Example

See the example directory for a complete sample app.


## License

The project is under the MIT license.
