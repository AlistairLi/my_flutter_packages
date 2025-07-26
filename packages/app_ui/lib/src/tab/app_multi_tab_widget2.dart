import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void _mLog(String message) {
  if (kDebugMode) {
    print("[MultiTab]  $message");
  }
}

/// 通用二级Tab组件
/// T: 一级tab数据模型类型
/// U: 二级tab数据模型类型
class MultiTabView2<T, U> extends StatefulWidget {
  /// 一级tab数据列表
  final List<T> firstLevelTabs;

  /// 二级tab数据列表（每个一级tab对应的二级tab列表）
  final List<List<U>> secondLevelTabs;

  /// 一级tab标题提取器
  final String Function(T) firstLevelTitleExtractor;

  /// 二级tab标题提取器
  final String Function(U) secondLevelTitleExtractor;

  /// 一级tab选中回调
  final Function(int firstIndex, T firstTab)? onFirstLevelSelected;

  /// 二级tab选中回调
  final Function(int firstIndex, int secondIndex, T firstTab, U secondTab)?
      onSecondLevelSelected;

  /// 内容构建器
  final Widget Function(
      int firstIndex, int secondIndex, T firstTab, U secondTab) contentBuilder;

  /// 一级tab样式配置
  final TabStyleConfig2? firstLevelStyle;

  /// 二级tab样式配置
  final TabStyleConfig2? secondLevelStyle;

  /// 是否显示二级tab
  final bool Function(List<U> secondTabs)? shouldShowSecondLevel;

  /// 在一级tab之后按行显示的小部件列表
  final List<Widget>? actions;

  /// 自定义头部组件
  final Widget? customHeader;

  /// 内容为空时显示的组件
  final Widget? emptyWidget;

  /// 初始选中的一级tab索引
  final int initialFirstIndex;

  /// 初始选中的二级tab索引
  final int initialSecondIndex;

  /// 文本缩放因子
  final double textScaleFactor;

  /// 宽度缩放因子
  final double widthScaleFactor;

  const MultiTabView2({
    super.key,
    required this.firstLevelTabs,
    required this.secondLevelTabs,
    required this.firstLevelTitleExtractor,
    required this.secondLevelTitleExtractor,
    required this.contentBuilder,
    required this.shouldShowSecondLevel,
    this.onFirstLevelSelected,
    this.onSecondLevelSelected,
    this.firstLevelStyle,
    this.secondLevelStyle,
    this.actions,
    this.customHeader,
    this.emptyWidget,
    this.initialFirstIndex = 0,
    this.initialSecondIndex = 0,
    this.textScaleFactor = 1.0,
    this.widthScaleFactor = 1.0,
  }) : assert(firstLevelTabs.length == secondLevelTabs.length);

  @override
  State<MultiTabView2<T, U>> createState() => _MultiTabView2State<T, U>();
}

