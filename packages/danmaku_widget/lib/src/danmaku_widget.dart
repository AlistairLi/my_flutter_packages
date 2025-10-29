import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:uuid/uuid.dart';

/// 弹幕数据模型
class DanmakuItem {
  /// 弹幕文本内容
  final String text;

  /// 边框颜色
  final Color borderColor;

  /// 是否包含表情符号
  final bool hasEmoji;

  /// 表情符号（可选）
  final String? emoji;

  /// 弹幕ID（用于唯一标识）
  final String id;

  const DanmakuItem({
    required this.text,
    required this.borderColor,
    this.hasEmoji = false,
    this.emoji,
    required this.id,
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

  /// 弹幕最大宽度（相对于屏幕宽度的比例）
  final double maxWidthRatio;

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
    this.maxWidthRatio = 0.7,
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

  const DanmakuWidget({
    super.key,
    required this.danmakuDataSource,
    this.config = const DanmakuConfig(),
    this.autoScroll = true,
    this.displayInterval = 1000,
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
          if (mounted) {
            _addRandomDanmaku();
          }
        },
      );
    }
  }

  void _addRandomDanmaku() {
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
    final track = _findAvailableTrack(danmaku);

    if (track != null) {
      final danmakuWidth = _estimateDanmakuWidth(danmaku);
      // 使用该轨道特定的速度
      final trackSpeed = track.speed;

      final controller = AnimationController(
        duration: Duration(
          milliseconds:
              (((_screenWidth + danmakuWidth) / trackSpeed) * 1000).round(),
        ),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: _screenWidth,
        end: -danmakuWidth, // 确保完全移出屏幕
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
          if (mounted && controller.status != AnimationStatus.completed) {
            controller.forward().then((_) {
              if (mounted) {
                _cleanupAnimation(controller);
              }
            });
          }
        });
      } else {
        // 立即启动动画
        controller.forward().then((_) {
          if (mounted) {
            _cleanupAnimation(controller);
          }
        });
      }
    } else {
      // 如果没有可用轨道，延迟重试
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _createDanmakuAnimation(danmaku);
        }
      });
    }
  }

  void _cleanupAnimation(AnimationController controller) {
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

      // 清理操作需要立即触发 setState 以保持数据一致性
      if (mounted) {
        setState(() {});
      }
    }
  }

  DanmakuTrack? _findAvailableTrack(DanmakuItem danmaku) {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // 首先收集所有可用的轨道
    List<DanmakuTrack> availableTracks = [];

    for (final track in _tracks) {
      if (track.lastDanmakuStartPosition == null) {
        // 如果轨道从未使用过，直接可用
        availableTracks.add(track);
      } else {
        // 计算上一条弹幕移动的距离（使用该轨道的速度）
        final timeSinceLastDanmaku =
            currentTime - (track.lastDanmakuEndTime ?? 0);

        // 如果时间差是负数，说明上一条弹幕还在初始延迟中，轨道不可用
        if (timeSinceLastDanmaku < 0) {
          continue;
        }

        final distanceMoved = timeSinceLastDanmaku * track.speed;

        // 计算上一条弹幕的当前位置
        // 上一条弹幕的left位置
        final lastDanmakuLeft = _screenWidth - distanceMoved;
        // 上一条弹幕的right位置
        final lastDanmakuRight =
            lastDanmakuLeft + (track.lastDanmakuWidth ?? 0);

        // 新弹幕从屏幕右边缘(_screenWidth)进入
        // 只有当上一条弹幕的右边缘 + 最小间距 <= 屏幕右边缘时，才不会重叠
        // 这样保证新弹幕从右边进入时，不会与上一条弹幕重叠
        if (lastDanmakuRight + widget.config.minSpacing <= _screenWidth) {
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

    // 估算弹幕宽度（简化计算）
    final textLength = danmaku.text.length;
    final emojiLength = danmaku.hasEmoji ? 1 : 0;
    final estimatedWidth =
        (textLength + emojiLength) * widget.config.fontSize * 0.6 +
            widget.config.padding.horizontal;
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

  @override
  void dispose() {
    _stopDanmakuTimer();
    _disposeAnimations();
    _widthCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果还未初始化，返回空容器
    if (!_isInitialized) {
      return const SizedBox.shrink();
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
    if (index >= _animationControllers.length) return const SizedBox.shrink();

    // 从当前显示的弹幕中获取对应的弹幕数据
    final danmaku = index < _currentDanmaku.length
        ? _currentDanmaku[index]
        : const DanmakuItem(id: '', text: '', borderColor: Colors.white);

    // 使用存储的轨道索引，并验证有效性
    final trackIndex =
        index < _currentDanmakuTracks.length ? _currentDanmakuTracks[index] : 0;

    // 边界检查：确保 trackIndex 在有效范围内
    if (trackIndex < 0 || trackIndex >= _tracks.length) {
      return const SizedBox.shrink();
    }

    final track = _tracks[trackIndex];
    final trackTop = track.top;

    // 捕获当前的animation和controller，避免闭包引用被索引变化影响
    final animation = _animations[index];
    final controller = _animationControllers[index];

    return AnimatedBuilder(
      key: ValueKey('danmaku_${danmaku.id}_$index'), // 使用唯一Key
      animation: animation,
      builder: (context, child) {
        // 检查controller状态，如果已disposed则不显示
        if (controller.isDismissed) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: animation.value,
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
        color: danmaku.borderColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        // 使用渐变边框效果
        border: Border.all(
          color: danmaku.borderColor.withValues(alpha: 0.6),
          width: widget.config.borderWidth,
        ),
      ),
      child: danmaku.hasEmoji && danmaku.emoji != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  danmaku.emoji!,
                  style: TextStyle(fontSize: widget.config.fontSize),
                ),
                const SizedBox(width: 4),
                Text(
                  danmaku.text,
                  style: TextStyle(
                    // color: widget.config.textColor,
                    color: danmaku.borderColor,
                    fontSize: widget.config.fontSize,
                    fontWeight: widget.config.fontWeight,
                  ),
                  maxLines: 1,
                ),
              ],
            )
          : Text(
              danmaku.text,
              style: TextStyle(
                // color: widget.config.textColor,
                color: danmaku.borderColor,
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
  void addDanmaku(String text, {String? emoji, Color? borderColor}) {
    final danmaku = DanmakuItem(
      // id: DateTime.now().millisecondsSinceEpoch.toString(),
      id: Uuid().v4(),
      text: text,
      emoji: emoji,
      hasEmoji: emoji != null,
      borderColor: borderColor ??
          _borderColors[_danmakuList.length % _borderColors.length],
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
