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

  /// 在一级tab之前按行显示的小部件列表
  final List<Widget>? startActions;

  /// 在一级tab之后按行显示的小部件列表
  final List<Widget>? actions;

  /// 在二级tab之前按行显示的小部件列表
  final List<Widget>? secondStartActions;

  /// 在二级tab之后按行显示的小部件列表
  final List<Widget>? secondActions;

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

  /// 一级tab双击回调
  final Function(int firstIndex, T firstTab)? onFirstLevelDoubleTap;

  /// 二级tab双击回调
  final Function(int firstIndex, int secondIndex, T firstTab, U secondTab)?
      onSecondLevelDoubleTap;

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
    this.startActions,
    this.actions,
    this.secondStartActions,
    this.secondActions,
    this.customHeader,
    this.emptyWidget,
    this.initialFirstIndex = 0,
    this.initialSecondIndex = 0,
    this.textScaleFactor = 1.0,
    this.widthScaleFactor = 1.0,
    this.onFirstLevelDoubleTap,
    this.onSecondLevelDoubleTap,
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
      final secondLength = widget.secondLevelTabs[i].length;
      if (secondLength == 0) return null;
      final initialIndex = i == _currentFirstIndex
          ? _currentSecondIndex.clamp(0, secondLength - 1)
          : 0;
      return TabController(
        vsync: this,
        length: secondLength,
        initialIndex: initialIndex,
      )..addListener(() => _onSecondLevelTabChanged(i));
    });
  }

  @override
  void didUpdateWidget(covariant MultiTabView2<T, U> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldFirstLength = oldWidget.firstLevelTabs.length;
    final newFirstLength = widget.firstLevelTabs.length;

    // 检查一级 tabs 是否改变
    if (oldFirstLength != newFirstLength) {
      // 销毁旧的一级 controller
      _firstLevelTabController.removeListener(_onFirstLevelTabChanged);
      _firstLevelTabController.dispose();

      // 销毁所有旧的二级 controllers
      for (final c in _secondLevelTabControllers) {
        c?.dispose();
      }

      // 确保当前索引在有效范围内
      _currentFirstIndex = _currentFirstIndex.clamp(0, newFirstLength - 1);
      if (newFirstLength == 0) {
        _currentFirstIndex = 0;
      }

      // 创建新的一级 controller
      _firstLevelTabController = TabController(
        vsync: this,
        length: newFirstLength,
        initialIndex: newFirstLength > 0 ? _currentFirstIndex : 0,
      );
      _firstLevelTabController.addListener(_onFirstLevelTabChanged);

      // 创建新的二级 controllers
      _secondLevelTabControllers = List.generate(newFirstLength, (i) {
        final secondLength = widget.secondLevelTabs[i].length;
        if (secondLength == 0) return null;
        return TabController(
          vsync: this,
          length: secondLength,
          initialIndex: 0,
        )..addListener(() => _onSecondLevelTabChanged(i));
      });

      // 更新二级索引
      if (newFirstLength > 0 &&
          _currentFirstIndex < _secondLevelTabControllers.length) {
        _currentSecondIndex =
            _secondLevelTabControllers[_currentFirstIndex]?.index ?? 0;
      } else {
        _currentSecondIndex = 0;
      }
    } else {
      // 一级 tabs 长度相同，检查每个二级 tabs 是否改变
      bool needRebuildSecond = false;
      for (int i = 0; i < newFirstLength; i++) {
        final oldSecondLength = oldWidget.secondLevelTabs[i].length;
        final newSecondLength = widget.secondLevelTabs[i].length;
        if (oldSecondLength != newSecondLength) {
          needRebuildSecond = true;
          break;
        }
      }

      if (needRebuildSecond) {
        // 销毁所有旧的二级 controllers
        for (final c in _secondLevelTabControllers) {
          c?.dispose();
        }

        // 创建新的二级 controllers
        _secondLevelTabControllers = List.generate(newFirstLength, (i) {
          final secondLength = widget.secondLevelTabs[i].length;
          if (secondLength == 0) return null;

          // 保留当前一级 tab 的二级索引（如果有效）
          int initialIndex = 0;
          if (i == _currentFirstIndex) {
            initialIndex = _currentSecondIndex.clamp(0, secondLength - 1);
          }

          return TabController(
            vsync: this,
            length: secondLength,
            initialIndex: initialIndex,
          )..addListener(() => _onSecondLevelTabChanged(i));
        });

        // 更新二级索引
        if (_currentFirstIndex < _secondLevelTabControllers.length) {
          final controller = _secondLevelTabControllers[_currentFirstIndex];
          _currentSecondIndex = controller?.index ?? 0;
        }
      }
    }
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
        Widget current = Text(title);
        if (widget.onFirstLevelDoubleTap != null) {
          current = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              widget.onFirstLevelDoubleTap?.call(index, tab);
            },
            child: current,
          );
        }
        return current;
      }),
    );

    // 处理左侧操作按钮
    var startActions = widget.startActions ?? [];
    // 处理右侧操作按钮
    var actions = widget.actions ?? [];

    if (startActions.isNotEmpty || actions.isNotEmpty) {
      List<Widget> rowChildren = [];

      // 添加左侧操作按钮
      if (startActions.isNotEmpty) {
        rowChildren.addAll(startActions);
      }

      // 添加TabBar（自动扩展）
      rowChildren.add(Expanded(child: current));

      // 添加右侧操作按钮
      if (actions.isNotEmpty) {
        rowChildren.addAll(actions);
      }

      current = Row(
        children: rowChildren,
      );
    }

    current = SizedBox(
      height: style.height * widget.widthScaleFactor,
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
        final secondController = _secondLevelTabControllers[firstIndex];

        // 需要二级 controller 且存在多个二级 tabs
        if (secondController != null &&
            secondTabs.length > 1 &&
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
        } else if (secondTabs.isNotEmpty) {
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
    final controller = _secondLevelTabControllers[firstIndex];
    if (controller == null) {
      return const SizedBox.shrink();
    }

    Widget current = TabBar(
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
        if (widget.onSecondLevelDoubleTap != null) {
          current = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              widget.onSecondLevelDoubleTap?.call(
                  firstIndex, index, widget.firstLevelTabs[firstIndex], tab);
            },
            child: current,
          );
        }
        return current;
      }),
    );

    // 处理左侧操作按钮
    var startActions = widget.secondStartActions ?? [];
    // 处理右侧操作按钮
    var actions = widget.secondActions ?? [];

    if (startActions.isNotEmpty || actions.isNotEmpty) {
      List<Widget> rowChildren = [];

      // 添加左侧操作按钮
      if (startActions.isNotEmpty) {
        rowChildren.addAll(startActions);
      }

      // 添加TabBar（自动扩展）
      rowChildren.add(Expanded(child: current));

      // 添加右侧操作按钮
      if (actions.isNotEmpty) {
        rowChildren.addAll(actions);
      }

      current = Row(
        children: rowChildren,
      );
    }

    current = SizedBox(
      height: style.height * widget.widthScaleFactor,
      child: current,
    );
    return current;
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
  final int height;

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
    this.height = 44,
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
      height: 44,
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
      height: 40,
    );
  }
}
