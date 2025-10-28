import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

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

  /// 弹幕移动速度（像素/秒）
  final double speed;

  /// 弹幕之间的最小间距
  final double minSpacing;

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
    this.speed = 50.0,
    this.minSpacing = 20.0,
  });
}

/// 弹幕轨迹信息
class DanmakuTrack {
  final int trackIndex;
  double top; // 改为可变，允许在运行时更新
  double? lastDanmakuEndTime;
  double? lastDanmakuWidth;
  double? lastDanmakuStartPosition; // 上一条弹幕的起始位置

  DanmakuTrack({
    required this.trackIndex,
    required this.top,
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
  late List<Animation<double>> _opacityAnimations;
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
    _maxTracks = 4;

    // 初始化轨道占位符，实际位置在 build 时通过 LayoutBuilder 计算
    _tracks = List.generate(_maxTracks, (index) {
      return DanmakuTrack(
        trackIndex: index,
        top: 0.0,
      );
    });
  }

  void _updateTracksWithHeight(double containerHeight) {
    if (_tracks.isEmpty) return;

    // 计算单个弹幕的大概高度
    final estimatedDanmakuHeight =
        widget.config.fontSize * 1.5 + widget.config.padding.vertical;

    // 计算轨道间距：让4条弹幕轨道在容器中均匀分布
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
    _opacityAnimations = [];
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
      final controller = AnimationController(
        duration: Duration(
          milliseconds:
              (((_screenWidth + danmakuWidth) / widget.config.speed) * 1000)
                  .round(),
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

      final opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      _animationControllers.add(controller);
      _animations.add(animation);
      _opacityAnimations.add(opacityAnimation);
      _currentDanmaku.add(danmaku);
      _currentDanmakuTracks.add(track.trackIndex);

      // 更新轨道信息
      _updateTrackInfo(
          track, controller.duration!.inMilliseconds / 1000.0, danmakuWidth);

      // 触发 UI 更新
      if (mounted) {
        setState(() {});
      }

      // 启动动画
      controller.forward().then((_) {
        // 动画完成后清理
        if (mounted) {
          setState(() {
            _cleanupAnimation(controller);
          });
        }
      });
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
    if (index != -1) {
      _animationControllers.removeAt(index);
      _animations.removeAt(index);
      _opacityAnimations.removeAt(index);
      if (index < _currentDanmaku.length) {
        _currentDanmaku.removeAt(index);
      }
      if (index < _currentDanmakuTracks.length) {
        _currentDanmakuTracks.removeAt(index);
      }
    }
    controller.dispose();
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
        // 计算上一条弹幕移动的距离
        final timeSinceLastDanmaku =
            currentTime - (track.lastDanmakuEndTime ?? 0);
        final distanceMoved = timeSinceLastDanmaku * widget.config.speed;

        // 如果上一条弹幕已经移动了足够的距离，则可以添加新弹幕
        if (distanceMoved >=
            (track.lastDanmakuWidth ?? 0) + widget.config.minSpacing) {
          availableTracks.add(track);
        }
      }
    }

    if (availableTracks.isEmpty) {
      return null;
    }

    // 如果有多个可用轨道，优先选择最久未使用的轨道
    // 对于从未使用的轨道，按索引顺序分配
    availableTracks.sort((a, b) {
      final aTime = a.lastDanmakuEndTime ?? double.negativeInfinity;
      final bTime = b.lastDanmakuEndTime ?? double.negativeInfinity;

      // 如果都是未使用的轨道，按轨道索引排序
      if (aTime == double.negativeInfinity &&
          bTime == double.negativeInfinity) {
        return a.trackIndex.compareTo(b.trackIndex);
      }

      return aTime.compareTo(bTime);
    });

    final selectedTrack = availableTracks.first;
    return selectedTrack;
  }

  void _updateTrackInfo(
      DanmakuTrack track, double duration, double danmakuWidth) {
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    track.lastDanmakuEndTime = currentTime;
    track.lastDanmakuWidth = danmakuWidth;
    track.lastDanmakuStartPosition = _screenWidth;
  }

  double _estimateDanmakuWidth(DanmakuItem danmaku) {
    // 估算弹幕宽度（简化计算）
    final textLength = danmaku.text.length;
    final emojiLength = danmaku.hasEmoji ? 1 : 0;
    final estimatedWidth =
        (textLength + emojiLength) * widget.config.fontSize * 0.6 +
            widget.config.padding.horizontal;
    return estimatedWidth.clamp(
        50.0, _screenWidth * widget.config.maxWidthRatio);
  }

  @override
  void didUpdateWidget(DanmakuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.danmakuDataSource.length != widget.danmakuDataSource.length) {
      _stopDanmakuTimer();
      _disposeAnimations();
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
    _opacityAnimations.clear();
    _currentDanmaku.clear();
    _currentDanmakuTracks.clear();
  }

  @override
  void dispose() {
    _stopDanmakuTimer();
    _disposeAnimations();
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
        // 使用 LayoutBuilder 获取实际容器尺寸，并重新计算轨道位置
        if (constraints.maxHeight > 0 && _tracks.isNotEmpty) {
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

    // 使用存储的轨道索引
    final trackIndex =
        index < _currentDanmakuTracks.length ? _currentDanmakuTracks[index] : 0;
    final track = _tracks[trackIndex];
    final maxWidth = _screenWidth * widget.config.maxWidthRatio;

    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return Positioned(
          left: _animations[index].value,
          top: track.top,
          child: AnimatedBuilder(
            animation: _opacityAnimations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimations[index].value,
                child: _buildDanmakuBubble(danmaku, maxWidth),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDanmakuBubble(DanmakuItem danmaku, double maxWidth) {
    // 根据图片效果，使用半透明背景和渐变边框
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
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
                Flexible(
                  child: Text(
                    danmaku.text,
                    style: TextStyle(
                      // color: widget.config.textColor,
                      color: danmaku.borderColor,
                      fontSize: widget.config.fontSize,
                      fontWeight: widget.config.fontWeight,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
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
              overflow: TextOverflow.ellipsis,
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
    speed: 40.0,
  );

  static const DanmakuConfig largeStyle = DanmakuConfig(
    fontSize: 16.0,
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    borderRadius: 16.0,
    lineHeight: 50.0,
    speed: 60.0,
  );

  static const DanmakuConfig transparentStyle = DanmakuConfig(
    borderWidth: 1.0,
  );
}
