import 'package:flutter/material.dart';

/// 复杂动画组件
///
/// 这个组件实现了一个复杂的动画序列：
/// 1. 从指定位置开始逐渐放大到正常大小
/// 2. 以中心为轴心左右晃动指定次数
/// 3. 轻微晃动指定次数
/// 4. 隐藏后重新开始循环
///
/// 特性：
/// - 支持从指定位置开始放大
/// - 普通晃动和轻微晃动之间有自然过渡
/// - 可选择跳过隐藏动画直接开始新一轮
class ComplexAnimatedWidget extends StatefulWidget {
  /// 需要添加动画效果的子组件
  final Widget child;

  /// 动画循环的间隔时间（每次动画序列完成后等待的时间）
  final Duration intervalDuration;

  /// 从无到有放大的动画持续时间
  final Duration scaleInDuration;

  /// 放大动画的起始位置对齐方式
  /// 默认为左下角 (Alignment.bottomLeft)
  final AlignmentGeometry scaleStartAlignment;

  /// 左右晃动的次数
  final int swingCount;

  /// 左右晃动的角度（弧度）
  final double swingAngle;

  /// 左右晃动的动画持续时间
  final Duration swingDuration;

  /// 轻微晃动的次数
  final int gentleSwingCount;

  /// 轻微晃动的角度（弧度）
  final double gentleSwingAngle;

  /// 轻微晃动的动画持续时间
  final Duration gentleSwingDuration;

  /// 隐藏动画的持续时间
  final Duration hideDuration;

  /// 是否跳过隐藏动画，直接开始新一轮动画
  final bool skipHideAnimation;

  const ComplexAnimatedWidget({
    super.key,
    required this.child,
    this.intervalDuration = const Duration(milliseconds: 0),
    this.scaleInDuration = const Duration(milliseconds: 800),
    this.scaleStartAlignment = AlignmentDirectional.bottomStart,
    this.swingCount = 2,
    this.swingAngle = 0.06,
    this.swingDuration = const Duration(milliseconds: 200),
    this.gentleSwingCount = 1,
    this.gentleSwingAngle = 0.02,
    this.gentleSwingDuration = const Duration(milliseconds: 150),
    this.hideDuration = const Duration(milliseconds: 200),
    this.skipHideAnimation = true,
  });

  @override
  State<ComplexAnimatedWidget> createState() => _ComplexAnimatedWidgetState();
}

