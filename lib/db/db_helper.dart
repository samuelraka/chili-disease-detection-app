import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'models/detection_record.dart';

class DBHelper {
  static Database? _db;

  static const String tableName = 'detection_records';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'detection.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT,
            disease TEXT,
            confidence REAL,
            date TEXT,
            symptoms TEXT,
            prevention TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertRecord(DetectionRecord record) async {
    final db = await database;
    return await db.insert(tableName, record.toMap());
  }

  static Future<List<DetectionRecord>> getAllRecords() async {
    final db = await database;
    final result = await db.query(tableName, orderBy: 'id DESC');
    return result.map((map) => DetectionRecord.fromMap(map)).toList();
  }

  static Future<List<DetectionRecord>> getRecentRecords({int limit = 3}) async {
    final db = await database;
    final result = await db.query(
      tableName,
      orderBy: 'date DESC',
      limit: limit,
    );
    return result.map((map) => DetectionRecord.fromMap(map)).toList();
  } 

  static Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllRecords() async {
    final db = await database;
    await db.delete(tableName);
  }
}
