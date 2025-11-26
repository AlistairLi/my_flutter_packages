import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

/// 弹幕数据模型
class DanmakuItem {
  /// 弹幕ID（用于唯一标识）
  final String id;

  /// 弹幕文本内容
  final String text;

  /// 弹幕文本颜色
  final Color textColor;

  /// 边框颜色
  final Color borderColor;

  /// 弹幕背景颜色
  final Color backgroundColor;

  const DanmakuItem({
    required this.id,
    required this.text,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });
}

/// 弹幕配置
class DanmakuConfig {
  /// 弹幕背景颜色
  // final Color backgroundColor;

  /// 文本颜色
  // final Color textColor;

  /// 文本字体大小
  final double fontSize;

  /// 文本字体粗细
  final FontWeight fontWeight;

  /// 弹幕内边距
  final EdgeInsets padding;

  /// 弹幕圆角
  final double borderRadius;

  /// 边框宽度
  final double borderWidth;

  /// 弹幕行高（每行弹幕的高度）
  final double lineHeight;

  /// 弹幕顶部起始位置
  final double topOffset;

  /// 弹幕最小移动速度（像素/秒）
  final double minSpeed;

  /// 弹幕最大移动速度（像素/秒）
  final double maxSpeed;

  /// 弹幕之间的最小间距
  final double minSpacing;

  /// 弹幕的行数
  final int lineCount;

  const DanmakuConfig({
    // this.backgroundColor = const Color(0xCC222222),
    // this.textColor = Colors.white,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    this.borderRadius = 15.0,
    this.borderWidth = 1.5,
    this.lineHeight = 32.0,
    this.topOffset = 50.0,
    this.minSpeed = 40.0,
    this.maxSpeed = 70.0,
    this.minSpacing = 40.0,
    this.lineCount = 3,
  });
}

/// 弹幕轨迹信息
class DanmakuTrack {
  final int trackIndex;
  double top; // 改为可变，允许在运行时更新
  double? lastDanmakuEndTime;
  double? lastDanmakuWidth;
  double? lastDanmakuStartPosition; // 上一条弹幕的起始位置
  final double speed; // 每条轨道的速度
  final double initialDelay; // 初始延迟（秒）
  bool isFirstUse = true; // 标记是否是第一次使用该轨道

  DanmakuTrack({
    required this.trackIndex,
    required this.top,
    required this.speed,
    this.initialDelay = 0.0,
    this.lastDanmakuEndTime,
    this.lastDanmakuWidth,
    this.lastDanmakuStartPosition,
  });
}

/// 多行弹幕组件
class DanmakuWidget extends StatefulWidget {
  /// 弹幕数据源列表
  final List<DanmakuItem> danmakuDataSource;

  /// 弹幕配置
  final DanmakuConfig config;

  /// 是否自动滚动
  final bool autoScroll;

  /// 弹幕显示间隔（毫秒）
  final int displayInterval;

  /// 控制在不可见时是否暂停弹幕运动
  final bool pauseWhenInvisible;

  const DanmakuWidget({
    super.key,
    required this.danmakuDataSource,
    this.config = const DanmakuConfig(),
    this.autoScroll = true,
    this.displayInterval = 1000,
    this.pauseWhenInvisible = false,
  });

  @override
  State<DanmakuWidget> createState() => _DanmakuWidgetState();
}

