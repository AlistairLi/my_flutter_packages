import 'package:firebase_bootstrap_plus/firebase_bootstrap_plus.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  await FirebaseInitializer.initFireBase();
  // ...
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
