import 'dart:io';

import 'package:args/args.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('output',
        abbr: 'o', help: 'Output directory', defaultsTo: 'lib')
    ..addOption('model-dir', help: 'Model directory', defaultsTo: 'model')
    ..addOption('dao-dir', help: 'DAO directory', defaultsTo: 'dao')
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

  try {
    final results = parser.parse(args);

    if (results['help'] == true) {
      _showHelp(parser);
      return;
    }

    if (results.rest.isEmpty) {
      print('Error: No command specified.');
      _showHelp(parser);
      exit(1);
    }

    final command = results.rest[0];

    if (command == 'create') {
      await _handleCreateCommand(results);
    } else if (command == 'help') {
      _showHelp(parser);
    } else {
      print('Error: Unknown command "$command".');
      _showHelp(parser);
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _showHelp(ArgParser parser) {
  print('''
Litebase Code Generator

Usage: litebase_gen <command> [arguments]

Commands:
  create    Generate model and DAO files
  help      Show this help message

Examples:
  litebase_gen create user name:String email:String age:int
  litebase_gen create product title:String price:double --output lib/generated
  litebase_gen create order userId:int total:double createdAt:DateTime

Field Types:
  int       - Integer
  double    - Double
  String    - String
  bool      - Boolean
  DateTime  - DateTime (stored as String)

Options:
${parser.usage}
''');
}

Future<void> _handleCreateCommand(ArgResults results) async {
  final rest = results.rest;

  if (rest.length < 3) {
    print('Error: Not enough arguments for create command.');
    print('Usage: litebase_gen create <modelName> <fieldName:type> ...');
    exit(1);
  }

  final modelName = rest[1];
  final fields = rest.sublist(2);
  final outputDir = results['output'] as String;
  final modelDir = results['model-dir'] as String;
  final daoDir = results['dao-dir'] as String;

  // 验证模型名称
  if (!_isValidModelName(modelName)) {
    print(
        'Error: Invalid model name "$modelName". Model name must start with a letter and contain only letters, numbers, and underscores.');
    exit(1);
  }

  final parsedFields = <_Field>[];

  for (var f in fields) {
    final parts = f.split(':');
    if (parts.length != 2) {
      print('Error: Invalid field format: $f');
      print('Expected format: fieldName:type');
      exit(1);
    }

    final fieldName = parts[0];
    final fieldType = parts[1];

    if (!_isValidFieldName(fieldName)) {
      print(
          'Error: Invalid field name "$fieldName". Field name must start with a letter and contain only letters, numbers, and underscores.');
      exit(1);
    }

    if (!_isValidFieldType(fieldType)) {
      print('Error: Invalid field type "$fieldType".');
      print('Supported types: int, double, String, bool, DateTime');
      exit(1);
    }

    parsedFields.add(_Field(fieldName, fieldType));
  }

  // 检查是否已有id字段
  final hasIdField = parsedFields.any((f) => f.name == 'id');
  if (!hasIdField) {
    parsedFields.insert(0, _Field('id', 'int'));
  }

  try {
    // 生成 Model 和 Dao 内容
    final modelContent = _generateModel(modelName, parsedFields);
    final daoContent = _generateDao(modelName, parsedFields);

    // 创建文件夹
    final modelOutputDir = Directory('$outputDir/$modelDir');
    final daoOutputDir = Directory('$outputDir/$daoDir');

    if (!modelOutputDir.existsSync())
      modelOutputDir.createSync(recursive: true);
    if (!daoOutputDir.existsSync()) daoOutputDir.createSync(recursive: true);

    // 写文件
    final modelFile =
        File('$outputDir/$modelDir/${modelName.toLowerCase()}.dart');
    final daoFile =
        File('$outputDir/$daoDir/${modelName.toLowerCase()}_dao.dart');

    // 检查文件是否已存在
    if (modelFile.existsSync()) {
      print('Warning: Model file already exists: ${modelFile.path}');
      print('Skipping model generation...');
    } else {
      modelFile.writeAsStringSync(modelContent);
      print('✔ Generated: ${modelFile.path}');
    }

    if (daoFile.existsSync()) {
      print('Warning: DAO file already exists: ${daoFile.path}');
      print('Skipping DAO generation...');
    } else {
      daoFile.writeAsStringSync(daoContent);
      print('✔ Generated: ${daoFile.path}');
    }

    // 输出建表语句
    final createTableSql = _generateCreateTableSql(modelName, parsedFields);
    print('\n📋 SQL CREATE TABLE statement:');
    print(createTableSql);

    // 输出使用示例
    _printUsageExample(modelName, parsedFields);
  } catch (e) {
    print('Error generating files: $e');
    exit(1);
  }
}

class _Field {
  final String name;
  final String type;

  _Field(this.name, this.type);
}

String _generateModel(String modelName, List<_Field> fields) {
  final buffer = StringBuffer();
  final className = _capitalize(modelName);

  buffer.writeln("import 'package:litebase/litebase.dart';");
  buffer.writeln();
  // 添加文件头注释
  buffer.writeln('/// Generated by litebase_gen');
  buffer.writeln('/// Model: $className');
  buffer.writeln('/// Generated at: ${DateTime.now().toIso8601String()}');
  buffer.writeln('class $className extends DbModel {');

  // 字段定义
  for (final field in fields) {
    final dartType = _mapType(field.type);
    final nullable = (field.name == 'id') ? '?' : '?';
    buffer.writeln('  final $dartType$nullable ${field.name};');
  }

  // 构造函数
  buffer.write('  $className({');
  for (final field in fields) {
    final req = (field.name == 'id') ? '' : 'required ';
    buffer.write('$req this.${field.name},');
  }
  buffer.writeln('});\n');

  // toMap 方法
  buffer.writeln('  @override');
  buffer.writeln('  Map<String, dynamic> toMap() => {');
  for (final field in fields) {
    if (field.type == 'DateTime') {
      buffer.writeln("    '${field.name}': ${field.name}?.toIso8601String(),");
    } else {
      buffer.writeln("    '${field.name}': ${field.name},");
    }
  }
  buffer.writeln('  };');

  // fromMap 静态方法
  buffer.writeln();
  buffer.writeln(
      '  static $className fromMap(Map<String, dynamic> map) => $className(');
  for (final field in fields) {
    final cast = _castFromMap(field.type, "map['${field.name}']");
    buffer.writeln('    ${field.name}: $cast,');
  }
  buffer.writeln('  );');

  // toJson & fromJson
  buffer.writeln();
  buffer.writeln('  Map<String, dynamic> toJson() => toMap();');
  buffer.writeln();
  buffer.writeln(
      '  static $className fromJson(Map<String, dynamic> json) => fromMap(json);');

  // 添加copyWith方法
  buffer.writeln();
  buffer.writeln('  $className copyWith({');
  for (final field in fields) {
    final dartType = _mapType(field.type);
    final nullable = (field.name == 'id') ? '?' : '?';
    buffer.writeln('    $dartType$nullable ${field.name},');
  }
  buffer.writeln('  }) => $className(');
  for (final field in fields) {
    buffer.writeln('    ${field.name}: ${field.name} ?? this.${field.name},');
  }
  buffer.writeln('  );');

  // 添加toString方法
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  String toString() => \'\'\'$className(\'');
  for (int i = 0; i < fields.length; i++) {
    final field = fields[i];
    final comma = i < fields.length - 1 ? ',' : '';
    buffer.writeln('    ${field.name}: \$${field.name}$comma');
  }
  buffer.writeln('  )\'\'\';');

  buffer.writeln('}');

  return buffer.toString();
}

String _generateDao(String modelName, List<_Field> fields) {
  final className = _capitalize(modelName);
  final daoName = '${className}Dao';
  final tableName = modelName.toLowerCase();
  final fileName = modelName.toLowerCase();

  return '''import '../model/$fileName.dart';
import 'package:litebase/litebase.dart';

/// Generated by litebase_gen
/// DAO: $daoName
/// Generated at: ${DateTime.now().toIso8601String()}
class $daoName extends BaseDao<$className> {
  @override
  String get tableName => '$tableName';

  @override
  $className fromMap(Map<String, dynamic> map) => $className.fromMap(map);

  /// 根据ID查询
  Future<$className?> findById(int id) async {
    final results = await queryWhere('id = ?', [id]);
    return results.isNotEmpty ? results.first : null;
  }

  /// 根据字段查询
  Future<List<$className>> findByField(String fieldName, dynamic value) async {
    return await queryWhere('\$fieldName = ?', [value]);
  }

  /// 更新指定ID的记录
  Future<int> updateById(int id, $className model) async {
    return await update(model, 'id = ?', [id]);
  }

  /// 删除指定ID的记录
  Future<int> deleteById(int id) async {
    return await delete('id = ?', [id]);
  }
}
''';
}

String _generateCreateTableSql(String modelName, List<_Field> fields) {
  final tableName = modelName.toLowerCase();
  final buffer = StringBuffer();

  buffer.writeln('-- Generated by litebase_gen');
  buffer.writeln('-- Table: $tableName');
  buffer.writeln('-- Generated at: ${DateTime.now().toIso8601String()}');
  buffer.writeln();
  buffer.write('CREATE TABLE $tableName (');

  final defs = fields.map((f) {
    final sqlType = _mapSqlType(f.type);
    if (f.name == 'id') {
      return '${f.name} INTEGER PRIMARY KEY AUTOINCREMENT';
    }
    return '${f.name} $sqlType';
  }).join(', ');

  buffer.write(defs);
  buffer.write(');');

  return buffer.toString();
}

void _printUsageExample(String modelName, List<_Field> fields) {
  final className = _capitalize(modelName);
  final daoName = '${className}Dao';

  print('\n📖 Usage Example:');
  print('''
// 1. 创建DAO实例
final ${modelName.toLowerCase()}Dao = $daoName();

// 2. 创建模型实例
final ${modelName.toLowerCase()} = $className(
${fields.where((f) => f.name != 'id').map((f) => '  ${f.name}: ${_getExampleValue(f.type)},').join('\n')}
);

// 3. 插入数据
final id = await ${modelName.toLowerCase()}Dao.insert(${modelName.toLowerCase()});
print('Inserted with ID: \$id');

// 4. 查询数据
final all${className}s = await ${modelName.toLowerCase()}Dao.queryAll();
final ${modelName.toLowerCase()}ById = await ${modelName.toLowerCase()}Dao.findById(1);

// 5. 更新数据
await ${modelName.toLowerCase()}Dao.updateById(1, ${modelName.toLowerCase()}.copyWith(
  // 更新字段
));

// 6. 删除数据
await ${modelName.toLowerCase()}Dao.deleteById(1);
''');
}

String _getExampleValue(String type) {
  switch (type.toLowerCase()) {
    case 'int':
      return '1';
    case 'double':
      return '99.99';
    case 'string':
      return "'example'";
    case 'bool':
      return 'true';
    case 'datetime':
      return 'DateTime.now()';
    default:
      return 'null';
  }
}

String _mapType(String type) {
  switch (type.toLowerCase()) {
    case 'int':
      return 'int';
    case 'double':
      return 'double';
    case 'string':
      return 'String';
    case 'bool':
      return 'bool';
    case 'datetime':
      return 'DateTime';
    default:
      return 'dynamic';
  }
}

String _mapSqlType(String type) {
  switch (type.toLowerCase()) {
    case 'int':
      return 'INTEGER';
    case 'double':
      return 'REAL';
    case 'string':
      return 'TEXT';
    case 'bool':
      return 'INTEGER'; // 0 or 1
    case 'datetime':
      return 'TEXT'; // ISO8601 string
    default:
      return 'TEXT';
  }
}

String _castFromMap(String type, String expr) {
  switch (type.toLowerCase()) {
    case 'int':
      return '$expr as int?';
    case 'double':
      return '($expr as num?)?.toDouble()';
    case 'string':
      return '$expr as String?';
    case 'bool':
      return '($expr as int?) == 1';
    case 'datetime':
      return '$expr != null ? DateTime.parse($expr as String) : null';
    default:
      return expr;
  }
}

bool _isValidModelName(String name) {
  return RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(name);
}

bool _isValidFieldName(String name) {
  return RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(name);
}

bool _isValidFieldType(String type) {
  const validTypes = ['int', 'double', 'String', 'bool', 'DateTime'];
  return validTypes.contains(type);
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