class _DanmakuWidgetState extends State<DanmakuWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  late List<DanmakuTrack> _tracks;
  late double _screenWidth;

  // late double _screenHeight;
  late int _maxTracks;
  bool _isInitialized = false;

  // 弹幕轮询管理
  List<DanmakuItem> _availableDanmaku = [];
  List<DanmakuItem> _usedDanmaku = [];
  List<DanmakuItem> _currentDanmaku = []; // 当前显示的弹幕
  List<int> _currentDanmakuTracks = []; // 每条弹幕对应的轨道索引
  Timer? _danmakuTimer;

  // 用于批量更新的标记
  bool _needsRebuild = false;

  // 缓存容器高度，避免频繁重新计算轨道位置
  double _lastContainerHeight = 0.0;

  // 弹幕宽度缓存，避免重复计算
  final Map<String, double> _widthCache = {};

  // 可见性状态
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中初始化，确保 MediaQuery 可用
    if (!_isInitialized) {
      _initializeTracks();
      _initializeDanmakuPool();
      _startDanmakuTimer();
      _isInitialized = true;
    } else {
      // 如果已经初始化，重新初始化弹幕池和定时器
      _stopDanmakuTimer();
      _initializeDanmakuPool();
      _startDanmakuTimer();
    }
  }

  void _initializeTracks() {
    _screenWidth = MediaQuery.of(context).size.width;
    // _screenHeight = MediaQuery.of(context).size.height;

    // 固定4条轨道
    _maxTracks = widget.config.lineCount;

    // 为每条轨道生成不同的速度和随机初始延迟
    final random = Random();
    final speedRange = widget.config.maxSpeed - widget.config.minSpeed;

    // 为每条轨道生成完全随机的初始延迟
    // 延迟范围：0 到 displayInterval * 轨道数 * 0.5
    final maxDelayMs = (widget.displayInterval * _maxTracks * 0.5).toInt();

    // 初始化轨道占位符，实际位置在 build 时通过 LayoutBuilder 计算
    _tracks = List.generate(_maxTracks, (index) {
      // 为每条轨道分配不同的速度
      final speedOffset = random.nextInt(speedRange.toInt() + 1);
      final trackSpeed = widget.config.minSpeed + speedOffset;

      // 为每条轨道分配随机的初始延迟（秒）
      final initialDelayMs = random.nextInt(maxDelayMs);
      final initialDelay = initialDelayMs / 1000.0;

      return DanmakuTrack(
        trackIndex: index,
        top: 0.0,
        speed: trackSpeed,
        initialDelay: initialDelay,
      );
    });
  }

  void _updateTracksWithHeight(double containerHeight) {
    if (_tracks.isEmpty) return;

    // 计算单个弹幕的大概高度
    final estimatedDanmakuHeight =
        widget.config.fontSize * 1.5 + widget.config.padding.vertical;

    // 计算轨道间距：让每条弹幕轨道在容器中均匀分布
    final trackSpacing =
        (containerHeight - estimatedDanmakuHeight * _maxTracks) /
            (_maxTracks + 1);

    // 更新每条轨道的 top 位置
    for (int i = 0; i < _tracks.length; i++) {
      _tracks[i].top =
          trackSpacing + i * (estimatedDanmakuHeight + trackSpacing);
    }
  }

  void _initializeDanmakuPool() {
    _availableDanmaku = List.from(widget.danmakuDataSource);
    _usedDanmaku = [];
    _currentDanmaku = [];
    _currentDanmakuTracks = [];
    _animationControllers = [];
    _animations = [];
  }

  void _startDanmakuTimer() {
    if (widget.autoScroll) {
      _danmakuTimer = Timer.periodic(
        Duration(milliseconds: widget.displayInterval),
        (timer) {
          if (mounted && _isVisible) {
            _addRandomDanmaku();
          }
        },
      );
    }
  }

  void _addRandomDanmaku() {
    // 如果不可见，不添加新弹幕
    if (!_isVisible) return;

    if (_availableDanmaku.isEmpty) {
      // 如果可用弹幕用完，重新洗牌
      if (_usedDanmaku.isNotEmpty) {
        _availableDanmaku = List.from(_usedDanmaku);
        _usedDanmaku = [];
      } else {
        // 如果已使用弹幕也为空，从数据源重新初始化
        _initializeDanmakuPool();
      }
    }

    if (_availableDanmaku.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(_availableDanmaku.length);
      final danmaku = _availableDanmaku[randomIndex];

      // 移动到已使用列表
      _usedDanmaku.add(danmaku);
      _availableDanmaku.removeAt(randomIndex);

      _createDanmakuAnimation(danmaku);
    }
  }

  void _createDanmakuAnimation(DanmakuItem danmaku) {
    // 防止重复添加：检查该弹幕是否已经在当前显示列表中
    if (_currentDanmaku.any((item) => item.id == danmaku.id)) {
      return;
    }

    final track = _findAvailableTrack(danmaku);

    if (track != null) {
      final danmakuWidth = _estimateDanmakuWidth(danmaku);
      // 使用该轨道特定的速度
      final trackSpeed = track.speed;

      // 增加额外的安全距离，确保完全移出屏幕
      // 额外增加 20% 的弹幕宽度作为缓冲
      final safeEndPosition = -danmakuWidth * 1.2;
      final totalDistance = _screenWidth - safeEndPosition;

      final controller = AnimationController(
        duration: Duration(
          milliseconds: ((totalDistance / trackSpeed) * 1000).round(),
        ),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: _screenWidth,
        end: safeEndPosition, // 增加安全距离
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      _animationControllers.add(controller);
      _animations.add(animation);
      _currentDanmaku.add(danmaku);
      _currentDanmakuTracks.add(track.trackIndex);

      // 考虑初始延迟后启动动画
      final initialDelay = track.initialDelay;
      final hasInitialDelay = initialDelay > 0 && track.isFirstUse;

      if (hasInitialDelay) {
        track.isFirstUse = false; // 标记已使用
      }

      // 立即占用轨道，防止重复分配
      // 如果有初始延迟，将开始时间设置为未来时间
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      track.lastDanmakuEndTime =
          currentTime + (hasInitialDelay ? initialDelay : 0);
      track.lastDanmakuWidth = danmakuWidth;
      track.lastDanmakuStartPosition = _screenWidth;

      // 延迟触发 UI 更新，避免频繁 setState
      if (!_needsRebuild) {
        _needsRebuild = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _needsRebuild) {
            setState(() {
              _needsRebuild = false;
            });
          }
        });
      }

      // 启动动画
      if (hasInitialDelay) {
        // 有初始延迟，延迟启动动画
        Future.delayed(Duration(milliseconds: (initialDelay * 1000).round()),
            () {
          if (mounted &&
              _isVisible &&
              controller.status != AnimationStatus.completed) {
            controller.forward().then((_) {
              if (mounted) {
                _cleanupAnimation(controller);
              }
            });
          }
        });
      } else {
        // 立即启动动画（如果可见）
        if (_isVisible) {
          controller.forward().then((_) {
            if (mounted) {
              _cleanupAnimation(controller);
            }
          });
        }
      }
    } else {
      // 如果没有可用轨道，将弹幕放回可用池的开头，等待下次被选中
      // 从已使用列表中移除，放回可用列表
      _usedDanmaku.remove(danmaku);
      _availableDanmaku.insert(0, danmaku); // 插入到开头，优先被选中
    }
  }

  void _cleanupAnimation(AnimationController controller) {
    // 使用 addPostFrameCallback 确保在下一帧渲染完成后再清理
    // 这样可以保证最后一帧（弹幕完全移出屏幕的状态）已经显示
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final index = _animationControllers.indexOf(controller);
      if (index != -1 && index < _animationControllers.length) {
        controller.dispose();
        _animationControllers.removeAt(index);
        _animations.removeAt(index);
        if (index < _currentDanmaku.length) {
          _currentDanmaku.removeAt(index);
        }
        if (index < _currentDanmakuTracks.length) {
          _currentDanmakuTracks.removeAt(index);
        }

        // 清理操作需要触发 setState 以保持数据一致性
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  DanmakuTrack? _findAvailableTrack(DanmakuItem danmaku) {
    // 先估算新弹幕的宽度（用于碰撞检测）
    final newDanmakuWidth = _estimateDanmakuWidth(danmaku);

    // 首先收集所有可用的轨道
    List<DanmakuTrack> availableTracks = [];

    for (final track in _tracks) {
      if (track.lastDanmakuStartPosition == null) {
        // 如果轨道从未使用过，直接可用
        availableTracks.add(track);
      } else {
        // 使用更可靠的方法：检查该轨道上的所有弹幕
        double minGap = double.infinity;

        // 遍历当前所有弹幕，找出在该轨道上的弹幕
        for (int i = 0; i < _currentDanmakuTracks.length; i++) {
          if (_currentDanmakuTracks[i] == track.trackIndex &&
              i < _animations.length) {
            // 获取该弹幕的实际位置（从动画控制器）
            final lastDanmakuLeft = _animations[i].value;
            final lastDanmakuWidth = i < _currentDanmaku.length
                ? _estimateDanmakuWidth(_currentDanmaku[i])
                : (track.lastDanmakuWidth ?? 0);
            final lastDanmakuRight = lastDanmakuLeft + lastDanmakuWidth;

            // 计算间距
            final gap = _screenWidth - lastDanmakuRight;
            minGap = gap < minGap ? gap : minGap;
          }
        }

        // 如果该轨道上没有弹幕，使用时间估算（兼容旧逻辑）
        if (minGap == double.infinity) {
          final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
          final timeSinceLastDanmaku =
              currentTime - (track.lastDanmakuEndTime ?? 0);

          // 如果时间差是负数，说明上一条弹幕还在初始延迟中，轨道不可用
          if (timeSinceLastDanmaku < 0) {
            continue;
          }

          final distanceMoved = timeSinceLastDanmaku * track.speed;
          final lastDanmakuLeft = _screenWidth - distanceMoved;
          final lastDanmakuRight =
              lastDanmakuLeft + (track.lastDanmakuWidth ?? 0);
          minGap = _screenWidth - lastDanmakuRight;
        }

        // 安全策略：
        // 1. 基础间距要求：minSpacing
        // 2. 考虑宽度估算误差：增加 50% 安全边距
        // 3. 考虑新弹幕的宽度：额外增加 10% 新弹幕宽度作为缓冲
        final safetyFactor = 1.5;
        final requiredGap =
            widget.config.minSpacing * safetyFactor + newDanmakuWidth * 0.1;

        if (minGap >= requiredGap) {
          availableTracks.add(track);
        }
      }
    }

    if (availableTracks.isEmpty) {
      return null;
    }

    // 如果有多个可用轨道，优先选择最久未使用的轨道
    // 对于从未使用的轨道，按初始延迟排序（延迟小的优先）
    availableTracks.sort((a, b) {
      final aTime = a.lastDanmakuEndTime ?? double.negativeInfinity;
      final bTime = b.lastDanmakuEndTime ?? double.negativeInfinity;

      // 如果都是未使用的轨道，按初始延迟排序，让延迟小的先被使用
      if (aTime == double.negativeInfinity &&
          bTime == double.negativeInfinity) {
        return a.initialDelay.compareTo(b.initialDelay);
      }

      return aTime.compareTo(bTime);
    });

    final selectedTrack = availableTracks.first;
    return selectedTrack;
  }

  double _estimateDanmakuWidth(DanmakuItem danmaku) {
    // 使用弹幕ID作为缓存key
    final cacheKey = danmaku.id;

    // 检查缓存
    if (_widthCache.containsKey(cacheKey)) {
      return _widthCache[cacheKey]!;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: danmaku.text,
        style: TextStyle(
          fontSize: widget.config.fontSize,
          fontWeight: widget.config.fontWeight,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    final textWidth = textPainter.width.ceilToDouble();
    final estimatedWidth = textWidth +
        widget.config.padding.horizontal +
        widget.config.borderWidth * 2;

    // 移除最大宽度限制，只保留最小宽度限制
    final width = estimatedWidth.clamp(50.0, double.infinity);

    // 存入缓存（限制缓存大小，避免内存泄漏）
    if (_widthCache.length > 100) {
      _widthCache.clear();
    }
    _widthCache[cacheKey] = width;

    return width;
  }

  @override
  void didUpdateWidget(DanmakuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.danmakuDataSource.length != widget.danmakuDataSource.length) {
      _stopDanmakuTimer();
      _disposeAnimations();
      _widthCache.clear(); // 清理缓存
      _initializeDanmakuPool();
      _startDanmakuTimer();
    }
  }

  void _stopDanmakuTimer() {
    _danmakuTimer?.cancel();
    _danmakuTimer = null;
  }

  void _disposeAnimations() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear();
    _animations.clear();
    _currentDanmaku.clear();
    _currentDanmakuTracks.clear();
  }

  /// 暂停弹幕运动
  void _pauseDanmaku() {
    if (!mounted) return;
    if (!_isVisible) return; // 已经暂停，不重复操作
    _isVisible = false;

    // 暂停定时器
    _danmakuTimer?.cancel();

    // 暂停所有动画控制器
    for (final controller in _animationControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
    }
  }

  /// 恢复弹幕运动
  void _resumeDanmaku() {
    if (!mounted) return;
    if (_isVisible) return; // 已经运行，不重复操作
    _isVisible = true;

    // 恢复定时器
    if (widget.autoScroll) {
      _danmakuTimer = Timer.periodic(
        Duration(milliseconds: widget.displayInterval),
        (timer) {
          if (mounted && _isVisible) {
            _addRandomDanmaku();
          }
        },
      );
    }

    // 恢复所有动画控制器
    for (final controller in _animationControllers) {
      if (!controller.isAnimating &&
          controller.status != AnimationStatus.completed &&
          controller.status != AnimationStatus.dismissed) {
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _stopDanmakuTimer();
    _disposeAnimations();
    _widthCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget current = _buildContent();
    if (widget.pauseWhenInvisible) {
      current = VisibilityDetectorWidget(
        onVisible: () {
          _resumeDanmaku();
        },
        onInvisible: () {
          _pauseDanmaku();
        },
        child: current,
      );
    }
    return current;
  }

  Widget _buildContent() {
    // 如果还未初始化，返回空容器
    if (!_isInitialized) {
      return const SizedBox(width: 2, height: 2);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 只在容器高度变化时重新计算轨道位置
        if (constraints.maxHeight > 0 &&
            _tracks.isNotEmpty &&
            constraints.maxHeight != _lastContainerHeight) {
          _lastContainerHeight = constraints.maxHeight;
          _updateTracksWithHeight(constraints.maxHeight);
        }

        return IgnorePointer(
          child: Stack(
            children: [
              // 弹幕层
              ...List.generate(_animationControllers.length, (index) {
                return _buildDanmakuItem(index);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDanmakuItem(int index) {
    // 严格的边界检查：确保 index 在所有相关列表的有效范围内
    if (index >= _animationControllers.length ||
        index >= _animations.length ||
        index >= _currentDanmaku.length ||
        index >= _currentDanmakuTracks.length) {
      return const SizedBox.shrink();
    }

    // 从当前显示的弹幕中获取对应的弹幕数据
    final danmaku = _currentDanmaku[index];

    // 使用存储的轨道索引，并验证有效性
    final trackIndex = _currentDanmakuTracks[index];

    // 边界检查：确保 trackIndex 在有效范围内
    if (trackIndex < 0 || trackIndex >= _tracks.length) {
      return const SizedBox.shrink();
    }

    final track = _tracks[trackIndex];
    final trackTop = track.top;

    // 捕获当前的animation和controller，避免闭包引用被索引变化影响
    final animation = _animations[index];
    // final controller = _animationControllers[index];

    return AnimatedBuilder(
      key: ValueKey('danmaku_${danmaku.id}_$index'), // 使用唯一Key
      animation: animation,
      builder: (context, child) {
        // 不检查状态，让动画自然完成到最后一帧
        // Future.microtask 会在下一个微任务中清理，确保最后一帧渲染完成
        return PositionedDirectional(
          start: animation.value,
          top: trackTop,
          child: child!,
        );
      },
      // 使用 child 缓存弹幕气泡，避免每帧重建
      child: RepaintBoundary(
        child: _buildDanmakuBubble(danmaku),
      ),
    );
  }

  Widget _buildDanmakuBubble(DanmakuItem danmaku) {
    // 根据图片效果，使用半透明背景和渐变边框
    return Container(
      padding: widget.config.padding,
      decoration: BoxDecoration(
        color: danmaku.backgroundColor,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        // 使用渐变边框效果
        border: Border.all(
          color: danmaku.borderColor,
          width: widget.config.borderWidth,
        ),
      ),
      child: Text(
        danmaku.text,
        style: TextStyle(
          color: danmaku.textColor,
          fontSize: widget.config.fontSize,
          fontWeight: widget.config.fontWeight,
        ),
        maxLines: 1,
      ),
    );
  }
}

/// 弹幕管理器
class DanmakuManager {
  static final DanmakuManager _instance = DanmakuManager._internal();

  factory DanmakuManager() => _instance;

  DanmakuManager._internal();

  final List<DanmakuItem> _danmakuList = [];
  final List<Color> _borderColors = [
    Colors.white,
    Colors.pink,
    Colors.cyan,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  /// 添加弹幕
  void addDanmaku(
    String text, {
    Color? textColor,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    final danmaku = DanmakuItem(
      // id: DateTime.now().millisecondsSinceEpoch.toString(),
      id: Uuid().v4(),
      text: text,
      textColor: textColor ?? Colors.white,
      borderColor: borderColor ??
          _borderColors[_danmakuList.length % _borderColors.length],
      backgroundColor: backgroundColor ?? Colors.black12,
    );

    _danmakuList.add(danmaku);

    // 限制弹幕数量，避免内存溢出
    if (_danmakuList.length > 20) {
      _danmakuList.removeAt(0);
    }
  }

  /// 获取弹幕列表
  List<DanmakuItem> get danmakuList => List.unmodifiable(_danmakuList);

  /// 清空弹幕
  void clearDanmaku() {
    _danmakuList.clear();
  }

  /// 移除指定弹幕
  void removeDanmaku(String id) {
    _danmakuList.removeWhere((danmaku) => danmaku.id == id);
  }
}

/// 预定义的弹幕样式
class DanmakuStyles {
  static const DanmakuConfig defaultStyle = DanmakuConfig();

  static const DanmakuConfig compactStyle = DanmakuConfig(
    fontSize: 12.0,
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
    borderRadius: 8.0,
    lineHeight: 30.0,
  );

  static const DanmakuConfig largeStyle = DanmakuConfig(
    fontSize: 16.0,
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    borderRadius: 16.0,
    lineHeight: 50.0,
  );

  static const DanmakuConfig transparentStyle = DanmakuConfig(
    borderWidth: 1.0,
  );
}
