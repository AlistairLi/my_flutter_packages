import 'package:app_ui/shared_widgets.dart';
import 'package:flutter/material.dart';

/// 空布局
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 50),
          AppText(
            "No data",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
