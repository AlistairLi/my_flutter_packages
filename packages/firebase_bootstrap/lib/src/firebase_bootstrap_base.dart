import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crashlytics_error_filter.dart';

/// 初始化 Firebase
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> initFireBase() async {
    try {
      await Firebase.initializeApp();
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

      FlutterError.onError = (errorDetails) {
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(errorDetails);
        } else {
          if (CrashlyticsErrorFilter.shouldRecordFlutterErrorAsFatal(
              errorDetails)) {
            FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
          } else {
            FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
          }
        }
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(exception: error, stack: stack),
          );
        } else {
          FirebaseCrashlytics.instance.recordError(
            error,
            stack,
            fatal: CrashlyticsErrorFilter.shouldRecordAsFatal(error),
          );
        }
        return true;
      };
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
