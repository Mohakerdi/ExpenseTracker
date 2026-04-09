import 'dart:io';

import 'package:expense_tracker/models/expense.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ExpenseHandler {
  ExpenseHandler._();

  static final ExpenseHandler instance = ExpenseHandler._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      path.join(dbPath, 'expenses.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE expenses(id TEXT PRIMARY KEY, title TEXT NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, category TEXT NOT NULL, image_data BLOB)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2 && !await _columnExists(db, 'expenses', 'image_path')) {
          await db.execute(
            'ALTER TABLE expenses ADD COLUMN image_path TEXT',
          );
        }

        if (oldVersion < 3 && !await _columnExists(db, 'expenses', 'image_data')) {
          await db.execute(
            'ALTER TABLE expenses ADD COLUMN image_data BLOB',
          );
        }

        if (oldVersion < 3) {
          await _migrateLegacyImagePathData(db);
        }
      },
      version: 3,
    );
  }

  Future<bool> _columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
    return tableInfo.any((column) => column['name'] == columnName);
  }

  Future<void> _migrateLegacyImagePathData(Database db) async {
    final hasImagePath = await _columnExists(db, 'expenses', 'image_path');
    final hasImageData = await _columnExists(db, 'expenses', 'image_data');
    if (!hasImagePath || !hasImageData) {
      return;
    }

    final legacyRows = await db.query(
      'expenses',
      columns: ['id', 'image_path', 'image_data'],
      where: 'image_path IS NOT NULL AND image_path != "" AND image_data IS NULL',
    );

    for (final row in legacyRows) {
      final id = row['id'] as String?;
      final storedPath = row['image_path'] as String?;
      if (id == null || storedPath == null) {
        continue;
      }

      final imagePath = _resolveStoredImagePath(storedPath);
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        continue;
      }

      try {
        final imageBytes = await imageFile.readAsBytes();
        if (imageBytes.isEmpty) {
          continue;
        }

        await db.update(
          'expenses',
          {'image_data': imageBytes},
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (_) {
        continue;
      }
    }
  }

  String _resolveStoredImagePath(String storedPath) {
    final parsedUri = Uri.tryParse(storedPath);
    if (parsedUri != null && parsedUri.scheme == 'file') {
      return parsedUri.toFilePath();
    }
    return storedPath;
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final data = await db.query('expenses', orderBy: 'date DESC');
    return data.map(Expense.fromMap).toList();
  }

  Future<void> insertExpense(Expense expense) async {
    final db = await database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
