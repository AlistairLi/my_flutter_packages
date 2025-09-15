import 'dart:io';

import 'package:app_image_picker/src/android_photo_picker_config.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 配置 Android 照片选择器
  if (Platform.isAndroid) {
    AndroidPhotoPickerConfig.configure();
  }
  // runApp(MyApp());
}
