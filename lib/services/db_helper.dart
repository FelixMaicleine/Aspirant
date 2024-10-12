import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE roles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      role_id INTEGER,
      FOREIGN KEY (role_id) REFERENCES roles (id)
    )
    ''');

    await db.insert('roles', {'name': 'admin'});
    await db.insert('roles', {'name': 'user'});

    await db.insert(
        'users', {'username': 'admin', 'password': 'admin123', 'role_id': 1});

    await db.insert(
        'users', {'username': 'user', 'password': 'user123', 'role_id': 2});
  }

  Future<int> createUser(String username, String password, int roleId) async {
    final db = await instance.database;
    final data = {
      'username': username,
      'password': password,
      'role_id': roleId
    };
    return await db.insert('users', data);
  }

  Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<Map<String, dynamic>?> getRoleById(int roleId) async {
    final db = await instance.database;

    final result = await db.query(
      'roles',
      where: 'id = ?',
      whereArgs: [roleId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}
