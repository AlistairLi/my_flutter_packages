import 'package:flutter/material.dart';

import '../config/smart_refresh_config.dart';

/// 空状态组件
class DefaultEmptyStatusWidget extends StatelessWidget {
  final String message;
  final String? assets;
  final VoidCallback? onRetry;

  const DefaultEmptyStatusWidget({
    super.key,
    this.message = 'No data',
    this.assets,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = RefreshConfig.scheme(context);
    var assets = this.assets;
    return Align(
      alignment: Alignment(0, -0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assets != null) ...[
            Image.asset(
              assets,
              width: 80,
              height: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16.0),
          ],
          Text(
            message,
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 16.0,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: onRetry,
              child: const Text('retry'),
            ),
          ],
        ],
      ),
    );
  }
}
