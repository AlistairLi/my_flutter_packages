import 'package:double_back_to_home/double_back_to_home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DoubleBackToHome(
      onFirstBack: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Press back again to go to the home screen'),
              duration: Duration(milliseconds: 1600),
            ),
          );
      },
      onError: (error, stackTrace) {
        debugPrint('Could not open the Android home screen: $error');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Double Back to Home')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'On Android, press the back button twice within 1.6 seconds '
                  'to send this app to the background.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
