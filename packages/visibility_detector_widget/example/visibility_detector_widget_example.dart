import 'package:flutter/material.dart';
import 'package:visibility_detector_widget/visibility_detector_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visibility Detector Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Visible';
  int _visibleCount = 0;
  int _invisibleCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visibility Detector Widget Demo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visibility Detector Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Current Status: $_status',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Visible Count: $_visibleCount',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Invisible Count: $_invisibleCount',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                'Scroll down to see the visibility detector widget:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Add some padding to demonstrate scrolling
              const SizedBox(height: 800),
              VisibilityDetectorWidget(
                onVisible: () {
                  setState(() {
                    _status = 'Visible';
                    _visibleCount++;
                  });
                  debugPrint('Widget became visible');
                },
                onInvisible: () {
                  setState(() {
                    _status = 'Invisible';
                    _invisibleCount++;
                  });
                  debugPrint('Widget became invisible');
                },
                onStateChanged: (isVisible, isInForeground) {
                  debugPrint(
                      'State changed - Visible: $isVisible, Foreground: $isInForeground');
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.blueAccent,
                  child: const Center(
                    child: Text(
                      'Visibility Detector Widget\n(I will detect when I become visible/invisible)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 800),
              const Text(
                'Scroll back up to see the counter change!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
