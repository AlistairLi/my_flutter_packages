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
          if (_shouldIgnoreFatalFlutterError(errorDetails)) {
            return;
          }

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
          if (_isIgnorableImageLoadException(error, stack)) {
            return true;
          }

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

  static bool _isIgnorableImageLoadException(Object error, [StackTrace? stackTrace]) {
    final errorText = error.toString().toLowerCase();
    final stackText = stackTrace?.toString().toLowerCase() ?? '';
    final isConnectionClosed =
    errorText.contains('connection closed while receiving data');
    final isHttpException = errorText.contains('httpexception');
    // final isImageRequest = RegExp(
    //   r'uri\s*=\s*https?:\/\/\S+\.(png|jpg|jpeg|webp|gif|bmp|svg)(\?|$)',
    //   caseSensitive: false,
    // ).hasMatch(error.toString());
    final isImageStack = stackText.contains('cached_network_image') ||
        stackText.contains('octo_image') ||
        stackText.contains('flutter_cache_manager') ||
        stackText.contains('image_provider');

    // return isConnectionClosed &&
    //     (isHttpException || isImageRequest || isImageStack);
    return isConnectionClosed && (isHttpException || isImageStack);
  }

  static bool _shouldIgnoreFatalFlutterError(FlutterErrorDetails errorDetails) {
    return _isIgnorableImageLoadException(
      errorDetails.exception,
      errorDetails.stack,
    );
  }

}
