import 'dart:io';

import 'package:flutter/foundation.dart';

class CrashlyticsErrorFilter {
  static bool shouldRecordAsFatal(Object error) {
    return !isNetworkRelated(error);
  }

  static bool isNetworkRelated(Object error) {
    if (error is SocketException ||
        error is HttpException ||
        error is HandshakeException ||
        error is TlsException) {
      return true;
    }

    final message = error.toString().toLowerCase();
    const keywords = <String>[
      'failed host lookup',
      'connection closed while receiving data',
      'connection terminated during handshake',
      'software caused connection abort',
      'clientexception',
      'socketexception',
      'httpexception',
      'handshakeexception',
      'dioexception',
      'cronet exception',
      'err_address_unreachable',
      'network is unreachable',
      'connection reset by peer',
      'timed out',
      'timeout',
      'no address associated with hostname',
    ];

    return keywords.any(message.contains);
  }

  static bool shouldRecordFlutterErrorAsFatal(FlutterErrorDetails details) {
    return shouldRecordAsFatal(details.exception);
  }
}
