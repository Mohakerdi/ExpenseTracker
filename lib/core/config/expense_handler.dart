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
          'CREATE TABLE expenses(id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, category TEXT)',
        );
      },
      version: 1,
    );
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
