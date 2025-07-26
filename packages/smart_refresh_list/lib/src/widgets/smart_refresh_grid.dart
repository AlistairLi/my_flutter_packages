import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_refresh_list/src/config/smart_refresh_config.dart';
import 'package:smart_refresh_list/src/smart_refresh_base.dart';
import 'package:smart_refresh_list/src/smart_refresh_controller.dart';
import 'package:smart_refresh_list/src/widgets/smart_refresh_widget.dart';

/// 下拉刷新和分页加载的GridView
class SmartRefreshGrid<T> extends StatelessWidget {
  const SmartRefreshGrid({
    super.key,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoad,
    this.controller,
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
    this.gridDelegate,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.maxCrossAxisExtent,
  });

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<PageData<T>> Function() onRefresh;
  final Future<PageData<T>> Function(int page) onLoad;
  final SmartRefreshController<T>? controller;
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

  // GridView 相关参数
  final SliverGridDelegate? gridDelegate;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final double? maxCrossAxisExtent;

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
        return GridView.builder(
          padding: padding,
          gridDelegate: gridDelegate ?? _buildGridDelegate(),
          itemCount: data.length,
          itemBuilder: (context, index) => itemBuilder(
            context,
            data[index],
            index,
          ),
        );
      },
    );
  }

  /// 构建默认的网格代理
  SliverGridDelegate _buildGridDelegate() {
    if (mainAxisExtent != null) {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisExtent: mainAxisExtent!,
      );
    } else if (maxCrossAxisExtent != null) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent!,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      );
    } else {
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      );
    }
  }
}
