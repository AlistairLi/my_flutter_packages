import 'package:flutter/material.dart';

/// 顶部弹窗
Future<T?> showTopDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color barrierColor = Colors.black54,
  String? barrierLabel,
  Duration transitionDuration = const Duration(milliseconds: 200),
  String? routeName,
  RouteSettings? routeSettings,
  bool useRootNavigator = true,
  bool enableFade = false,
  Curve curve = Curves.easeOutCubic,
  Curve reverseCurve = Curves.easeOutQuart,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: transitionDuration,
    barrierColor: barrierColor,
    routeSettings: routeSettings ??
        (routeName != null ? RouteSettings(name: routeName) : null),
    useRootNavigator: useRootNavigator,
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.topCenter,
        child: child,
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      Widget current = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: anim1,
            curve: curve,
            reverseCurve: reverseCurve,
          ),
        ),
        child: child,
      );
      if (enableFade) {
        current = FadeTransition(
          opacity: anim1,
          child: current,
        );
      }
      return current;
    },
  );
}

/// 底部弹窗
/// [showModalBottomSheet]
/// [showBottomSheet]
Future<T?> showBottomDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color barrierColor = Colors.black54,
  String? barrierLabel,
  Duration transitionDuration = const Duration(milliseconds: 200),
  String? routeName,
  RouteSettings? routeSettings,
  bool useRootNavigator = true,
  bool enableFade = false,
  Curve curve = Curves.easeInCubic,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierDismissible: barrierDismissible,
    transitionDuration: transitionDuration,
    barrierColor: barrierColor,
    routeSettings: routeSettings ??
        (routeName != null ? RouteSettings(name: routeName) : null),
    useRootNavigator: useRootNavigator,
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: child,
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      Widget current = SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim1, curve: curve)),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      );
      if (enableFade) {
        current = FadeTransition(
          opacity: anim1,
          child: current,
        );
      }
      return current;
    },
  );
}

/// 缩放弹窗
Future<T?> showScaleDialog<T>({
  required BuildContext context,
  required RoutePageBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = Colors.black54,
  String? barrierLabel,
  Duration transitionDuration = const Duration(milliseconds: 200),
  String? routeName,
  RouteSettings? routeSettings,
  bool useRootNavigator = true,
  Curve curve = Curves.linear,
  double scaleBegin = 0.0,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierDismissible: barrierDismissible,
    transitionDuration: transitionDuration,
    barrierColor: barrierColor,
    routeSettings: routeSettings ??
        (routeName != null ? RouteSettings(name: routeName) : null),
    useRootNavigator: useRootNavigator,
    pageBuilder: builder,
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: scaleBegin, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: curve),
        ),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      );
    },
  );
}

/// 淡入弹窗
Future<T?> showFadeDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color barrierColor = Colors.black54,
  String? barrierLabel,
  Duration transitionDuration = const Duration(milliseconds: 200),
  String? routeName,
  RouteSettings? routeSettings,
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierDismissible: barrierDismissible,
    transitionDuration: transitionDuration,
    barrierColor: barrierColor,
    routeSettings: routeSettings ??
        (routeName != null ? RouteSettings(name: routeName) : null),
    useRootNavigator: useRootNavigator,
    pageBuilder: (context, anim1, anim2) {
      return Center(child: child);
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: child,
      );
    },
  );
}
