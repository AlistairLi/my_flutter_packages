import 'dart:ui';

import 'package:flutter/material.dart';

/// 图片对比滑块组件
///
/// 用于展示处理前后的图片对比效果，用户可以通过拖拽滑块来查看不同区域的对比效果。
///
/// 使用示例：
/// ```dart
/// ImageComparisonSlider(
///   beforeWidget: Image.asset('before.jpg'),
///   afterWidget: Image.asset('after.jpg'),
///   onPositionChanged: (position) => print('滑块位置: $position'),
///   scaleFactor: 1.0, // 适配比例
/// )
/// ```
///
/// 注意事项：
/// - 使用时注意处理与手机的滑动返回手势冲突，需要拦截滑动返回手势
/// - 建议在父组件中处理手势冲突，避免影响用户体验
/// - 在Android平台上，启用手势排除区域检测可以避免滑块拖拽与系统返回手势冲突
class ImageComparisonSlider extends StatefulWidget {
  /// 处理前的图片Widget
  final Widget beforeWidget;

  /// 处理后的图片Widget
  final Widget afterWidget;

  /// 组件宽度，为null时自适应父容器宽度
  final double? width;

  /// 组件高度，为null时自适应父容器高度
  final double? height;

  /// 圆角半径，为null时不显示圆角
  final double? borderRadius;

  /// 滑块手柄的宽度
  final double sliderHandleWidth;

  /// 初始滑块位置 (0.0 - 1.0)，0.0表示最左侧，1.0表示最右侧
  final double initialPosition;

  /// 滑块手柄的自定义图标资源路径
  final String? handleIcon;

  /// 滑块位置变化回调函数
  ///
  /// 参数 position: 当前滑块位置，范围 0.0 - 1.0
  final ValueChanged<double>? onPositionChanged;

  /// 是否显示"处理前"/"处理后"标签
  final bool showLabels;

  /// 处理前标签文本
  final String beforeLabel;

  /// 处理后标签文本
  final String afterLabel;

  /// 是否使用毛玻璃效果作为标签背景
  final bool labelBackgroundBlur;

  /// 是否启用测试模式（为相同图片添加模糊效果用于测试）
  final bool test;

  /// 适配比例
  final double scaleFactor;

  /// 是否启用Android手势排除区域检测
  ///
  /// 当启用时，滑块在Android平台上会受到系统手势排除区域的限制，
  /// 避免与系统返回手势冲突。在iOS和其他平台上此属性无效。
  final bool enableGestureExclusion;

  const ImageComparisonSlider({
    super.key,
    required this.beforeWidget,
    required this.afterWidget,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.sliderHandleWidth = 50,
    this.initialPosition = 0.5,
    this.onPositionChanged,
    this.showLabels = true,
    this.beforeLabel = "处理前",
    this.afterLabel = "处理后",
    this.labelBackgroundBlur = true,
    this.test = false,
    this.handleIcon,
    this.scaleFactor = 1.0,
    this.enableGestureExclusion = false,
  });

  @override
  State<ImageComparisonSlider> createState() => _ImageComparisonSliderState();
}

class _ImageComparisonSliderState extends State<ImageComparisonSlider> {
  /// 当前滑块位置 (0.0 - 1.0)
  late double _sliderPosition;

  /// 容器宽度
  late double _containerWidth;

  /// 容器高度
  late double _containerHeight;

  /// 容器GlobalKey，用于坐标转换
  final GlobalKey _containerKey = GlobalKey();

  /// 左侧手势排除区域宽度（像素）
  double _leftGestureExclusionWidth = 0.0;

  /// 右侧手势排除区域宽度（像素）
  double _rightGestureExclusionWidth = 0.0;

  /// 是否已初始化手势排除区域
  bool _gestureExclusionInitialized = false;

