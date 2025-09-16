// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BaseChangeNotifier2 extends ChangeNotifier {
  BaseChangeNotifier2({this.autoCancelRequests = true});

  // final CancelToken cancelToken = CancelToken();
  bool autoCancelRequests;

  int _updatePage = 0;

  int get updatePage => _updatePage;

  updatePageStatus() {
    _updatePage++;
    if (hasListeners) {
      notifyListeners();
    }
  }

  back() {
    // Get.back();
  }

  @override
  void dispose() {
    super.dispose();
    if (autoCancelRequests) {
      // cancelToken.cancel("$this dispose");
    }
  }
}
