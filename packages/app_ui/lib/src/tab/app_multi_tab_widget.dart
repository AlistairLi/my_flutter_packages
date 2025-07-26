import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';

/// 通用二级Tab组件
/// T: 一级tab数据模型类型
/// U: 二级tab数据模型类型
class MultiTabView<T, U> extends StatefulWidget {
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
  final TabStyleConfig? firstLevelStyle;

  /// 二级tab样式配置
  final TabStyleConfig? secondLevelStyle;

  /// 是否显示二级tab
  final bool Function(List<U> secondTabs)? shouldShowSecondLevel;

  /// 自定义头部组件
  final Widget? customHeader;

  /// 初始选中的一级tab索引
  final int initialFirstIndex;

  /// 初始选中的二级tab索引
  final int initialSecondIndex;

  /// 文本缩放因子
  final double textScaleFactor;

  /// 宽度缩放因子
  final double widthScaleFactor;

  const MultiTabView({
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
    this.customHeader,
    this.initialFirstIndex = 0,
    this.initialSecondIndex = 0,
    this.textScaleFactor = 1.0,
    this.widthScaleFactor = 1.0,
  }) : assert(firstLevelTabs.length == secondLevelTabs.length);

  @override
  State<MultiTabView<T, U>> createState() => _MultiTabViewState<T, U>();
}

