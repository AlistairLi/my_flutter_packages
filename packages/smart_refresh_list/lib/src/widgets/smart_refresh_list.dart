import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_refresh_list/src/config/smart_refresh_config.dart';
import 'package:smart_refresh_list/src/smart_refresh_base.dart';
import 'package:smart_refresh_list/src/smart_refresh_controller.dart';
import 'package:smart_refresh_list/src/widgets/smart_refresh_widget.dart';

/// 下拉刷新和分页加载的ListView
class SmartRefreshList<T> extends StatelessWidget {
  const SmartRefreshList({
    super.key,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoad,
    this.controller,
    this.scrollController,
    this.separatorBuilder,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.physics,
    this.header = const MaterialClassicHeader(),
    this.footer,
    this.styleConfig,
    this.emptyWidget,
    this.errorWidget,
    this.onError,
    this.padding,
  });

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<PageData<T>> Function() onRefresh;
  final Future<PageData<T>> Function(int page) onLoad;
  final SmartRefreshController<T>? controller;
  final ScrollController? scrollController;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool enablePullDown;
  final bool enablePullUp;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final RefreshStyleConfig? styleConfig;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final Function(String? error)? onError;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SmartRefreshWidget<T>(
      controller: controller,
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      physics: physics,
      header: header,
      footer: footer,
      styleConfig: styleConfig,
      emptyWidget: emptyWidget,
      errorWidget: errorWidget,
      onError: onError,
      onRefresh: onRefresh,
      onLoad: onLoad,
      child: (data) {
        if (separatorBuilder != null) {
          return ListView.separated(
            padding: padding,
            itemCount: data.length,
            controller: scrollController,
            itemBuilder: (context, index) => itemBuilder(
              context,
              data[index],
              index,
            ),
            separatorBuilder: separatorBuilder!,
          );
        } else {
          return ListView.builder(
            padding: padding,
            itemCount: data.length,
            controller: scrollController,
            itemBuilder: (context, index) => itemBuilder(
              context,
              data[index],
              index,
            ),
          );
        }
      },
    );
  }
}
