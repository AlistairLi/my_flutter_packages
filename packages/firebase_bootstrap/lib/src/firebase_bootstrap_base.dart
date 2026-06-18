import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crashlytics_error_filter.dart';

/// 初始化 Firebase
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> initFireBase({bool? enableCrashlytics}) async {
    try {
      await Firebase.initializeApp();
      FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(enableCrashlytics ?? !kDebugMode);

      FlutterError.onError = (errorDetails) {
        // 保留 Flutter 的红屏提示
        // FlutterError.presentError(errorDetails);

        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(errorDetails);
          return;
        }
        if (CrashlyticsErrorFilter.shouldIgnoreFlutterError(errorDetails)) {
          // 日志
          return;
        }
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        var errorDetails = FlutterErrorDetails(exception: error, stack: stack);
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(errorDetails);
          return true;
        }
        if (CrashlyticsErrorFilter.shouldIgnoreFlutterError(errorDetails)) {
          // 日志
          return true;
        }
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