class _MultiTabViewState<T, U> extends State<MultiTabView<T, U>>
    with TickerProviderStateMixin {
  late TabController _firstLevelTabController;
  late TabController _secondLevelTabController;

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

    _secondLevelTabController = TabController(
      vsync: this,
      length: widget.secondLevelTabs[_currentFirstIndex].length,
      initialIndex: _currentSecondIndex,
    );

    _firstLevelTabController.addListener(_onFirstLevelTabChanged);
    _secondLevelTabController.addListener(_onSecondLevelTabChanged);
  }

  @override
  void dispose() {
    _firstLevelTabController.removeListener(_onFirstLevelTabChanged);
    _secondLevelTabController.removeListener(_onSecondLevelTabChanged);
    _firstLevelTabController.dispose();
    _secondLevelTabController.dispose();
    super.dispose();
  }

  void _onFirstLevelTabChanged() {
    if (_firstLevelTabController.indexIsChanging) {
      final newFirstIndex = _firstLevelTabController.index;
      if (newFirstIndex != _currentFirstIndex) {
        _currentFirstIndex = newFirstIndex;
        _currentSecondIndex = 0;

        // 更新二级tab控制器
        _secondLevelTabController.dispose();
        _secondLevelTabController = TabController(
          vsync: this,
          length: widget.secondLevelTabs[_currentFirstIndex].length,
          initialIndex: 0,
        );
        _secondLevelTabController.addListener(_onSecondLevelTabChanged);

        // 触发回调
        widget.onFirstLevelSelected?.call(
          _currentFirstIndex,
          widget.firstLevelTabs[_currentFirstIndex],
        );

        setState(() {});
      }
    }
  }

  void _onSecondLevelTabChanged() {
    if (_secondLevelTabController.indexIsChanging) {
      final newSecondIndex = _secondLevelTabController.index;
      if (newSecondIndex != _currentSecondIndex) {
        _currentSecondIndex = newSecondIndex;

        // 触发回调
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
        // 自定义头部
        if (widget.customHeader != null) widget.customHeader!,

        // 一级tab
        _buildFirstLevelTabBar(),

        // 二级tab
        _buildSecondLevelTabBar(),

        // 内容区域
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildFirstLevelTabBar() {
    final style = widget.firstLevelStyle ?? TabStyleConfig.defaultFirstLevel();
    return Container(
      alignment: AlignmentDirectional.centerStart,
      height: 44 * widget.widthScaleFactor,
      child: TabBar(
        controller: _firstLevelTabController,
        isScrollable: style.isScrollable,
        padding: style.padding,
        labelPadding: style.labelPadding,
        indicatorColor: style.indicatorColor,
        tabAlignment: style.tabAlignment,
        automaticIndicatorColorAdjustment:
            style.automaticIndicatorColorAdjustment,
        dividerColor: style.dividerColor,
        indicatorSize: style.indicatorSize,
        tabs: List.generate(widget.firstLevelTabs.length, (index) {
          final isSelected = index == _currentFirstIndex;
          final tab = widget.firstLevelTabs[index];
          final title = widget.firstLevelTitleExtractor(tab);

          return Container(
            alignment: AlignmentDirectional.center,
            height: double.maxFinite,
            child: SizedBox(
              height: 44 * widget.widthScaleFactor,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? style.selectedTextColor
                            : style.unselectedTextColor,
                        fontSize: isSelected
                            ? style.selectedFontSize
                            : style.unselectedFontSize,
                        fontWeight: isSelected
                            ? style.selectedFontWeight
                            : style.unselectedFontWeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSecondLevelTabBar() {
    final secondTabs = widget.secondLevelTabs[_currentFirstIndex];
    final shouldShow = widget.shouldShowSecondLevel?.call(secondTabs) ??
        (secondTabs.isNotEmpty &&
            !(secondTabs.length == 1 &&
                widget.secondLevelTitleExtractor(secondTabs[0]) == "All"));

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final style =
        widget.secondLevelStyle ?? TabStyleConfig.defaultSecondLevel();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2 * widget.widthScaleFactor,
      ),
      margin: EdgeInsetsDirectional.only(
        start: 18 * widget.widthScaleFactor,
        end: 18 * widget.widthScaleFactor,
        top: 7 * widget.widthScaleFactor,
      ),
      height: 30 * widget.widthScaleFactor,
      child: TabBar(
        controller: _secondLevelTabController,
        isScrollable: style.isScrollable,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
        tabAlignment: style.tabAlignment,
        labelPadding: style.labelPadding,
        indicatorColor: style.indicatorColor,
        automaticIndicatorColorAdjustment:
            style.automaticIndicatorColorAdjustment,
        dividerColor: style.dividerColor,
        indicatorSize: style.indicatorSize,
        tabs: List.generate(secondTabs.length, (index) {
          final isSelected = index == _currentSecondIndex;
          final tab = secondTabs[index];
          final title = widget.secondLevelTitleExtractor(tab);

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * widget.widthScaleFactor,
              vertical: 2 * widget.widthScaleFactor,
            ),
            alignment: AlignmentDirectional.center,
            height: double.maxFinite,
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(
                      color: Colors.white,
                      width: 1 * widget.widthScaleFactor,
                    )
                  : null,
              borderRadius: BorderRadius.circular(26 * widget.widthScaleFactor),
              gradient: isSelected
                  ? LinearGradient(colors: [
                      Color(0xFF35DBFF),
                      Color(0xFF35DBFF),
                    ])
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        offset: const Offset(-2, 4),
                        color: const Color(0xFF35DBFF).withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? style.selectedTextColor
                    : style.unselectedTextColor,
                fontSize: isSelected
                    ? style.selectedFontSize
                    : style.unselectedFontSize,
                fontWeight: isSelected
                    ? style.selectedFontWeight
                    : style.unselectedFontWeight,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    return ExtendedTabBarView(
      controller: _firstLevelTabController,
      children: List.generate(widget.firstLevelTabs.length, (firstIndex) {
        final firstTab = widget.firstLevelTabs[firstIndex];
        final secondTabs = widget.secondLevelTabs[firstIndex];

        return ExtendedTabBarView(
          controller: _secondLevelTabController,
          children: List.generate(secondTabs.length, (secondIndex) {
            final secondTab = secondTabs[secondIndex];
            return widget.contentBuilder(
                firstIndex, secondIndex, firstTab, secondTab);
          }),
        );
      }),
    );
  }
}

/// Tab样式配置
class TabStyleConfig {
  final bool isScrollable;
  final EdgeInsets padding;
  final EdgeInsets labelPadding;
  final Color indicatorColor;
  final TabAlignment tabAlignment;
  final bool automaticIndicatorColorAdjustment;
  final Color dividerColor;
  final TabBarIndicatorSize indicatorSize;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final FontWeight selectedFontWeight;
  final FontWeight unselectedFontWeight;
  final double selectedFontSize;
  final double unselectedFontSize;

  const TabStyleConfig({
    this.isScrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
    this.labelPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.indicatorColor = Colors.transparent,
    this.tabAlignment = TabAlignment.start,
    this.automaticIndicatorColorAdjustment = false,
    this.dividerColor = Colors.transparent,
    this.indicatorSize = TabBarIndicatorSize.tab,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.selectedFontWeight,
    required this.unselectedFontWeight,
    required this.selectedFontSize,
    required this.unselectedFontSize,
  });

  /// 默认一级tab样式
  factory TabStyleConfig.defaultFirstLevel() {
    return TabStyleConfig(
      padding: EdgeInsets.only(left: 6, right: 6),
      labelPadding: EdgeInsets.only(right: 12, left: 12),
      selectedTextColor: const Color(0xFF202020),
      unselectedTextColor: const Color(0x80000000),
      selectedFontWeight: FontWeight.bold,
      unselectedFontWeight: FontWeight.w500,
      selectedFontSize: 18,
      unselectedFontSize: 14,
    );
  }

  /// 默认二级tab样式
  factory TabStyleConfig.defaultSecondLevel() {
    return TabStyleConfig(
      labelPadding: EdgeInsets.symmetric(horizontal: 5),
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black38,
      selectedFontWeight: FontWeight.bold,
      unselectedFontWeight: FontWeight.w500,
      selectedFontSize: 14,
      unselectedFontSize: 12,
    );
  }
}
