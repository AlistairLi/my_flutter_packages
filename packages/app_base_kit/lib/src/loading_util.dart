import 'package:flutter_easyloading/flutter_easyloading.dart';

/// loading 工具
class LoadingUtil {
  LoadingUtil._();

  static void show({String? message}) {
    EasyLoading.show(status: message);
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }
}
