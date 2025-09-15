# litebase_gen

A CLI tool to generate `litebase` model and DAO files.

## Features

- **Model Generation**: Generate complete Dart model classes extending `DbModel`
- **DAO Generation**: Generate DAO classes with full CRUD operations
- **SQL Generation**: Generate CREATE TABLE SQL statements
- **Type Safety**: Support for int, double, String, bool, DateTime types
- **Auto ID Field**: Automatically adds `id` field as primary key if not specified
- **Enhanced Methods**: Includes `copyWith`, `toString`, and custom query methods
- **Flexible Output**: Customizable output directories and file structure
- **Validation**: Input validation for model names and field types
- **Help System**: Comprehensive help and usage examples


## Installation

Add the dependency in your project's `pubspec.yaml`:

```yaml
dev_dependencies:
  litebase_gen: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## Quick Start

### Basic Usage

```bash
# Generate a user model with basic fields
dart run litebase_gen create user id:int name:String age:int

# Generate a product model with more complex fields
dart run litebase_gen create product title:String price:double description:String inStock:bool createdAt:DateTime
```

### Advanced Usage

```bash
# Custom output directory
dart run litebase_gen create category name:String --output lib/generated

# Custom model and DAO directories
dart run litebase_gen create tag name:String --model-dir models --dao-dir repositories

# Show help
dart run litebase_gen help
```

## Supported Field Types

| Type | Dart Type | SQL Type | Description |
|------|-----------|----------|-------------|
| `int` | `int` | `INTEGER` | Integer values |
| `double` | `double` | `REAL` | Floating point numbers |
| `String` | `String` | `TEXT` | Text strings |
| `bool` | `bool` | `INTEGER` | Boolean (0 or 1) |
| `DateTime` | `DateTime` | `TEXT` | ISO8601 formatted dates |

## Generated Code Structure

### Model Class

The generated model includes:

- **Fields**: All specified fields with proper types
- **Constructor**: Named constructor with required/optional parameters
- **toMap()**: Convert model to Map for database storage
- **fromMap()**: Create model from Map (database result)
- **toJson()/fromJson()**: JSON serialization methods
- **copyWith()**: Create modified copy of the model
- **toString()**: String representation for debugging

### DAO Class

The generated DAO includes:

- **Basic CRUD**: insert, update, delete, query operations
- **Custom Methods**: findById, findByField, updateById, deleteById
- **Batch Operations**: insertBatch, insertBatchInTransaction
- **Query Methods**: queryAll, queryWhere, queryPaged, count

## Examples

### Example 1: User Model

```bash
dart run litebase_gen create user name:String email:String age:int createdAt:DateTime
```

**Generated Model:**
```dart
class User extends DbModel {
  final int? id;
  final String name;
  final String email;
  final int age;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.createdAt,
  });

  // ... complete implementation
}
```

**Generated DAO:**
```dart
class UserDao extends BaseDao<User> {
  @override
  String get tableName => 'user';

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);

  Future<User?> findById(int id) async { /* ... */ }
  Future<List<User>> findByField(String fieldName, dynamic value) async { /* ... */ }
  Future<int> updateById(int id, User model) async { /* ... */ }
  Future<int> deleteById(int id) async { /* ... */ }
}
```

**Generated SQL:**
```sql
CREATE TABLE user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  email TEXT,
  age INTEGER,
  createdAt TEXT
);
```

### Example 2: Product Model

```bash
litebase_gen create product title:String price:double description:String inStock:bool
```

### Example 3: Order Model

```bash
litebase_gen create order userId:int productId:int quantity:int total:double status:String
```

## Usage in Your App

```dart
import 'package:litebase/litebase.dart';
import 'dao/user_dao.dart';
import 'model/user.dart';

void main() async {
  // Initialize database
  await DbManager.initialize();
  
  // Create DAO instance
  final userDao = UserDao();
  
  // Create and insert user
  final user = User(
    name: 'John Doe',
    email: 'john@example.com',
    age: 30,
    createdAt: DateTime.now(),
  );
  
  final id = await userDao.insert(user);
  print('User created with ID: $id');
  
  // Query users
  final allUsers = await userDao.queryAll();
  final userById = await userDao.findById(id);
  final usersByName = await userDao.findByField('name', 'John Doe');
  
  // Update user
  final updatedUser = user.copyWith(age: 31);
  await userDao.updateById(id, updatedUser);
  
  // Delete user
  await userDao.deleteById(id);
}
```

## Command Line Options

```bash
litebase_gen create <modelName> <fieldName:type> [options]

Options:
  -o, --output <dir>     Output directory (default: lib)
  --model-dir <dir>      Model directory (default: model)
  --dao-dir <dir>        DAO directory (default: dao)
  -h, --help             Show help
```

## File Structure

By default, the tool creates the following structure:

```
lib/
├── model/
│   └── user.dart          # Generated model
└── dao/
    └── user_dao.dart      # Generated DAO
```

With custom options:
```bash
dart run litebase_gen create user name:String --output lib/generated --model-dir models --dao-dir repositories
```

Creates:
```
lib/generated/
├── models/
│   └── user.dart
└── repositories/
    └── user_dao.dart
```

## Best Practices

1. **Naming Convention**: Use PascalCase for model names (e.g., `User`, `Product`)
2. **Field Names**: Use camelCase for field names (e.g., `firstName`, `createdAt`)
3. **Required Fields**: All fields except `id` are required by default
4. **DateTime Fields**: Use `DateTime` type for timestamps
5. **File Organization**: Keep models and DAOs in separate directories

## Troubleshooting

### Common Issues

1. **Invalid model name**: Model names must start with a letter and contain only letters, numbers, and underscores
2. **Invalid field type**: Use only supported types: `int`, `double`, `String`, `bool`, `DateTime`
3. **File already exists**: The tool will skip generation if files already exist

### Error Messages

- `Invalid model name`: Check that the model name follows naming conventions
- `Invalid field format`: Use `fieldName:type` format
- `Invalid field type`: Use only supported field types
- `File already exists`: Remove existing files or use different names

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License