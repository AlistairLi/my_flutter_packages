import 'package:flutter/material.dart';

/// 弹窗级别的配置
class DialogConfig {
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double topRadius;
  final double pageHeight;
  final double pageMarginHorizontal;
  final double pageMarginVertical;
  final double indicatorMarginHorizontal;
  final double indicatorMarginVertical;
  final double bottomSpace;

  const DialogConfig({
    this.backgroundColor,
    this.indicatorColor,
    this.topRadius = 20,
    this.pageHeight = 240,
    this.pageMarginHorizontal = 0,
    this.pageMarginVertical = 0,
    this.indicatorMarginHorizontal = 50,
    this.indicatorMarginVertical = 10,
    this.bottomSpace = 15,
  });
}

/// 每页级别的配置
class PageConfig {
  final int countPerPage;
  final int countPerRow;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool test;

  const PageConfig({
    this.countPerPage = 8,
    this.countPerRow = 4,
    this.mainAxisSpacing = 1,
    this.crossAxisSpacing = 1,
    this.childAspectRatio = 1.0,
    this.test = false,
  });
}

/// 支持分页展示、带指示器、可自定义内容的通用弹窗组件
/// 可用于礼物弹窗等
class PagedSelectionDialog<T> extends StatefulWidget {
  final List<T> dataList;

  final Widget Function(dynamic data, int index, int pageIndex) itemBuilder;

  final WidgetBuilder? topBuilder;

  final WidgetBuilder? bottomBuilder;

  final DialogConfig dialogConfig;

  final PageConfig pageConfig;

  const PagedSelectionDialog({
    super.key,
    required this.dataList,
    required this.itemBuilder,
    this.topBuilder,
    this.bottomBuilder,
    this.dialogConfig = const DialogConfig(),
    this.pageConfig = const PageConfig(),
  });

  @override
  State<PagedSelectionDialog> createState() => _PagedSelectionDialogState<T>();
}

class _PagedSelectionDialogState<T> extends State<PagedSelectionDialog> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var dialogConfig = widget.dialogConfig;
    var topRadius = dialogConfig.topRadius;
    var paddingBottom =
        MediaQuery.of(context).padding.bottom + dialogConfig.bottomSpace;

    // 总页数
    final int pageCount =
        (widget.dataList.length / widget.pageConfig.countPerPage).ceil();
    return Container(
      padding: EdgeInsets.only(bottom: paddingBottom),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topRadius),
          topRight: Radius.circular(topRadius),
        ),
        color: widget.dialogConfig.backgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.topBuilder != null) widget.topBuilder!(context),
          Container(
            height: dialogConfig.pageHeight,
            margin: EdgeInsets.symmetric(
              horizontal: dialogConfig.pageMarginHorizontal,
              vertical: dialogConfig.pageMarginVertical,
            ),
            alignment: Alignment.center,
            child: PageView.builder(
              itemCount: pageCount,
              itemBuilder: (context, index) {
                return _PageWidget(
                  dataList: widget.dataList,
                  pageIndex: index,
                  itemBuilder: widget.itemBuilder,
                  pageConfig: widget.pageConfig,
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
            ),
          ),
          _buildPageIndicator(dialogConfig, pageCount),
          if (widget.bottomBuilder != null) widget.bottomBuilder!(context),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(DialogConfig config, int pageCount) {
    var indicatorColor = widget.dialogConfig.indicatorColor ?? Colors.blue;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: config.indicatorMarginHorizontal,
        vertical: config.indicatorMarginVertical,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPageIndex == index
                  ? indicatorColor
                  : indicatorColor.withValues(alpha: 0.3),
            ),
          );
        }),
      ),
    );
  }
}

/// 一页内容
class _PageWidget<T> extends StatelessWidget {
  final List<T> dataList;
  final int pageIndex;
  final Widget Function(dynamic data, int index, int pageIndex) itemBuilder;
  final PageConfig pageConfig;

  const _PageWidget({
    super.key,
    required this.dataList,
    required this.pageIndex,
    required this.pageConfig,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final int startIndex = pageIndex * pageConfig.countPerPage;
    final int endIndex = (pageIndex + 1) * pageConfig.countPerPage;
    var totalCount = dataList.length;
    List<T> currentPageList = dataList
        .sublist(startIndex, endIndex < totalCount ? endIndex : totalCount)
        .cast();
    Widget widget = GridView.builder(
      itemCount: currentPageList.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: pageConfig.countPerRow,
        mainAxisSpacing: pageConfig.mainAxisSpacing,
        crossAxisSpacing: pageConfig.crossAxisSpacing,
        childAspectRatio: pageConfig.childAspectRatio,
      ),
      itemBuilder: (context, index) {
        var data = currentPageList[index];
        var current = itemBuilder(data, index, pageIndex);
        if (pageConfig.test) {
          current = Container(
            color: Colors.blue,
            child: current,
          );
        }
        return current;
      },
    );
    if (pageConfig.test) {
      widget = Container(
        color: Colors.green,
        child: widget,
      );
    }
    return widget;
  }
}