  @override
  void initState() {
    super.initState();
    _sliderPosition = widget.initialPosition.clamp(0.0, 1.0);

    // 初始化手势排除区域检测
    if (widget.enableGestureExclusion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeGestureExclusion();
      });
    }
  }

  /// 初始化手势排除区域检测
  void _initializeGestureExclusion() {
    if (!widget.enableGestureExclusion || _gestureExclusionInitialized) {
      return;
    }

    try {
      final FlutterView? view =
          WidgetsBinding.instance.platformDispatcher.implicitView;
      final ViewPadding? systemGestureInsets = view?.systemGestureInsets;

      setState(() {
        _leftGestureExclusionWidth =
            _pxToDp(context, systemGestureInsets?.left ?? 0) *
                widget.scaleFactor;
        _rightGestureExclusionWidth =
            _pxToDp(context, systemGestureInsets?.right ?? 0) *
                widget.scaleFactor;
        _gestureExclusionInitialized = true;
      });

      // 如果当前滑块位置在排除区域内，调整到安全位置
      _adjustSliderPositionIfNeeded();
    } catch (e) {
      // 如果获取失败，使用默认值
      setState(() {
        _leftGestureExclusionWidth = 0.0;
        _rightGestureExclusionWidth = 0.0;
        _gestureExclusionInitialized = true;
      });
    }
  }

  /// 如果需要，调整滑块位置到安全区域
  void _adjustSliderPositionIfNeeded() {
    if (!_gestureExclusionInitialized || _containerWidth <= 0) {
      return;
    }

    final leftExclusionRatio = _leftGestureExclusionWidth / _containerWidth;
    final rightExclusionRatio = _rightGestureExclusionWidth / _containerWidth;

    double newPosition = _sliderPosition;
    bool needsUpdate = false;

    // 检查左侧边界
    if (_sliderPosition < leftExclusionRatio) {
      newPosition = leftExclusionRatio;
      needsUpdate = true;
    }

    // 检查右侧边界
    if (_sliderPosition > (1.0 - rightExclusionRatio)) {
      newPosition = 1.0 - rightExclusionRatio;
      needsUpdate = true;
    }

    if (needsUpdate) {
      setState(() {
        _sliderPosition = newPosition;
      });
      widget.onPositionChanged?.call(_sliderPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _updateContainerDimensions(constraints);

        Widget current = _buildMainStack();

        // 应用圆角
        if (widget.borderRadius != null) {
          current = ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius!),
            child: current,
          );
        }

        // 包装为固定尺寸容器
        current = SizedBox(
          key: _containerKey,
          width: _containerWidth,
          height: _containerHeight,
          child: current,
        );

        return current;
      },
    );
  }

  /// 更新容器尺寸
  void _updateContainerDimensions(BoxConstraints constraints) {
    _containerWidth = _getValidDimension(widget.width, constraints.maxWidth);
    _containerHeight = _getValidDimension(widget.height, constraints.maxHeight);
  }

  /// 获取有效的尺寸值
  double _getValidDimension(double? dimension, double maxDimension) {
    if (dimension == null ||
        dimension == double.infinity ||
        dimension == double.negativeInfinity) {
      return maxDimension;
    }
    return dimension;
  }

  /// 构建主要的Stack布局
  Widget _buildMainStack() {
    return Stack(
      children: [
        // 处理前的图片（底层）
        _buildBeforeWidget(),

        // 处理前的标签
        if (widget.showLabels) ...[
          _buildLabel(widget.beforeLabel, Alignment.topRight),
        ],

        // 处理后的图片（带裁剪效果）
        _buildAfterWidget(),

        // 滑块手柄
        _buildSliderHandle(),
      ],
    );
  }

  /// 构建处理前的图片Widget
  Widget _buildBeforeWidget() {
    Widget current = widget.beforeWidget;

    // 测试模式：为相同图片添加模糊效果
    if (widget.test) {
      current = Stack(
        children: [
          Positioned.fill(child: current),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.white38,
            ),
          ),
        ],
      );
    }

    return Positioned.fill(child: current);
  }

  /// 构建处理后的图片Widget（带裁剪效果）
  Widget _buildAfterWidget() {
    Widget current = widget.afterWidget;

    // 设置尺寸
    current = SizedBox(
      width: _containerWidth,
      height: _containerHeight,
      child: current,
    );

    // 添加标签
    if (widget.showLabels) {
      current = Stack(
        children: [
          current,
          _buildLabel(widget.afterLabel, Alignment.topLeft),
        ],
      );
    }

    // 应用裁剪效果
    current = ClipRect(
      child: Align(
        widthFactor: _sliderPosition,
        heightFactor: 1,
        alignment: AlignmentDirectional.centerStart,
        child: current,
      ),
    );

    return current;
  }

  /// 构建滑块手柄
  Widget _buildSliderHandle() {
    final handleWidth = widget.sliderHandleWidth;
    final halfWidth = handleWidth / 2;
    final centerY = _containerHeight * 0.5;

    return PositionedDirectional(
      start: _containerWidth * _sliderPosition - halfWidth,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onPanUpdate: (details) {
          _updatePositionFromGlobal(details.globalPosition.dx);
        },
        onPanStart: (details) {
          _updatePositionFromGlobal(details.globalPosition.dx);
        },
        child: Container(
          color: Colors.transparent,
          width: handleWidth,
          height: _containerHeight,
          child: Stack(
            children: [
              // 垂直分割线
              _buildVerticalDivider(halfWidth),

              // 自定义图标或默认手柄
              if (widget.handleIcon != null)
                _buildCustomHandleIcon(handleWidth, centerY, halfWidth)
              else
                _buildDefaultHandle(handleWidth, centerY, halfWidth),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建垂直分割线
  Widget _buildVerticalDivider(double halfWidth) {
    return PositionedDirectional(
      end: halfWidth,
      top: 0,
      bottom: 0,
      child: Container(
        width: 1.5 * widget.scaleFactor,
        decoration: BoxDecoration(
          color: Colors.white70,
          boxShadow: [
            BoxShadow(
              color: Colors.white,
              blurStyle: BlurStyle.normal,
              offset: Offset(-1.5 * widget.scaleFactor, 0),
              blurRadius: 6 * widget.scaleFactor,
              spreadRadius: -2 * widget.scaleFactor,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建自定义手柄图标
  Widget _buildCustomHandleIcon(
      double handleWidth, double centerY, double halfWidth) {
    return PositionedDirectional(
      start: 0,
      top: centerY - halfWidth,
      child: Image.asset(
        widget.handleIcon!,
        width: handleWidth,
        height: handleWidth,
      ),
    );
  }

  /// 构建默认手柄样式
  Widget _buildDefaultHandle(
      double handleWidth, double centerY, double halfWidth) {
    final handleSize = 20 * widget.scaleFactor;
    final handleOffset = 10 * widget.scaleFactor;
    final dotSize = 4 * widget.scaleFactor;
    final borderRadius = 4 * widget.scaleFactor;

    return Stack(
      children: [
        // 水平线
        PositionedDirectional(
          start: halfWidth,
          top: centerY,
          child: Container(
            width: halfWidth,
            height: 1 * widget.scaleFactor,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white,
                  width: 1 * widget.scaleFactor,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        ),

        // 手柄框
        PositionedDirectional(
          start: 0,
          top: centerY - handleOffset,
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1 * widget.scaleFactor,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Center(
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(dotSize / 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建标签
  Widget _buildLabel(String text, Alignment alignment) {
    final radius = 20 * widget.scaleFactor;
    final backgroundColor = Colors.black.withValues(alpha: 0.3);
    final padding = EdgeInsets.symmetric(
        horizontal: 10 * widget.scaleFactor, vertical: 5 * widget.scaleFactor);
    final fontSize = 12 * widget.scaleFactor;
    final margin = 16 * widget.scaleFactor;

    Widget labelWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );

    // 应用毛玻璃效果
    if (widget.labelBackgroundBlur) {
      labelWidget = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 3 * widget.scaleFactor, sigmaY: 3 * widget.scaleFactor),
          child: labelWidget,
        ),
      );
    }

    return PositionedDirectional(
      top: margin,
      start: alignment == Alignment.topLeft ? margin : null,
      end: alignment == Alignment.topRight ? margin : null,
      child: labelWidget,
    );
  }

  /// 更新滑块位置
  void _updateSliderPosition(double localX) {
    double newPosition = (localX / _containerWidth).clamp(0.0, 1.0);

    // 如果启用了手势排除区域检测，应用边界限制
    if (widget.enableGestureExclusion && _gestureExclusionInitialized) {
      final leftExclusionRatio = _leftGestureExclusionWidth / _containerWidth;
      final rightExclusionRatio = _rightGestureExclusionWidth / _containerWidth;

      // 限制在安全区域内
      newPosition =
          newPosition.clamp(leftExclusionRatio, 1.0 - rightExclusionRatio);
    }

    setState(() {
      _sliderPosition = newPosition;
    });

    widget.onPositionChanged?.call(_sliderPosition);
  }

  /// 从全局坐标更新滑块位置
  void _updatePositionFromGlobal(double globalX) {
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(Offset(globalX, 0));
      _updateSliderPosition(localPosition.dx);
    }
  }

  /// 获取当前手势排除区域信息（用于调试）
  Map<String, dynamic> getGestureExclusionInfo() {
    return {
      'enabled': widget.enableGestureExclusion,
      'initialized': _gestureExclusionInitialized,
      'leftExclusionWidth': _leftGestureExclusionWidth,
      'rightExclusionWidth': _rightGestureExclusionWidth,
      'containerWidth': _containerWidth,
      'leftExclusionRatio': _containerWidth > 0
          ? _leftGestureExclusionWidth / _containerWidth
          : 0.0,
      'rightExclusionRatio': _containerWidth > 0
          ? _rightGestureExclusionWidth / _containerWidth
          : 0.0,
    };
  }

  double _pxToDp(BuildContext context, double px) {
    var ratio = MediaQuery.of(context).devicePixelRatio;
    return px / ratio;
  }
}
