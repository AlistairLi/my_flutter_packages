import 'package:dart_extensions_kit/dart_extensions_kit.dart';
import 'package:test/test.dart';

void main() {
  group('String Extensions', () {
    test('capitalize should work correctly', () {
      expect('hello'.capitalize, equals('Hello'));
      expect(''.capitalize, equals(''));
    });

    test('isEmail should work correctly', () {
      expect('test@example.com'.isEmail, isTrue);
      expect('invalid-email'.isEmail, isFalse);
    });
    List<String> phoneNumbers = [
      '1234567890',
      '12345678901',
      '123456789012',
      '1234567890123',
      '12345678901234',
      '123456789012345',
      '1234567890123456',
    ];
  });

  group('List Extensions', () {
    List<String> phoneNumbers = [
      '1234567890',
      '1234567890',
      '12345678901',
      '123456789012',
      '1234567890123',
      '12345678901234',
      '123456789012345',
      '1234567890123456',
    ];
    test('distinct', () {
      expect(phoneNumbers.distinct, isNot(equals(phoneNumbers)));
    });

    // List<(String, String)> userList = [
    //   ("用户ID1", "用户名1"),
    //   ("用户ID1", "用户名1"),
    //   ("用户ID2", "用户名2"),
    //   ("用户ID3", "用户名3"),
    // ];
    // test('distinctBy', () {
    //   expect(userList.distinctBy((e) {
    //     return e.$1;
    //   }), isNot(equals(userList)));
    // });

    List? nullList;
    test('List EmptyOrNull', () {
      expect(nullList.isEmptyOrNull, isTrue);
      expect(nullList.isNotEmptyOrNull, isFalse);
    });

    Map<String, dynamic>? nullMap;
    test('Map EmptyOrNull', () {
      expect(nullMap.isEmptyOrNull, isTrue);
      expect(nullMap.isNotEmptyOrNull, isFalse);
    });
  });

  num n = 1;
  int i = 1;
  double d = 1.0;
  group('Number Extensions', () {
    test('Number Extensions', () {
      print(8.toFileSize);
      print(1024.toFileSize);
      print((1024 * 1024).toFileSize);
      print((1024 * 1024 * 1024).toFileSize);
      print((1024 * 1024 * 1024 * 1024).toFileSize);
    });
  });

  group('bool Extensions', () {
    bool? nB;
    bool b = true;
    bool bf = false;
    test('bool Extensions', () {
      print(nB.isTrue);
      print(b.isTrue);
      print(bf.isTrue);
    });
  });
}
