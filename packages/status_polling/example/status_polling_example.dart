import 'package:flutter/material.dart';
import 'package:status_polling/status_polling.dart';

class AttentionPageExample extends StatefulWidget {
  const AttentionPageExample({super.key});

  @override
  State<AttentionPageExample> createState() => _AttentionPageExampleState();
}

class _AttentionPageExampleState extends State<AttentionPageExample> {
  final String _tag = "AttentionPageExample";

  final ScrollController _controller = ScrollController();

  final List<UserInfo> _dataList = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var itemExtent = 80.0;
    return StatusPollingWidget(
      scrollController: _controller,
      logTag: _tag,
      onRefreshStatus: (scrollOffset) {
        if (!_controller.hasClients) {
          return;
        }
        var viewportDimension = _controller.position.viewportDimension;
        var items = List<UserInfo>.from(_dataList);
        // 获取可见的item列表
        // var visibleItems = getVisibleListRange<UserInfo>(
        //     scrollOffset, itemExtent, viewportDimension, items);
        // var visibleIds = visibleItems.items
        //     .map((e) => e.userId)
        //     .where((element) => element != null && element.isNotEmpty)
        //     .cast<String>()
        //     .toList();
        // 调用接口更新状态
        // ...
      },
      child: RefreshIndicator(
        onRefresh: () {
          // 模拟下拉刷新列表数据
          return Future.delayed(Duration(seconds: 1));
        },
        child: ListView.builder(
          controller: _controller,
          itemExtent: itemExtent,
          itemCount: _dataList.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Text("${_dataList[index].userId}"),
                Text("${_dataList[index].userName}"),
              ],
            );
          },
        ),
      ),
    );
  }
}

class UserInfo {
  String? userId;
  String? userName;
}
