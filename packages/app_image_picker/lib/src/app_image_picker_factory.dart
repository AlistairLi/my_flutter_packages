import 'package:app_image_picker/src/app_image_picker_base.dart';
import 'package:app_image_picker/src/image_picker_impl.dart';

class AppImagePickerFactory {
  AppImagePickerFactory._();

  static AppImagePicker _instance = ImagePickerImpl();

  static AppImagePicker get instance => _instance;

  static void setCustomImpl(AppImagePicker impl) {
    _instance = impl;
  }
}