class _MultiTabView2State<T, U> extends State<MultiTabView2<T, U>>
    with TickerProviderStateMixin {
  late TabController _firstLevelTabController;
  late List<TabController?> _secondLevelTabControllers;

  int _currentFirstIndex = 0;
  int _currentSecondIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentFirstIndex = widget.initialFirstIndex;
    _currentSecondIndex = widget.initialSecondIndex;

    _firstLevelTabController = TabController(
      vsync: this,
      length: widget.firstLevelTabs.length,
      initialIndex: _currentFirstIndex,
    );
    _firstLevelTabController.addListener(_onFirstLevelTabChanged);

    // 初始化每个一级tab的二级tab controller
    _secondLevelTabControllers =
        List.generate(widget.firstLevelTabs.length, (i) {
      return TabController(
        vsync: this,
        length: widget.secondLevelTabs[i].length,
        initialIndex: i == _currentFirstIndex ? _currentSecondIndex : 0,
      )..addListener(() => _onSecondLevelTabChanged(i));
    });
  }

  @override
  void dispose() {
    _firstLevelTabController.removeListener(_onFirstLevelTabChanged);
    _firstLevelTabController.dispose();
    for (final c in _secondLevelTabControllers) {
      c?.dispose();
    }
    super.dispose();
  }

  void _onFirstLevelTabChanged() {
    _mLog("_onFirstLevelTabChanged");
    if (!_firstLevelTabController.indexIsChanging) {
      final newFirstIndex = _firstLevelTabController.index;
      if (newFirstIndex != _currentFirstIndex) {
        // setState(() {
        _currentFirstIndex = newFirstIndex;
        _currentSecondIndex =
            _secondLevelTabControllers[_currentFirstIndex]?.index ?? 0;
        // });
        widget.onFirstLevelSelected?.call(
          _currentFirstIndex,
          widget.firstLevelTabs[_currentFirstIndex],
        );
      }
    }
  }

  void _onSecondLevelTabChanged(int firstTabIndex) {
    _mLog("_onSecondLevelTabChanged");
    final controller = _secondLevelTabControllers[firstTabIndex];
    if (controller != null &&
        !controller.indexIsChanging &&
        firstTabIndex == _currentFirstIndex) {
      final newSecondIndex = controller.index;
      if (newSecondIndex != _currentSecondIndex) {
        // setState(() {
        _currentSecondIndex = newSecondIndex;
        // });
        widget.onSecondLevelSelected?.call(
          _currentFirstIndex,
          _currentSecondIndex,
          widget.firstLevelTabs[_currentFirstIndex],
          widget.secondLevelTabs[_currentFirstIndex][_currentSecondIndex],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.customHeader != null) widget.customHeader!,
        _buildFirstLevelTabBar(),
        Expanded(
          child: _buildFirstContent(),
        ),
      ],
    );
  }

  Widget _buildFirstLevelTabBar() {
    final style = widget.firstLevelStyle ?? TabStyleConfig2.defaultFirstLevel();
    Widget current = TabBar(
      controller: _firstLevelTabController,
      isScrollable: style.isScrollable,
      labelStyle: style.labelStyle,
      unselectedLabelStyle: style.unselectedLabelStyle,
      indicator: style.indicator,
      padding: style.padding,
      labelPadding: style.labelPadding,
      tabAlignment: style.tabAlignment,
      automaticIndicatorColorAdjustment:
          style.automaticIndicatorColorAdjustment,
      dividerColor: style.dividerColor,
      indicatorSize: style.indicatorSize,
      tabs: List.generate(widget.firstLevelTabs.length, (index) {
        final tab = widget.firstLevelTabs[index];
        final title = widget.firstLevelTitleExtractor(tab);
        return Text(title);
      }),
    );

    var actions = widget.actions ?? [];
    if (actions.isNotEmpty) {
      current = Row(
        children: [
          Expanded(child: current),
          ...actions,
        ],
      );
    }

    current = SizedBox(
      height: 44 * widget.widthScaleFactor,
      child: current,
    );
    return current;
  }

  Widget _buildFirstContent() {
    return ExtendedTabBarView(
      controller: _firstLevelTabController,
      children: List.generate(widget.firstLevelTabs.length, (firstIndex) {
        final firstTab = widget.firstLevelTabs[firstIndex];
        final secondTabs = widget.secondLevelTabs[firstIndex];
        final secondController = _secondLevelTabControllers[firstIndex]!;
        if (secondTabs.length > 1 &&
            widget.shouldShowSecondLevel?.call(secondTabs) == true) {
          return Column(children: [
            _buildSecondLevelTabBar(firstIndex),
            Expanded(
              child: ExtendedTabBarView(
                controller: secondController,
                children: List.generate(secondTabs.length, (secondIndex) {
                  final secondTab = secondTabs[secondIndex];
                  return widget.contentBuilder(
                    firstIndex,
                    secondIndex,
                    firstTab,
                    secondTab,
                  );
                }),
              ),
            ),
          ]);
        } else if (secondTabs.length == 1) {
          return widget.contentBuilder(
            firstIndex,
            0,
            firstTab,
            secondTabs[0],
          );
        } else {
          return widget.emptyWidget ?? const SizedBox.shrink();
        }
      }),
    );
  }

  Widget _buildSecondLevelTabBar(int firstIndex) {
    final secondTabs = widget.secondLevelTabs[firstIndex];

    final style =
        widget.secondLevelStyle ?? TabStyleConfig2.defaultSecondLevel();
    final controller = _secondLevelTabControllers[firstIndex]!;

    return SizedBox(
      height: 40 * widget.widthScaleFactor,
      child: TabBar(
        controller: controller,
        tabAlignment: style.tabAlignment,
        isScrollable: style.isScrollable,
        labelStyle: style.labelStyle,
        unselectedLabelStyle: style.unselectedLabelStyle,
        indicator: style.indicator,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
        padding: style.padding,
        labelPadding: style.labelPadding,
        automaticIndicatorColorAdjustment:
            style.automaticIndicatorColorAdjustment,
        dividerColor: style.dividerColor,
        indicatorSize: style.indicatorSize,
        tabs: List.generate(secondTabs.length, (index) {
          final tab = secondTabs[index];
          final title = widget.secondLevelTitleExtractor(tab);
          Widget current = Text(title);
          // if (style.unselectedIndicator != null) {
          //   current = Container(
          //     decoration: style.unselectedIndicator,
          //     padding: style.labelPadding,
          //     child: Text(title),
          //   );
          // }
          return current;
        }),
      ),
    );
  }
}

/// Tab样式配置
class TabStyleConfig2 {
  final bool isScrollable;
  final TabAlignment tabAlignment;
  final TextStyle labelStyle;
  final TextStyle unselectedLabelStyle;
  final Decoration indicator;
  final Decoration? unselectedIndicator;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry labelPadding;
  final bool automaticIndicatorColorAdjustment;
  final Color dividerColor;
  final TabBarIndicatorSize indicatorSize;

  const TabStyleConfig2({
    this.isScrollable = true,
    this.tabAlignment = TabAlignment.start,
    required this.labelStyle,
    required this.unselectedLabelStyle,
    this.indicator = const BoxDecoration(),
    this.unselectedIndicator,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    this.dividerColor = Colors.transparent,
    this.automaticIndicatorColorAdjustment = false,
    this.indicatorSize = TabBarIndicatorSize.tab,
  });

  /// 默认一级tab样式
  factory TabStyleConfig2.defaultFirstLevel() {
    return TabStyleConfig2(
      labelStyle: TextStyle(
        fontSize: 14,
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        color: Colors.white38,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.only(left: 6, right: 6),
      labelPadding: EdgeInsets.only(right: 12, left: 12),
    );
  }

  /// 默认二级tab样式
  factory TabStyleConfig2.defaultSecondLevel() {
    return TabStyleConfig2(
      labelStyle: TextStyle(
        fontSize: 14,
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        color: Colors.white38,
        fontWeight: FontWeight.w500,
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: 5),
    );
  }
}
