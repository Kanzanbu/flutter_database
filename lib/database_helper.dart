import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'demo.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertItem(Map<String, dynamic> item) async {
    return await _db!.insert('items', item);
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    return await _db!.query('items');
  }

  static Future<int> updateFirstItem(String newName) async {
    final items = await _db!.query('items', limit: 1);
    if (items.isEmpty) return 0;
    final id = items.first['id'] as int;
    return await _db!.update('items', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearItems() async {
    await _db!.delete('items');
  }
}
