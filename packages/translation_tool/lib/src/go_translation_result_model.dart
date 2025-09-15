// data : {"translations":[{"translatedText":"你好世界","detectedSourceLanguage":"en"}]}

/// Google 翻译结果模型
class GoTranslationResultModel {
  GoTranslationResultModel({
    Data? data,
  }) {
    _data = data;
  }

  GoTranslationResultModel.fromJson(dynamic json) {
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Data? _data;

  GoTranslationResultModel copyWith({
    Data? data,
  }) =>
      GoTranslationResultModel(
        data: data ?? _data,
      );

  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

/// translations : [{"translatedText":"你好世界","detectedSourceLanguage":"en"}]

class Data {
  Data({
    List<Translations>? translations,
  }) {
    _translations = translations;
  }

  Data.fromJson(dynamic json) {
    if (json['translations'] != null) {
      _translations = [];
      json['translations'].forEach((v) {
        _translations?.add(Translations.fromJson(v));
      });
    }
  }

  List<Translations>? _translations;

  Data copyWith({
    List<Translations>? translations,
  }) =>
      Data(
        translations: translations ?? _translations,
      );

  List<Translations>? get translations => _translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_translations != null) {
      map['translations'] = _translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// translatedText : "你好世界"
/// detectedSourceLanguage : "en"

class Translations {
  Translations({
    String? translatedText,
    String? detectedSourceLanguage,
  }) {
    _translatedText = translatedText;
    _detectedSourceLanguage = detectedSourceLanguage;
  }

  Translations.fromJson(dynamic json) {
    _translatedText = json['translatedText'];
    _detectedSourceLanguage = json['detectedSourceLanguage'];
  }

  String? _translatedText;
  String? _detectedSourceLanguage;

  Translations copyWith({
    String? translatedText,
    String? detectedSourceLanguage,
  }) =>
      Translations(
        translatedText: translatedText ?? _translatedText,
        detectedSourceLanguage:
            detectedSourceLanguage ?? _detectedSourceLanguage,
      );

  String? get translatedText => _translatedText;

  String? get detectedSourceLanguage => _detectedSourceLanguage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['translatedText'] = _translatedText;
    map['detectedSourceLanguage'] = _detectedSourceLanguage;
    return map;
  }
}
