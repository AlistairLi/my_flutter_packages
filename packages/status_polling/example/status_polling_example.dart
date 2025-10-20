import 'package:flutter/material.dart';
import 'package:status_polling/status_polling.dart';

class AttentionPageExample extends StatelessWidget {
  final String tag = "AttentionPageExample";

  const AttentionPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusPollingWidget(
      logTag: tag,
      onRefreshStatus: (scrollOffset) {
        // 模拟刷新状态
        Future.delayed(Duration(seconds: 1));
      },
      child: RefreshIndicator(
        onRefresh: () {
          // 模拟下拉刷新列表数据
          return Future.delayed(Duration(seconds: 1));
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            return SizedBox.square();
          },
        ),
      ),
    );
  }
}
