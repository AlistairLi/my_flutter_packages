import 'dart:async';

import 'package:flutter/material.dart';

/// 防抖动点击 Widget
///
/// 一个用于防止用户快速重复点击的 Flutter Widget。
/// 它可以在指定时间内只允许一次点击事件，有效防止误操作和重复提交。
///
/// 功能特性
/// - 可配置的防抖动时间间隔
/// - 支持启用/禁用防抖动功能
/// - 内置视觉反馈效果
/// - 支持自定义反馈颜色和透明度
/// - 支持包装任何子组件
///
/// 使用场景
/// 1. **表单提交** - 防止用户重复提交表单
/// 2. **网络请求** - 防止重复发送 API 请求
/// 3. **页面跳转** - 防止快速重复点击导致多次跳转
/// 4. **点赞/收藏** - 防止用户快速重复操作
/// 5. **支付操作** - 防止重复支付
///
/// 注意事项
/// 1. 防抖动时间不宜设置过短（建议至少 300ms）
/// 2. 对于重要的操作，建议结合服务器端验证
/// 3. 视觉反馈可以帮助用户理解操作已被接收
/// 4. 在列表项中使用时，注意状态管理
class DebouncedTapWidget extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 点击回调函数
  final VoidCallback? onTap;

  /// 防抖动时间间隔（毫秒），默认 500ms
  final int debounceDuration;

  /// 是否启用防抖动，默认 true
  final bool enabled;

  /// 点击时的视觉反馈
  final bool enableFeedback;

  /// 点击时的颜色变化
  final Color? feedbackColor;

  /// 点击时的透明度变化
  final double? feedbackOpacity;

  final HitTestBehavior behavior;

  const DebouncedTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.debounceDuration = 500,
    this.enabled = true,
    this.enableFeedback = false,
    this.feedbackColor,
    this.feedbackOpacity,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<DebouncedTapWidget> createState() => _DebouncedTapWidgetState();
}

class _DebouncedTapWidgetState extends State<DebouncedTapWidget>
    with SingleTickerProviderStateMixin {
  Timer? _debounceTimer;
  bool _isDebouncing = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.feedbackOpacity ?? 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 添加动画状态监听器，动画完成后自动反向
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || _isDebouncing) {
      return;
    }

    // 开始防抖动
    _isDebouncing = true;

    // 执行点击回调
    widget.onTap?.call();

    // 视觉反馈
    if (widget.enableFeedback) {
      _animationController.forward();
    }

    // 设置防抖动定时器
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceDuration), () {
      if (mounted) {
        setState(() {
          _isDebouncing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: widget.behavior,
      child: widget.enableFeedback
          ? AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                Widget feedbackWidget = Opacity(
                  opacity: _opacityAnimation.value,
                  child: widget.child,
                );

                if (widget.feedbackColor != null) {
                  feedbackWidget = ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      widget.feedbackColor!,
                      BlendMode.srcATop,
                    ),
                    child: feedbackWidget,
                  );
                }

                return feedbackWidget;
              },
            )
          : widget.child,
    );
  }
}
