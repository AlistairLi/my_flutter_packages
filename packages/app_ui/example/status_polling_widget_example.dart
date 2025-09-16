import 'package:app_ui/src/status_polling_widget.dart';
import 'package:flutter/material.dart';

/// 消息中心-关注列表，不带Scaffold
class FollowPageExample extends StatelessWidget {
  final String tag = "FollowPageExample";

  const FollowPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return StatusPollingWidget(
      logTag: tag,
      onRefreshStatus: () async {
        // 模拟刷新状态
        return Future.delayed(Duration(seconds: 1));
      },
      child: RefreshIndicator(
        onRefresh: () {
          // 模拟刷新列表数据
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
