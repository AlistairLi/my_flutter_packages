/// 滚动工具函数
///
/// 提供与 [ScrollController] 相关的便捷计算工具，例如计算当前可见的列表项。
library;

/// 根据滚动偏移量计算当前可见的子列表。
///
/// 参数：
/// [offset] 当前滚动的偏移量（`ScrollController.offset`）
/// [itemExtent] 每个列表项的固定高度或宽度
/// [viewportDimension] 可视区域的高度或宽度
/// [items] 原始完整列表
///
/// 返回：
/// 当前可见的子列表（`List<T>`）
VisibleRange<T> getVisibleListRange<T>(
  double offset,
  double itemExtent,
  double viewportDimension,
  List<T> items,
) {
  if (items.isEmpty || itemExtent <= 0 || viewportDimension <= 0) {
    return const VisibleRange(firstIndex: 0, lastIndex: 0, items: []);
  }

  final int firstIndex =
      (offset / itemExtent).floor().clamp(0, items.length - 1);
  final int lastIndex = ((offset + viewportDimension) / itemExtent)
      .floor()
      .clamp(0, items.length - 1);

  return VisibleRange(
    firstIndex: firstIndex,
    lastIndex: lastIndex,
    items: items.sublist(firstIndex, lastIndex + 1),
  );
}

/// 获取 GridView 的可见项
///
/// [offset] 当前滚动偏移量（ScrollController.offset）
/// [mainAxisExtent] 主轴方向上的item高度
/// [mainAxisSpacing] 主轴方向上的间距
/// [viewportDimension] 可视区域高度
/// [crossAxisCount] 交叉轴上的子项数量
/// [items] 原始数据列表
/// [headerHeight] Header的高度
VisibleRange<T> getVisibleGridRange<T>({
  required double offset,
  required double mainAxisExtent,
  required double mainAxisSpacing,
  required double viewportDimension,
  required int crossAxisCount,
  required List<T> items,
  double headerHeight = 0.0,
}) {
  if (items.isEmpty ||
      mainAxisExtent <= 0 ||
      viewportDimension <= 0 ||
      crossAxisCount <= 0) {
    return const VisibleRange(firstIndex: 0, lastIndex: 0, items: []);
  }

  final double rowExtent = mainAxisExtent + mainAxisSpacing;
  final int totalRows = (items.length + crossAxisCount - 1) ~/ crossAxisCount;

  int? startIndex;
  int? endIndex;
  final visibleItems = <T>[];

  for (int row = 0; row < totalRows; row++) {
    final double rowTop = headerHeight + row * rowExtent;
    final double rowBottom = rowTop + mainAxisExtent;

    // 判断行是否至少有部分可见
    if (rowBottom > offset && rowTop < offset + viewportDimension) {
      // 当前行所有 item
      final int rowStartIndex = row * crossAxisCount;
      final int rowEndIndex =
          ((row + 1) * crossAxisCount - 1).clamp(0, items.length - 1);

      startIndex ??= rowStartIndex;
      endIndex = rowEndIndex;

      visibleItems.addAll(items.sublist(rowStartIndex, rowEndIndex + 1));
    }
  }
  return VisibleRange(
    firstIndex: startIndex ?? 0,
    lastIndex: endIndex ?? 0,
    items: visibleItems,
  );
}

class VisibleRange<T> {
  final int firstIndex;
  final int lastIndex;
  final List<T> items;

  const VisibleRange({
    required this.firstIndex,
    required this.lastIndex,
    required this.items,
  });
}
