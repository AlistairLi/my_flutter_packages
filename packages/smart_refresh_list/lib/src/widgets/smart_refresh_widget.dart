import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_refresh_list/src/config/smart_refresh_config.dart';
import 'package:smart_refresh_list/src/smart_refresh_base.dart';
import 'package:smart_refresh_list/src/smart_refresh_controller.dart';

/// 下拉刷新和分页加载widget
class SmartRefreshWidget<T> extends StatefulWidget {
  final Widget Function(List<T> data) child;
  final Future<PageData<T>> Function()? onRefresh;
  final Future<PageData<T>> Function(int page)? onLoad;
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

  const SmartRefreshWidget({
    super.key,
    required this.child,
    this.onRefresh,
    this.onLoad,
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
    this.dataTransformer,
  });

  final DataTransformer<T>? dataTransformer;

  @override
  State<SmartRefreshWidget<T>> createState() => _SmartRefreshWidgetState<T>();
}

class _SmartRefreshWidgetState<T> extends State<SmartRefreshWidget<T>> {
  late final SmartRefreshController<T> _ctl =
      widget.controller ?? SmartRefreshController<T>();

  @override
  void dispose() {
    if (widget.controller == null) _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<T>>(
      valueListenable: _ctl.dataNotifier,
      builder: (context, data, child) {
        return SmartRefresher(
          controller: _ctl.raw,
          enablePullDown: widget.enablePullDown,
          enablePullUp: widget.enablePullUp,
          physics: widget.physics,
          header: widget.header,
          footer: widget.footer,
          onRefresh: widget.onRefresh != null ? _handleRefresh : null,
          onLoading: widget.onLoad != null ? _handleLoad : null,
          child: _buildChild(data),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    try {
      final pageData = await widget.onRefresh!();
      _ctl.setPage(pageData.page, pageSize: pageData.pageSize);
      _ctl.setData(pageData.data ?? []);
      _ctl.finishRefresh(success: true);
    } catch (e) {
      _ctl.finishRefresh(success: false);
      widget.onError?.call(e.toString());
    }
  }

  Future<void> _handleLoad() async {
    try {
      final nextPage = _ctl.currentPage + 1;
      final pageData = await widget.onLoad!(nextPage);
      _ctl.addData(pageData.data ?? []);
      _ctl.setPage(pageData.page, pageSize: pageData.pageSize);
      _ctl.finishLoad(success: true, noMore: !pageData.getHasMore());
    } catch (e) {
      _ctl.finishLoad(success: false);
      widget.onError?.call(e.toString());
    }
  }

  Widget _buildChild(List<T> data) {
    var isNotRefreshing = _ctl.headerStatus != RefreshStatus.refreshing;
    var isNotLoading = _ctl.footerStatus != LoadStatus.loading;
    if (_ctl.isEmpty &&
        isNotRefreshing &&
        isNotLoading &&
        widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return widget.child(data);
  }
}
