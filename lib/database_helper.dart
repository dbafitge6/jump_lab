import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class JumpRecord {
  final int? id;
  final DateTime date;
  final double jump1;
  final double jump2;
  final double jump3;
  final double average;
  final double best;

  JumpRecord({
    this.id,
    required this.date,
    required this.jump1,
    required this.jump2,
    required this.jump3,
    required this.average,
    required this.best,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'jump1': jump1,
      'jump2': jump2,
      'jump3': jump3,
      'average': average,
      'best': best,
    };
  }

  factory JumpRecord.fromMap(Map<String, dynamic> map) {
    return JumpRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      jump1: map['jump1'],
      jump2: map['jump2'],
      jump3: map['jump3'],
      average: map['average'],
      best: map['best'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jumplab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        jump1 REAL NOT NULL,
        jump2 REAL NOT NULL,
        jump3 REAL NOT NULL,
        average REAL NOT NULL,
        best REAL NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(JumpRecord record) async {
    final db = await database;
    return await db.insert('records', record.toMap());
  }

  Future<List<JumpRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query('records', orderBy: 'date DESC');
    return maps.map((map) => JumpRecord.fromMap(map)).toList();
  }

  Future<JumpRecord?> getBestRecord() async {
    final db = await database;
    final maps = await db.query(
      'records',
      orderBy: 'best DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return JumpRecord.fromMap(maps.first);
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }
}
