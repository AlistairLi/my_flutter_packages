import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresh_list/smart_refresh_list.dart';

void main() {
  group('SmartRefreshGrid Tests', () {
    testWidgets('SmartRefreshGrid should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRefreshGrid<String>(
              onRefresh: () async => PageData(
                data: ['test1', 'test2', 'test3'],
                page: 1,
                pageSize: 20,
              ),
              onLoad: (page) async => PageData(
                data: [],
                page: page,
                pageSize: 20,
              ),
              itemBuilder: (context, item, index) => Card(
                child: Center(child: Text(item)),
              ),
              crossAxisCount: 2,
            ),
          ),
        ),
      );

      expect(find.byType(SmartRefreshGrid<String>), findsOneWidget);
    });

    testWidgets('SmartRefreshGrid should handle custom grid delegate',
        (WidgetTester tester) async {
      final customDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRefreshGrid<String>(
              onRefresh: () async => PageData(
                data: ['test1', 'test2', 'test3'],
                page: 1,
                pageSize: 20,
              ),
              onLoad: (page) async => PageData(
                data: [],
                page: page,
                pageSize: 20,
              ),
              itemBuilder: (context, item, index) => Card(
                child: Center(child: Text(item)),
              ),
              gridDelegate: customDelegate,
            ),
          ),
        ),
      );

      expect(find.byType(SmartRefreshGrid<String>), findsOneWidget);
    });

    testWidgets('SmartRefreshGrid should handle maxCrossAxisExtent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRefreshGrid<String>(
              onRefresh: () async => PageData(
                data: ['test1', 'test2', 'test3'],
                page: 1,
                pageSize: 20,
              ),
              onLoad: (page) async => PageData(
                data: [],
                page: page,
                pageSize: 20,
              ),
              itemBuilder: (context, item, index) => Card(
                child: Center(child: Text(item)),
              ),
              maxCrossAxisExtent: 150.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
          ),
        ),
      );

      expect(find.byType(SmartRefreshGrid<String>), findsOneWidget);
    });

    testWidgets('SmartRefreshGrid should handle mainAxisExtent',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRefreshGrid<String>(
              onRefresh: () async => PageData(
                data: ['test1', 'test2', 'test3'],
                page: 1,
                pageSize: 20,
              ),
              onLoad: (page) async => PageData(
                data: [],
                page: page,
                pageSize: 20,
              ),
              itemBuilder: (context, item, index) => Card(
                child: Center(child: Text(item)),
              ),
              crossAxisCount: 2,
              mainAxisExtent: 120.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
          ),
        ),
      );

      expect(find.byType(SmartRefreshGrid<String>), findsOneWidget);
    });
  });
} 