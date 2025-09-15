import 'package:flutter/cupertino.dart';

import 'route_name.dart';

class AppNavigator {
  AppNavigator._();

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static void openLogin(BuildContext context) {
    Navigator.pushNamed(context, RouteName.login);
  }
}
