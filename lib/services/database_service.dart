import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        label TEXT,
        debit REAL DEFAULT 0,
        credit REAL DEFAULT 0
      )
    ''');
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List<Transaction>.from(maps.map((map) => Transaction.fromMap(map)));
  }

  Future<void> importFromCsv(List<Transaction> transactions) async {
    final db = await database;
    final batch = db.batch();
    for (final t in transactions) {
      batch.insert('transactions', t.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<bool> isEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM transactions'),
    );
    return count == 0;
  }

  Future<List<String>> getAllCategories() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM transactions ORDER BY category',
    );
    return result.map((row) => row['category'] as String).toList();
  }
}
