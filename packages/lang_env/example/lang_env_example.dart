import 'package:lang_env/lang_env.dart';

void main() {
  var languageCode = LangEnv.deviceLanguageCode;
  var countryCode = LangEnv.deviceCountryCode;
  LangEnv.setOnLocaleChanged(() {
    var languageCode = LangEnv.deviceLanguageCode;
    var countryCode = LangEnv.deviceCountryCode;
  });
  print('languageCode: $languageCode, countryCode: $countryCode');
}
