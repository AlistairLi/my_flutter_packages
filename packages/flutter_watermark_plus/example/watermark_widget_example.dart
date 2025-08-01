import 'package:flutter/material.dart';
import 'package:flutter_watermark_plus/flutter_watermark_plus.dart';

/// Example application demonstrating the Flutter Watermark Plus package
///
/// This example shows various ways to use the watermark functionality
/// with different configurations and use cases.
void main() {
  runApp(const WatermarkExampleApp());
}

/// Main application widget
class WatermarkExampleApp extends StatelessWidget {
  const WatermarkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Watermark Plus Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WatermarkExamplePage(),
    );
  }
}

/// Example page showing different watermark configurations
class WatermarkExamplePage extends StatefulWidget {
  const WatermarkExamplePage({super.key});

  @override
  State<WatermarkExamplePage> createState() => _WatermarkExamplePageState();
}

class _WatermarkExamplePageState extends State<WatermarkExamplePage> {
  String watermarkText = 'CONFIDENTIAL';
  double opacity = 0.2;
  double rotation = -0.785; // -45 degrees in radians
  double horizontalInterval = 150.0;
  double verticalInterval = 150.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watermark Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls section
            _buildControls(),
            const SizedBox(height: 20),

            // Examples section
            _buildExamples(),
          ],
        ),
      ),
    );
  }

  /// Builds the controls for customizing watermark properties
  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Watermark Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Text input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Watermark Text',
                border: OutlineInputBorder(),
              ),
              // value: watermarkText,
              onChanged: (value) => setState(() => watermarkText = value),
            ),
            const SizedBox(height: 16),

            // Opacity slider
            Text('Opacity: ${(opacity * 100).round()}%'),
            Slider(
              value: opacity,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (value) => setState(() => opacity = value),
            ),

            // Rotation slider
            Text('Rotation: ${(rotation * 180 / 3.14159).round()}°'),
            Slider(
              value: rotation,
              min: -3.14159,
              max: 3.14159,
              divisions: 36,
              onChanged: (value) => setState(() => rotation = value),
            ),

            // Interval controls
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Horizontal Interval: ${horizontalInterval.round()}px'),
                      Slider(
                        value: horizontalInterval,
                        min: 50.0,
                        max: 300.0,
                        divisions: 25,
                        onChanged: (value) =>
                            setState(() => horizontalInterval = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vertical Interval: ${verticalInterval.round()}px'),
                      Slider(
                        value: verticalInterval,
                        min: 50.0,
                        max: 300.0,
                        divisions: 25,
                        onChanged: (value) =>
                            setState(() => verticalInterval = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the examples section showing different watermark configurations
  Widget _buildExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Watermark Examples',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Example 1: Basic watermark
        _buildExampleCard(
          'Basic Watermark',
          'Simple watermark with default settings',
          TextWatermarkWidget(
            text: watermarkText,
            config: Config(
              rotationAngle: rotation,
              horizontalInterval: horizontalInterval,
              verticalInterval: verticalInterval,
            ),
            child: _buildSampleContent(),
          ),
        ),

        const SizedBox(height: 16),

        // Example 2: Colored watermark
        _buildExampleCard(
          'Colored Watermark',
          'Watermark with custom color and larger font',
          TextWatermarkWidget(
            text: watermarkText,
            config: Config(
              textStyle: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              rotationAngle: rotation,
              horizontalInterval: horizontalInterval,
              verticalInterval: verticalInterval,
            ),
            child: _buildSampleContent(),
          ),
        ),

        const SizedBox(height: 16),

        // Example 3: Diagonal watermark
        _buildExampleCard(
          'Diagonal Watermark',
          'Watermark with 45-degree rotation',
          TextWatermarkWidget(
            text: watermarkText,
            config: Config(
              rotationAngle: 0.785, // 45 degrees
              horizontalInterval: horizontalInterval,
              verticalInterval: verticalInterval,
            ),
            child: _buildSampleContent(),
          ),
        ),

        const SizedBox(height: 16),

        // Example 4: Dense watermark
        _buildExampleCard(
          'Dense Watermark',
          'Watermark with smaller intervals for dense coverage',
          TextWatermarkWidget(
            text: watermarkText,
            config: Config(
              rotationAngle: rotation,
              horizontalInterval: 80,
              verticalInterval: 80,
            ),
            child: _buildSampleContent(),
          ),
        ),

        const SizedBox(height: 16),

        // Example 5: Image with watermark
        _buildExampleCard(
          'Image with Watermark',
          'Watermark applied to an image',
          TextWatermarkWidget(
            text: watermarkText,
            config: Config(
              rotationAngle: rotation,
              horizontalInterval: horizontalInterval,
              verticalInterval: verticalInterval,
            ),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an example card with title, description, and content
  Widget _buildExampleCard(String title, String description, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds sample content for watermark examples
  Widget _buildSampleContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Sample Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              'This content has a watermark overlay',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
