import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  group('CrashlyticsErrorFilter.shouldIgnoreFlutterError', () {
    FlutterErrorDetails details(Object exception) {
      return FlutterErrorDetails(exception: exception);
    }

    test('ignores explicit transient network exceptions', () {
      expect(
        CrashlyticsErrorFilter.shouldIgnoreFlutterError(
          details(const SocketException('Failed host lookup')),
        ),
        isTrue,
      );
    });

    test('ignores network messages', () {
      final errors = <Object>[
        Exception('No route to host'),
        Exception('Connection refused'),
        Exception('Failed host lookup'),
        Exception('Connection reset by peer'),
        Exception('HttpException'),
        Exception('HandshakeException'),
        Exception('TimeoutException'),
        Exception('Network is unreachable'),
      ];

      for (final error in errors) {
        expect(
          CrashlyticsErrorFilter.shouldIgnoreFlutterError(details(error)),
          isTrue,
          reason: error.toString(),
        );
      }
    });

    test('keeps unrelated Dio bad response errors reportable', () {
      expect(
        CrashlyticsErrorFilter.shouldIgnoreFlutterError(
          details(Exception('DioException [bad response]: status code 500')),
        ),
        isFalse,
      );
    });

    test('ignores image loading errors', () {
      final errors = <Object>[
        Exception('Failed to load image'),
        Exception('ImageCodecException'),
        Exception('Invalid image data'),
        Exception('Unable to decode bytes as an image'),
        Exception('Invalid argument(s): string is not well-formed UTF-16'),
        Exception('Invalid image dimensions'),
      ];

      for (final error in errors) {
        expect(
          CrashlyticsErrorFilter.shouldIgnoreFlutterError(details(error)),
          isTrue,
          reason: error.toString(),
        );
      }
    });

    test('ignores common Flutter non-fatal errors', () {
      final errors = <Object>[
        Exception('A RenderFlex overflowed by 10 pixels'),
        Exception('A RenderBox was not laid out'),
        Exception('Duplicate GlobalKey detected in widget tree'),
        Exception('ScrollController attached to multiple ScrollViews'),
        Exception('Vertical viewport was given unbounded height'),
        Exception('Horizontal viewport was given unbounded width'),
        Exception("NoSuchMethodError: The method 'foo' was called on null"),
        RangeError.index(3, const [1, 2]),
        Exception('assert failed'),
        Exception('Unhandled Exception: MissingPluginException'),
      ];

      for (final error in errors) {
        expect(
          CrashlyticsErrorFilter.shouldIgnoreFlutterError(details(error)),
          isTrue,
          reason: error.toString(),
        );
      }
    });

    test('keeps unrelated errors reportable', () {
      final errors = <Object>[
        Exception('DioException [bad response]: status code 500'),
        Exception('Business flow connection state is invalid'),
        NoSuchMethodError.withInvocation(null, Invocation.getter(#missing)),
      ];

      for (final error in errors) {
        expect(
          CrashlyticsErrorFilter.shouldIgnoreFlutterError(details(error)),
          isFalse,
          reason: error.toString(),
        );
      }
    });
  });
}
