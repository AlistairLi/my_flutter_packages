import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresh_list/smart_refresh_list.dart';

void main() {
  group('AppRefresh Tests', () {
    testWidgets('AppRefreshList should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SmartRefreshList<String>(
              onRefresh: () async => PageData(
                data: ['test'],
                page: 1,
                pageSize: 20,
              ),
              onLoad: (page) async =>
                  PageData(data: [], page: page, pageSize: 20),
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      expect(find.byType(SmartRefreshList<String>), findsOneWidget);
    });

    test('AppRefreshController should initialize correctly', () {
      final controller = SmartRefreshController<String>();

      expect(controller.dataList, isEmpty);
      expect(controller.currentPage, equals(1));
      expect(controller.isEmpty, isTrue);
      expect(controller.length, equals(0));
    });

    test('AppRefreshController should manage data correctly', () {
      final controller = SmartRefreshController<String>();
      final testData = ['item1', 'item2', 'item3'];

      controller.setData(testData);
      expect(controller.dataList, equals(testData));
      expect(controller.length, equals(3));
      expect(controller.isEmpty, isFalse);

      controller.addData(['item4', 'item5']);
      expect(controller.length, equals(5));

      controller.clearData();
      expect(controller.dataList, isEmpty);
      expect(controller.currentPage, equals(1));
    });

    test('AppRefreshController should handle refresh states', () {
      final controller = SmartRefreshController<String>();

      controller.finishRefresh(success: true);

      controller.finishRefresh(success: false);
    });

    test('AppRefreshController should handle load states', () {
      final controller = SmartRefreshController<String>();

      controller.finishLoad(success: true);

      controller.finishLoad(noMore: true);
    });

    test('PageData should work correctly', () {
      final data = ['item1', 'item2'];
      final pageData = PageData(
        data: data,
        page: 1,
        pageSize: 20,
      );

      expect(pageData.data, equals(data));
      expect(pageData.page, equals(1));
      expect(pageData.pageSize, equals(20));
      expect(pageData.getHasMore(), isTrue);

      final emptyPageData = PageData.empty();
      expect(emptyPageData.data, isEmpty);
      expect(emptyPageData.page, equals(1));
      expect(emptyPageData.pageSize, equals(20));
      expect(emptyPageData.getHasMore(), isFalse);
    });

    test('RefreshStyleConfig should work correctly', () {
      final config = RefreshStyleConfig(
        primaryColor: Colors.red,
        backgroundColor: Colors.blue,
      );

      expect(config.primaryColor, equals(Colors.red));
      expect(config.backgroundColor, equals(Colors.blue));
      expect(config.enableOverScroll, isTrue);

      final newConfig = config.copyWith(enableOverScroll: false);
      expect(newConfig.enableOverScroll, isFalse);
      expect(newConfig.primaryColor,
          equals(Colors.red)); // Should preserve other values
    });
  });
}
