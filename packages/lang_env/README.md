# lang_env

A Flutter utility package for retrieving device and application locale information using official Flutter APIs.

## Features

- ✅ Get device locale information
- ✅ Access current app language settings
- ✅ Retrieve device language and country codes
- ✅ Listen to locale changes


## Installation
Add the dependency in `pubspec.yaml`:

```yaml 
dependencies:
  lang_env: ^1.0.0
```

Then run:
``` bash
flutter pub get
```


## Usage

```dart
void main() {
  var languageCode = LangEnv.deviceLanguageCode;
  var countryCode = LangEnv.deviceCountryCode;
  LangEnv.setOnLocaleChanged(() {
    var languageCode = LangEnv.deviceLanguageCode;
    var countryCode = LangEnv.deviceCountryCode;
  });
  print('languageCode: $languageCode, countryCode: $countryCode');
}
```


## Example

See the example directory for a complete sample app.


## License

The project is under the MIT license.