import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class RouteConfig {
  RouteConfig._();

  static bool enablePrint = kDebugMode;

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
}
