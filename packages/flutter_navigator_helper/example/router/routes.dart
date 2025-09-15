import 'package:flutter/material.dart';

import 'route_name.dart';

typedef MyRouteBuilder = Widget Function(
  BuildContext context, {
  Object? arguments,
});

var onGenerateRoute = (RouteSettings settings) {
  final String? name = settings.name;
  final MyRouteBuilder? pageContentBuilder = namedRoutes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      return MaterialPageRoute(
        builder: (context) => pageContentBuilder(
          context,
          arguments: settings.arguments,
        ),
      );
    } else {
      return MaterialPageRoute(
        builder: (context) => pageContentBuilder(context),
      );
    }
  }
  return MaterialPageRoute(builder: (context) => SizedBox()); // NotFoundPage
};

final Map<String, MyRouteBuilder> namedRoutes = {
  RouteName.splash: (context, {arguments}) => SizedBox(),
  RouteName.login: (context, {arguments}) => SizedBox(),
};
