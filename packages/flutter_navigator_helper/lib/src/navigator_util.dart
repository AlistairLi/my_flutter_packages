import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_navigator_helper/src/navigator_observer_impl.dart';
import 'package:flutter_navigator_helper/src/route_config.dart';

class NavigatorUtil {
  NavigatorUtil._();

  static const String _tag = "NavigatorUtil";

  static final routeCompleter = <Route<dynamic>, List<Completer<bool>>>{};

  /// 某个路由是否存在
  static bool isRouteExist(String routeName) {
    for (var element in naviObserverImpl.routeHistories) {
      if (element.settings.name == routeName) {
        return true;
      }
    }
    return false;
  }

  /// 检查是否存在指定的多个路由中的任意一个
  static bool isAnyRouteExist(List<String> routeNames) {
    for (var element in naviObserverImpl.routeHistories) {
      if (routeNames.contains(element.settings.name)) {
        return true;
      }
    }
    return false;
  }

  /// 栈顶路由
  static String? get topStackRoutingName {
    if (naviObserverImpl.routeHistories.isEmpty) {
      return '';
    }
    final currentRoute = naviObserverImpl.routeHistories.last;
    return currentRoute.settings.name;
  }

  /// 关闭指定页面、弹窗
  static void close(List<String> routeNames) {
    try {
      List result = [];
      for (var element in naviObserverImpl.routeHistories) {
        if (routeNames.contains(element.settings.name)) {
          result.add(element);
        }
      }
      for (var element in result) {
        RouteConfig.navigatorKey.currentState?.removeRoute(element);
      }
    } catch (e) {
      if (RouteConfig.enablePrint) {
        print("$_tag, close(), $e");
      }
    }
  }

  // 关闭指定界面以及其上面的弹窗和页面
  static void closeAllAbove(String routeName) {
    try {
      final navigator = RouteConfig.navigatorKey.currentState;
      if (navigator == null) {
        if (RouteConfig.enablePrint) {
          print("$_tag, closeAllAbove(), navigator is null");
        }
        return;
      }

      // 找到目标路由的索引
      int targetIndex = -1;
      for (int i = 0; i < naviObserverImpl.routeHistories.length; i++) {
        if (naviObserverImpl.routeHistories[i].settings.name == routeName) {
          targetIndex = i;
          break;
        }
      }

      // 如果没找到目标路由，直接返回
      if (targetIndex == -1) {
        if (RouteConfig.enablePrint) {
          print("$_tag, closeAllAbove(), route '$routeName' not found");
        }
        return;
      }

      // 从栈顶开始，关闭目标路由上面的所有路由
      // 注意：routeHistories 是从栈底到栈顶的顺序
      for (int i = naviObserverImpl.routeHistories.length - 1; i > targetIndex; i--) {
        final route = naviObserverImpl.routeHistories[i];
        try {
          navigator.removeRoute(route);
          if (RouteConfig.enablePrint) {
            print("$_tag, closeAllAbove(), removed route: ${route.settings.name}");
          }
        } catch (e) {
          if (RouteConfig.enablePrint) {
            print("$_tag, closeAllAbove(), failed to remove route ${route.settings.name}: $e");
          }
        }
      }

      // 最后关闭目标路由本身
      final targetRoute = naviObserverImpl.routeHistories[targetIndex];
      try {
        navigator.removeRoute(targetRoute);
        if (RouteConfig.enablePrint) {
          print("$_tag, closeAllAbove(), removed target route: ${targetRoute.settings.name}");
        }
      } catch (e) {
        if (RouteConfig.enablePrint) {
          print("$_tag, closeAllAbove(), failed to remove target route ${targetRoute.settings.name}: $e");
        }
      }
    } catch (e) {
      if (RouteConfig.enablePrint) {
        print("$_tag, closeAllAbove(), $e");
      }
    }
  }

  static void init() {
    naviObserverImpl.routeStream.listen((event) {
      if (routeCompleter.isNotEmpty) {
        for (Route<dynamic> route in routeCompleter.keys) {
          if (!naviObserverImpl.routeHistories.contains(route)) {
            // 路由已销毁
            routeCompleter[route]?.forEach((element) {
              if (!element.isCompleted) {
                element.complete(false);
              }
            });
          } else if (naviObserverImpl.routeHistories.last == route) {
            // 路由已回到顶部
            routeCompleter[route]?.forEach((element) {
              if (!element.isCompleted) {
                element.complete(true);
              }
            });
          }
        }
        routeCompleter.removeWhere(
            (key, value) => !naviObserverImpl.routeHistories.contains(key));
        routeCompleter.removeWhere((key, value) => event == key);
      }
    });
  }
}
