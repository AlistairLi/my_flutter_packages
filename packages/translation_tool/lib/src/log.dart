import 'package:flutter/foundation.dart';

transLog(String tag, String msg) {
  if (kDebugMode) {
    print('[translation_tool]  $tag  $msg');
  }
}
