import 'package:flutter/material.dart';
import 'package:svga_wrapper/svga_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVGA Wrapper Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVGA Wrapper Example'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SVGA Animation Example',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // 使用 assets 中的 SVGA 文件
            SVGASimpleImageEx(
              assetsName: 'assets/animations/example.svga',
            ),
            SizedBox(height: 20),
            // 使用网络 URL
            SVGASimpleImageEx(
              resUrl: 'https://example.com/animation.svga',
            ),
          ],
        ),
      ),
    );
  }
}
