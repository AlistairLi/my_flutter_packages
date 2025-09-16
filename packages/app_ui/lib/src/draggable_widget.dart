import 'package:flutter/material.dart';

/// 拖拽组件
class DraggableWidget extends StatefulWidget {
  final Widget child;
  final GlobalKey parentKey;
  final Offset offset;
  final bool wrapWithStack;
  final EdgeInsets padding;

  const DraggableWidget({
    super.key,
    required this.child,
    required this.parentKey,
    this.offset = Offset.zero,
    this.wrapWithStack = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<StatefulWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  late Offset _offset;
  final GlobalKey _key = GlobalKey();

  bool _isDragging = false;
  late Offset _maxOffset;
  late Offset _minOffset;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
  }

  void _setBoundary(_) {
    final RenderBox renderBox =
        _key.currentContext?.findRenderObject() as RenderBox;
    final RenderBox parentRenderBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox;

    final Size size = renderBox.size;
    final Size parentSize = parentRenderBox.size;

    double paddingLeft = widget.padding.left;
    double paddingRight = widget.padding.right;
    double paddingTop = widget.padding.top;
    double paddingBottom = widget.padding.bottom;

    assert(paddingLeft + paddingRight + size.width <= parentSize.width);
    assert(paddingTop + paddingBottom + size.height <= parentSize.height);

    setState(() {
      _maxOffset = Offset(parentSize.width - size.width - paddingRight,
          parentSize.height - size.height - paddingBottom);
      _minOffset = Offset(paddingLeft, paddingTop);

      // 检查并调整初始位置，确保不超出边界
      double adjustedX = widget.offset.dx;
      double adjustedY = widget.offset.dy;

      if (adjustedX < _minOffset.dx) {
        adjustedX = _minOffset.dx;
      } else if (adjustedX > _maxOffset.dx) {
        adjustedX = _maxOffset.dx;
      }

      if (adjustedY < _minOffset.dy) {
        adjustedY = _minOffset.dy;
      } else if (adjustedY > _maxOffset.dy) {
        adjustedY = _maxOffset.dy;
      }

      _offset = Offset(adjustedX, adjustedY);
    });
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }
    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Positioned(
      top: _offset.dy,
      left: _offset.dx,
      child: Listener(
        onPointerUp: _onPointerUp,
        onPointerMove: _pointerMove,
        child: Container(
          key: _key,
          child: widget.child,
        ),
      ),
    );

    // 根据wrapWithStack属性决定是否包裹Stack
    if (widget.wrapWithStack) {
      current = Stack(
        children: [
          current,
        ],
      );
    }
    return current;
  }

  _onPointerUp(PointerUpEvent pointerUpEvent) {
    if (_isDragging) {
      setState(() {
        _isDragging = false;
      });
    }
  }

  _pointerMove(PointerMoveEvent pointerMoveEvent) {
    _updatePosition(pointerMoveEvent);
    setState(() {
      _isDragging = true;
    });
  }
}
