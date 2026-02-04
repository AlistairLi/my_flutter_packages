import 'package:firebase_bootstrap/firebase_bootstrap.dart';
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
