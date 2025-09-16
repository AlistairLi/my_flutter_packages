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
