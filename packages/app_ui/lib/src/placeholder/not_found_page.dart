import 'package:app_ui/src/custom_app_bar.dart';
import 'package:flutter/material.dart';

/// 未找到路由时显示的默认页面
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'The page you are looking for doesn’t exist or has been moved.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // 可选：跳转到首页或其他默认页面
                    // Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
