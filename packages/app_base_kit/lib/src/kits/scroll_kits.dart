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

/// 计算当前 GridView 滚动位置下，距离列表底部还剩多少“完整行数”。
///
/// 该方法假设每个网格项（item）的主轴方向尺寸固定（即高度固定），
/// 可用于判断 GridView 是否即将滚动到底，从而触发“预加载”或“上拉加载更多”逻辑。
///
/// 参数说明:
/// - [offset]：当前滚动偏移量（通常为 `ScrollController.offset`）。
/// - [mainAxisExtent]：单个网格项在主轴方向的尺寸（垂直网格即 item 高度）。
/// - [mainAxisSpacing]：网格中每行之间的间距（`GridView` 的 `mainAxisSpacing`）。
/// - [viewportDimension]：当前可视区域的主轴方向尺寸（通常为视口高度）。
/// - [crossAxisCount]：每行的列数（`SliverGridDelegateWithFixedCrossAxisCount.crossAxisCount`）。
/// - [items]：当前网格数据列表。
/// - [headerHeight]：列表顶部额外内容高度，例如 banner、header（可选，默认 0）。
/// - [footerHeight]：列表底部额外内容高度，例如广告位、加载区（可选，默认 0）。
///
/// 返回值:
/// 返回一个 [int]，表示距离列表底部还剩的完整行数。
/// 当返回 `0` 时，说明当前列表已经滚动到底部（或仅剩不足一行）。
int? calculateRemainingGridRows<T>({
  required double offset,
  required double mainAxisExtent,
  required double mainAxisSpacing,
  required double viewportDimension,
  required int crossAxisCount,
  required List<T> items,
  double headerHeight = 0.0,
  double footerHeight = 0.0,
}) {
  if (items.isEmpty || mainAxisExtent <= 0 || crossAxisCount <= 0) return null;

  final int totalRows = (items.length + crossAxisCount - 1) ~/ crossAxisCount;
  final double rowExtent = mainAxisExtent + mainAxisSpacing;

  // 整个列表（含 header/footer）的总高度
  final double totalContentHeight =
      headerHeight + totalRows * rowExtent - mainAxisSpacing + footerHeight;

  // 当前可视区域底部位置
  final double visibleBottom = offset + viewportDimension;

  // 剩余可滚动距离（像素）
  final double remainingPixels =
      (totalContentHeight - visibleBottom).clamp(0.0, double.infinity);

  // 剩余行数（向下取整）
  final int remainingRows = (remainingPixels / rowExtent).floor();

  return remainingRows;
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
