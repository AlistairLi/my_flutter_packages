import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// 初始化 Firebase
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> initFireBase() async {
    try {
      await Firebase.initializeApp();
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

      const fatalError = true;

      FlutterError.onError = (errorDetails) {
        if (kDebugMode) {
          FlutterError.dumpErrorToConsole(errorDetails);
        } else {
          if (fatalError) {
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
          if (fatalError) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          } else {
            // If you want to record a "non-fatal" exception
            FirebaseCrashlytics.instance.recordError(error, stack);
          }
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