class _ComplexAnimatedWidgetState extends State<ComplexAnimatedWidget>
    with TickerProviderStateMixin {
  /// 缩放动画控制器
  late AnimationController _scaleController;

  /// 旋转动画控制器
  late AnimationController _rotationController;

  /// 旋转过渡动画控制器
  late AnimationController _rotationTransitionController;

  /// 轻微旋转动画控制器
  late AnimationController _gentleRotationController;

  /// 轻微旋转过渡动画控制器
  late AnimationController _gentleRotationTransitionController;

  /// 透明度动画控制器
  late AnimationController _opacityController;

  /// 缩放动画
  late Animation<double> _scaleAnimation;

  /// 普通晃动旋转动画
  late Animation<double> _swingRotationAnimation;

  /// 普通过渡晃动旋转动画
  late Animation<double> _swingRotationTransitionAnimation;

  /// 轻微晃动旋转动画
  late Animation<double> _gentleSwingRotationAnimation;

  /// 轻微过渡晃动旋转动画
  late Animation<double> _gentleSwingRotationTransitionAnimation;

  /// 透明度动画
  late Animation<double> _opacityAnimation;

  /// 当前动画阶段
  AnimationStage _currentStage = AnimationStage.scaleIn;

  /// 当前晃动次数
  int _currentSwingCount = 0;

  /// 当前轻微晃动次数
  int _currentGentleSwingCount = 0;

  /// 是否跳过隐藏动画
  bool _skipHideAnimation = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _scaleController = AnimationController(
      duration: widget.scaleInDuration,
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: widget.swingDuration,
      vsync: this,
    );

    _rotationTransitionController = AnimationController(
      duration: scaleDuration(widget.swingDuration, 0.5),
      vsync: this,
    );

    _gentleRotationController = AnimationController(
      duration: widget.gentleSwingDuration,
      vsync: this,
    );

    _gentleRotationTransitionController = AnimationController(
      duration: scaleDuration(widget.gentleSwingDuration, 0.5),
      vsync: this,
    );

    _opacityController = AnimationController(
      duration: widget.hideDuration,
      vsync: this,
    );

    // 创建缩放动画：从0到1
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack, // 使用弹性曲线
    ));

    // 创建普通晃动旋转动画
    _swingRotationAnimation = Tween<double>(
      begin: widget.swingAngle,
      end: -widget.swingAngle,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // 创建普通晃动旋转过渡动画
    _swingRotationTransitionAnimation = Tween<double>(
      begin: 0,
      end: widget.swingAngle,
    ).animate(CurvedAnimation(
      parent: _rotationTransitionController,
      curve: Curves.easeInOut,
    ));

    // 创建轻微晃动旋转动画
    _gentleSwingRotationAnimation = Tween<double>(
      begin: widget.gentleSwingAngle,
      end: -widget.gentleSwingAngle,
    ).animate(CurvedAnimation(
      parent: _gentleRotationController,
      curve: Curves.easeInOut,
    ));

    // 创建过渡轻微晃动旋转动画
    _gentleSwingRotationTransitionAnimation = Tween<double>(
      begin: 0,
      end: widget.gentleSwingAngle,
    ).animate(CurvedAnimation(
      parent: _gentleRotationTransitionController,
      curve: Curves.easeInOut,
    ));

    // 创建透明度动画：从1到0
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeIn,
    ));

    // 设置跳过隐藏动画标志
    _skipHideAnimation = widget.skipHideAnimation;

    // 启动动画循环
    _startAnimation();
  }

  /// 启动动画循环
  void _startAnimation() {
    Future.delayed(widget.intervalDuration, () {
      if (mounted) {
        _performScaleInAnimation();
      }
    });
  }

  /// 执行从无到有的放大动画
  void _performScaleInAnimation() {
    if (!mounted) return;

    _currentStage = AnimationStage.scaleIn;
    _scaleController.forward().then((_) {
      if (!mounted) return;
      _performSwingAnimation();
    });
  }

  /// 执行左右晃动动画
  void _performSwingAnimation() {
    if (!mounted) return;

    _currentStage = AnimationStage.swingStart;
    _currentSwingCount = 0;
    _rotationTransitionController.forward().then((_) {
      _currentStage = AnimationStage.swing;
      _performNextSwing();
    });
  }

  /// 执行下一次左右晃动
  void _performNextSwing() {
    if (!mounted || _currentSwingCount >= widget.swingCount) {
      _performTransitionToGentleSwing();
      return;
    }

    _rotationController.forward().then((_) {
      if (!mounted) return;
      _rotationController.reverse().then((_) {
        if (!mounted) return;
        _currentSwingCount++;
        _performNextSwing();
      });
    });
  }

  /// 从普通晃动过渡到轻微晃动
  void _performTransitionToGentleSwing() {
    if (!mounted) return;

    _currentStage = AnimationStage.swingEnd;
    // 先回到中心位置，然后开始轻微晃动
    _rotationTransitionController.reverse().then((_) {
      if (!mounted) return;
      _performGentleSwingAnimation();
    });
  }

  /// 执行轻微晃动动画
  void _performGentleSwingAnimation() {
    if (!mounted) return;

    _currentStage = AnimationStage.gentleSwingStart;
    _currentGentleSwingCount = 0;

    _gentleRotationTransitionController.forward().then((_) {
      _currentStage = AnimationStage.gentleSwing;
      _performNextGentleSwing();
    });
  }

  /// 执行下一次轻微晃动
  void _performNextGentleSwing() {
    if (!mounted || _currentGentleSwingCount >= widget.gentleSwingCount) {
      _performTransitionToHide();
      return;
    }

    _gentleRotationController.forward().then((_) {
      if (!mounted) return;
      _gentleRotationController.reverse().then((_) {
        if (!mounted) return;
        _currentGentleSwingCount++;
        _performNextGentleSwing();
      });
    });
  }

  /// 从轻微晃动过渡到隐藏
  void _performTransitionToHide() {
    if (!mounted) return;

    _currentStage = AnimationStage.gentleSwingEnd;
    // 先回到中心位置，然后隐藏
    _gentleRotationTransitionController.reverse().then((_) {
      if (!mounted) return;
      _performHideAnimation();
    });
  }

  /// 执行隐藏动画
  void _performHideAnimation() {
    if (!mounted) return;

    _currentStage = AnimationStage.hide;

    // 如果跳过隐藏动画，直接重置并重新开始
    if (_skipHideAnimation) {
      _resetAndRestart();
      return;
    }

    _opacityController.forward().then((_) {
      if (!mounted) return;
      _resetAndRestart();
    });
  }

  /// 重置所有动画控制器并重新开始
  void _resetAndRestart() {
    if (!mounted) return;

    // 重置所有动画控制器
    _scaleController.reset();
    _rotationController.reset();
    _rotationTransitionController.reset();
    _gentleRotationController.reset();
    _gentleRotationTransitionController.reset();
    _opacityController.reset();
    // 重新开始循环
    _startAnimation();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _rotationTransitionController.dispose();
    _gentleRotationController.dispose();
    _gentleRotationTransitionController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _rotationController,
        _rotationTransitionController,
        _gentleRotationController,
        _gentleRotationTransitionController,
        _opacityController,
      ]),
      builder: (context, child) {
        double scale = 1.0;
        double rotation = 0.0;
        double opacity = 1.0;

        // 根据当前阶段应用不同的动画
        switch (_currentStage) {
          case AnimationStage.scaleIn:
            scale = _scaleAnimation.value;
            break;
          case AnimationStage.swingStart:
            scale = 1.0;
            rotation = _swingRotationTransitionAnimation.value;
            break;
          case AnimationStage.swing:
            scale = 1.0;
            rotation = _swingRotationAnimation.value;
            break;
          case AnimationStage.swingEnd:
            scale = 1.0;
            rotation = _swingRotationTransitionAnimation.value;
            break;
          case AnimationStage.gentleSwingStart:
            scale = 1.0;
            rotation = _gentleSwingRotationTransitionAnimation.value;
            break;
          case AnimationStage.gentleSwing:
            scale = 1.0;
            rotation = _gentleSwingRotationAnimation.value;
            break;
          case AnimationStage.gentleSwingEnd:
            scale = 1.0;
            rotation = _gentleSwingRotationTransitionAnimation.value;
            break;
          case AnimationStage.hide:
            scale = 1.0;
            rotation = 0.0;
            opacity = _opacityAnimation.value;
            break;
        }

        // 使用Align和Transform.scale组合实现从指定位置开始放大
        return Align(
          alignment: widget.scaleStartAlignment,
          child: Transform.scale(
            scale: scale,
            alignment: widget.scaleStartAlignment,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 根据缩放比例调整动画持续时间
  Duration scaleDuration(Duration duration, double factor) {
    final scaledMilliseconds = (duration.inMilliseconds * factor).round();
    return Duration(milliseconds: scaledMilliseconds);
  }
}

/// 动画阶段枚举
enum AnimationStage {
  scaleIn, // 从无到有放大
  swingStart, // 左右晃动开始
  swing, // 左右晃动
  swingEnd, // 左右晃动结束
  gentleSwingStart, // 轻微晃动开始
  gentleSwing, // 轻微晃动
  gentleSwingEnd, // 轻微晃动结束
  hide, // 隐藏
}
