import 'package:sqflite/sqflite.dart';

/// 迁移支持
typedef Migration = Future<void> Function(
  Database db,
  int oldVersion,
  int newVersion,
);
