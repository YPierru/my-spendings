import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/balance.dart';
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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
    await db.execute('''
      CREATE TABLE balance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE balance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final batch = db.batch();
    for (final t in _initialTransactions) {
      batch.insert('transactions', {
        'date': t[0],
        'category': t[1],
        'label': t[2],
        'debit': t[3],
        'credit': t[4],
      });
    }
    await batch.commit(noResult: true);
  }

  static const List<List<dynamic>> _initialTransactions = [
    ['2025-01-02T00:00:00.000', 'Protonmail', 'protonmail', 4.99, 0.0],
    ['2025-01-02T00:00:00.000', 'Amazon', 'livre', 7.49, 0.0],
    ['2025-01-02T00:00:00.000', 'Variable', 'liévin 2025', 64.0, 0.0],
    ['2025-01-03T00:00:00.000', 'Protonmail', 'protonmail', 8.01, 0.0],
    ['2025-01-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-01-06T00:00:00.000', 'Amazon', 'piles', 5.12, 0.0],
    ['2025-01-06T00:00:00.000', 'Variable', 'sg appro', 10.0, 0.0],
    ['2025-01-06T00:00:00.000', 'Variable', 'ovh', 15.59, 0.0],
    ['2025-01-06T00:00:00.000', 'Amazon', 'tel', 140.0, 0.0],
    ['2025-01-06T00:00:00.000', 'LMNP', 'appro', 125.59, 0.0],
    ['2025-01-08T00:00:00.000', 'Amazon', 'support maman', 11.39, 0.0],
    ['2025-01-09T00:00:00.000', 'Spotify', 'spotify', 11.12, 0.0],
    ['2025-01-09T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-01-10T00:00:00.000', 'Variable', 'resto onor', 190.0, 0.0],
    ['2025-01-14T00:00:00.000', 'Variable', 'courses', 42.1, 0.0],
    ['2025-01-15T00:00:00.000', 'Amazon', 'livre', 3.49, 0.0],
    ['2025-01-17T00:00:00.000', 'Adyen', 'uber eat AMS', 23.08, 0.0],
    ['2025-01-20T00:00:00.000', 'Cpt Joint', 'appro', 45.0, 0.0],
    ['2025-01-21T00:00:00.000', 'Variable', 'cheque noel', 80.0, 0.0],
    ['2025-01-21T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-01-22T00:00:00.000', 'Adyen', 'rbt', 0.0, 39.0],
    ['2025-01-23T00:00:00.000', 'Amazon', 'livre', 7.49, 0.0],
    ['2025-01-23T00:00:00.000', 'Coiffeur', 'coiffeur', 8.0, 0.0],
    ['2025-01-23T00:00:00.000', 'Sport', 'rouvy', 16.49, 0.0],
    ['2025-01-25T00:00:00.000', 'Salaire', 'salaire', 0.0, 4371.65],
    ['2025-01-27T00:00:00.000', 'Sport', 'alltricks', 13.88, 0.0],
    ['2025-01-27T00:00:00.000', 'Téléphone', 'sosh', 20.99, 0.0],
    ['2025-01-27T00:00:00.000', 'Variable', 'sauces piquantes', 44.0, 0.0],
    ['2025-01-27T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-01-27T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-01-27T00:00:00.000', 'Variable', 'chaussures', 193.0, 0.0],
    ['2025-01-27T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-01-27T00:00:00.000', 'LMNP', 'lmnp', 575.0, 0.0],
    ['2025-01-27T00:00:00.000', 'Cpt Joint', 'appro budget', 1000.0, 0.0],
    ['2025-01-27T00:00:00.000', 'Economies', 'économies', 1300.0, 0.0],
    ['2025-01-28T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-01-28T00:00:00.000', 'Variable', 'google one', 19.99, 0.0],
    ['2025-01-29T00:00:00.000', 'Variable', 'cyclo cross', 0.0, 15.0],
    ['2025-01-31T00:00:00.000', 'Amazon', 'livre', 7.49, 0.0],
    ['2025-02-03T00:00:00.000', 'Amazon', 'telephone', 139.99, 0.0],
    ['2025-02-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-02-03T00:00:00.000', 'Coiffeur', 'coiffeur', 24.0, 0.0],
    ['2025-02-04T00:00:00.000', 'Variable', 'bonnet UCI', 30.54, 0.0],
    ['2025-02-10T00:00:00.000', 'Economies', 'appro', 0.0, 350.0],
    ['2025-02-10T00:00:00.000', 'Variable', 'kdo manon', 16.48, 0.0],
    ['2025-02-10T00:00:00.000', 'Sport', 'D4 gels/barres', 20.97, 0.0],
    ['2025-02-10T00:00:00.000', 'Cpt Joint', 'voiture et edf', 450.0, 0.0],
    ['2025-02-11T00:00:00.000', 'Amazon', 'livre', 7.49, 0.0],
    ['2025-02-11T00:00:00.000', 'Spotify', 'spotify', 11.12, 0.0],
    ['2025-02-14T00:00:00.000', 'Variable', 'vente leboncoin', 0.0, 125.0],
    ['2025-02-17T00:00:00.000', 'Variable', 'google one', 5.99, 0.0],
    ['2025-02-17T00:00:00.000', 'Cpt Joint', 'appro', 125.0, 0.0],
    ['2025-02-18T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-02-18T00:00:00.000', 'Amazon', 'livre', 7.49, 0.0],
    ['2025-02-19T00:00:00.000', 'Variable', 'franprix', 3.59, 0.0],
    ['2025-02-23T00:00:00.000', 'Santé', 'compléments alimentaires', 39.0, 0.0],
    ['2025-02-23T00:00:00.000', 'Variable', 'bexley', 42.0, 0.0],
    ['2025-02-23T00:00:00.000', 'Sport', 'lunettes vélo', 169.98, 0.0],
    ['2025-02-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4371.65],
    ['2025-02-25T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-02-25T00:00:00.000', 'Sport', 'rouvy', 16.49, 0.0],
    ['2025-02-25T00:00:00.000', 'Téléphone', 'sosh', 20.99, 0.0],
    ['2025-02-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-02-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-02-25T00:00:00.000', 'Cpt Joint', 'charges', 450.0, 0.0],
    ['2025-02-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-02-25T00:00:00.000', 'LMNP', 'lmnp', 575.0, 0.0],
    ['2025-02-25T00:00:00.000', 'Cpt Joint', 'appro variable', 1000.0, 0.0],
    ['2025-02-25T00:00:00.000', 'Economies', 'economies', 1000.0, 0.0],
    ['2025-02-26T00:00:00.000', 'Variable', 'rbt undiz', 0.0, 13.49],
    ['2025-02-27T00:00:00.000', 'Variable', 'appro bourso', 10.0, 0.0],
    ['2025-02-28T00:00:00.000', 'Amazon', 'amazon maman', 16.49, 0.0],
    ['2025-02-28T00:00:00.000', 'Variable', 'bar bieres AMS', 22.8, 0.0],
    ['2025-02-28T00:00:00.000', 'Adyen', 'diner ams', 22.97, 0.0],
    ['2025-02-28T00:00:00.000', 'Adyen', 'diner ams', 70.0, 0.0],
    // March
    ['2025-03-03T00:00:00.000', 'Amazon', 'livre', 7.49, 0.0],
    ['2025-03-06T00:00:00.000', 'Adyen', 'expense', 0.0, 92.97],
    ['2025-03-06T00:00:00.000', 'Variable', 'rbt maman', 0.0, 17.0],
    ['2025-03-07T00:00:00.000', 'Variable', 'super U boulot', 2.27, 0.0],
    ['2025-03-07T00:00:00.000', 'Sport', 'cintre vélo', 58.43, 0.0],
    ['2025-03-10T00:00:00.000', 'Spotify', 'spotify', 11.12, 0.0],
    ['2025-03-10T00:00:00.000', 'Sport', 'rapha', 112.0, 0.0],
    ['2025-03-11T00:00:00.000', 'Variable', 'adyen', 0.1, 0.0],
    ['2025-03-11T00:00:00.000', 'Amazon', 'livre', 7.99, 0.0],
    ['2025-03-14T00:00:00.000', 'Variable', 'sg appro', 37.44, 0.0],
    ['2025-03-17T00:00:00.000', 'Sport', 'support compteur', 40.0, 0.0],
    ['2025-03-18T00:00:00.000', 'Amazon', 'filtres aspi', 42.98, 0.0],
    ['2025-03-18T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-03-23T00:00:00.000', 'Amazon', 'livre', 7.99, 0.0],
    ['2025-03-23T00:00:00.000', 'Téléphone', 'sosh', 20.99, 0.0],
    ['2025-03-23T00:00:00.000', 'Cpt Joint', 'appro', 45.97, 0.0],
    ['2025-03-23T00:00:00.000', 'Sport', 'entretien velo', 151.1, 0.0],
    ['2025-03-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4804.29],
    ['2025-03-25T00:00:00.000', 'Sport', 'rouvy', 16.49, 0.0],
    ['2025-03-25T00:00:00.000', 'Santé', 'pharmacie', 16.85, 0.0],
    ['2025-03-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-03-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-03-25T00:00:00.000', 'Variable', 'vin', 110.06, 0.0],
    ['2025-03-25T00:00:00.000', 'Cpt Joint', 'charges', 450.0, 0.0],
    ['2025-03-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-03-25T00:00:00.000', 'LMNP', 'lmnp', 575.0, 0.0],
    ['2025-03-25T00:00:00.000', 'Cpt Joint', 'appro', 1000.0, 0.0],
    ['2025-03-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-03-26T00:00:00.000', 'Sport', 'pneus', 141.85, 0.0],
    ['2025-03-27T00:00:00.000', 'Variable', 'surclassement eurostar', 20.0, 0.0],
    ['2025-03-31T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-03-31T00:00:00.000', 'Adyen', 'diner ams', 22.67, 0.0],
    ['2025-03-31T00:00:00.000', 'Sport', 'D4', 58.96, 0.0],
    // April
    ['2025-04-01T00:00:00.000', 'Variable', 'appro bourso', 20.0, 0.0],
    ['2025-04-02T00:00:00.000', 'Adyen', 'uk metro', 15.88, 0.0],
    ['2025-04-02T00:00:00.000', 'Adyen', 'diner londre', 139.16, 0.0],
    ['2025-04-02T00:00:00.000', 'Variable', 'vente leboncoin', 0.0, 120.0],
    ['2025-04-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-04-04T00:00:00.000', 'Adyen', 'uk metro', 8.54, 0.0],
    ['2025-04-04T00:00:00.000', 'Adyen', 'uk metro', 15.82, 0.0],
    ['2025-04-07T00:00:00.000', 'Economies', 'economies', 0.0, 539.1],
    ['2025-04-07T00:00:00.000', 'Variable', 'parking', 1.6, 0.0],
    ['2025-04-07T00:00:00.000', 'Variable', 'bar st quentin', 18.1, 0.0],
    ['2025-04-07T00:00:00.000', 'Adyen', 'uk metro', 32.86, 0.0],
    ['2025-04-07T00:00:00.000', 'Variable', 'compléments alimentaires', 41.99, 0.0],
    ['2025-04-07T00:00:00.000', 'Variable', 'leboncoin cafetiere', 120.89, 0.0],
    ['2025-04-07T00:00:00.000', 'Variable', 'leboncoin moulin', 110.49, 0.0],
    ['2025-04-07T00:00:00.000', 'Variable', 'vente porte velo', 0.0, 220.0],
    ['2025-04-07T00:00:00.000', 'LMNP', 'loyers Q1', 0.0, 955.15],
    ['2025-04-07T00:00:00.000', 'LMNP', 'loyers Q1', 800.0, 0.0],
    ['2025-04-08T00:00:00.000', 'Variable', 'matelas', 539.1, 0.0],
    ['2025-04-09T00:00:00.000', 'Coiffeur', 'coiffeur', 8.0, 0.0],
    ['2025-04-09T00:00:00.000', 'Spotify', 'spotify', 11.12, 0.0],
    ['2025-04-10T00:00:00.000', 'Adyen', 'expense', 0.0, 245.59],
    ['2025-04-11T00:00:00.000', 'Amazon', 'accessoires café', 44.87, 0.0],
    ['2025-04-14T00:00:00.000', 'Amazon', 'livre', 14.99, 0.0],
    ['2025-04-14T00:00:00.000', 'Variable', 'tasse café', 21.38, 0.0],
    ['2025-04-14T00:00:00.000', 'Amazon', 'arbre a chat maman', 45.98, 0.0],
    ['2025-04-14T00:00:00.000', 'Economies', 'charges', 0.0, 240.0],
    ['2025-04-14T00:00:00.000', 'Cpt Joint', 'charges', 240.0, 0.0],
    ['2025-04-16T00:00:00.000', 'Variable', 'kdo anniv dalle', 0.0, 80.0],
    ['2025-04-16T00:00:00.000', 'Variable', 'kdo papa gaelle', 0.0, 150.0],
    ['2025-04-17T00:00:00.000', 'Cpt Joint', 'appro santé A RBT', 245.0, 0.0],
    ['2025-04-17T00:00:00.000', 'Economies', 'appro lit', 0.0, 518.0],
    ['2025-04-17T00:00:00.000', 'Santé', 'rbt alan', 0.0, 53.5],
    ['2025-04-17T00:00:00.000', 'Santé', 'rbt alan', 0.0, 101.01],
    ['2025-04-17T00:00:00.000', 'Variable', 'rbt alan manon', 70.3, 0.0],
    ['2025-04-20T00:00:00.000', 'Economies', 'chambre lille', 0.0, 100.0],
    ['2025-04-20T00:00:00.000', 'Cpt Joint', 'chambre lille', 100.0, 0.0],
    ['2025-04-20T00:00:00.000', 'Economies', 'vacances mai', 0.0, 372.0],
    ['2025-04-20T00:00:00.000', 'Cpt Joint', 'vacances mai', 372.0, 0.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'lille', 5.3, 0.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'lille', 6.5, 0.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'lille', 7.8, 0.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'wallys café', 11.3, 0.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'sg cloture', 14.84, 0.0],
    ['2025-04-22T00:00:00.000', 'Santé', 'rbt alan', 0.0, 37.44],
    ['2025-04-22T00:00:00.000', 'Variable', 'souvenirs lille', 42.5, 0.0],
    ['2025-04-22T00:00:00.000', 'Santé', 'rbt alan', 0.0, 44.5],
    ['2025-04-22T00:00:00.000', 'Cpt Joint', 'rbt alan', 81.94, 0.0],
    ['2025-04-22T00:00:00.000', 'Cpt Joint', 'appro', 100.0, 0.0],
    ['2025-04-22T00:00:00.000', 'Economies', 'appro', 0.0, 100.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'sncf avignon', 187.0, 0.0],
    ['2025-04-22T00:00:00.000', 'Variable', 'lit', 518.0, 0.0],
    ['2025-04-23T00:00:00.000', 'Variable', 'google', 0.79, 0.0],
    ['2025-04-23T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-04-23T00:00:00.000', 'Sport', 'rouvy', 16.49, 0.0],
    ['2025-04-23T00:00:00.000', 'Santé', 'rbt manon', 0.0, 56.0],
    ['2025-04-24T00:00:00.000', 'Restaurant', '3B', 42.7, 0.0],
    ['2025-04-24T00:00:00.000', 'Cpt Joint', 'appro', 203.75, 0.0],
    ['2025-04-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4804.29],
    ['2025-04-25T00:00:00.000', 'Téléphone', 'sosh', 20.99, 0.0],
    ['2025-04-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-04-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-04-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-04-25T00:00:00.000', 'LMNP', 'appro', 575.0, 0.0],
    ['2025-04-25T00:00:00.000', 'Cpt Joint', 'budget', 1000.0, 0.0],
    ['2025-04-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-04-28T00:00:00.000', 'Sport', 'D4', 69.05, 0.0],
    ['2025-04-29T00:00:00.000', 'Adyen', 'diner movenpick', 29.5, 0.0],
    ['2025-04-29T00:00:00.000', 'Sport', 'airbnb vaison', 55.75, 0.0],
    ['2025-04-30T00:00:00.000', 'Sport', 'plaquettes chaine velo', 78.58, 0.0],
    // May
    ['2025-05-02T00:00:00.000', 'Loto', 'fdj', 11.6, 0.0],
    ['2025-05-02T00:00:00.000', 'Variable', 'google', 26.99, 0.0],
    ['2025-05-02T00:00:00.000', 'Adyen', 'diner ams', 32.21, 0.0],
    ['2025-05-05T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-05-05T00:00:00.000', 'Variable', 'kdo maman et rbt', 0.0, 150.0],
    ['2025-05-07T00:00:00.000', 'Variable', 'chocolat vannes', 7.3, 0.0],
    ['2025-05-07T00:00:00.000', 'Variable', 'bateau arzon', 13.0, 0.0],
    ['2025-05-09T00:00:00.000', 'Variable', 'ikea taie oreiller', 6.39, 0.0],
    ['2025-05-09T00:00:00.000', 'Spotify', 'spotify', 11.12, 0.0],
    ['2025-05-09T00:00:00.000', 'Variable', 'tremie moulin café', 24.99, 0.0],
    ['2025-05-12T00:00:00.000', 'Santé', 'compléments alimentaires', 40.89, 0.0],
    ['2025-05-13T00:00:00.000', 'Variable', 'cagnotte adyen', 25.0, 0.0],
    ['2025-05-15T00:00:00.000', 'Adyen', 'expense', 0.0, 61.71],
    ['2025-05-19T00:00:00.000', 'Variable', 'rbt airbnb ventoux', 0.0, 55.75],
    ['2025-05-19T00:00:00.000', 'Sport', 'D4', 63.54, 0.0],
    ['2025-05-19T00:00:00.000', 'Variable', 'rbt sncf', 0.0, 138.0],
    ['2025-05-19T00:00:00.000', 'Cpt Joint', 'appro', 150.0, 0.0],
    ['2025-05-19T00:00:00.000', 'Sport', 'chaussures porte bagage', 229.96, 0.0],
    ['2025-05-20T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-05-22T00:00:00.000', 'Cpt Joint', 'appro', 18.07, 0.0],
    ['2025-05-22T00:00:00.000', 'Variable', 'bracelet montre', 115.96, 0.0],
    ['2025-05-23T00:00:00.000', 'Economies', 'economies', 274.01, 0.0],
    ['2025-05-23T00:00:00.000', 'Salaire', 'salaire', 0.0, 4884.03],
    ['2025-05-26T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-05-26T00:00:00.000', 'Variable', 'uniqlo', 9.9, 0.0],
    ['2025-05-26T00:00:00.000', 'Variable', 'revolut', 11.33, 0.0],
    ['2025-05-26T00:00:00.000', 'Téléphone', 'sosh', 20.99, 0.0],
    ['2025-05-26T00:00:00.000', 'Amazon', 'amazon', 33.99, 0.0],
    ['2025-05-26T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-05-26T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-05-26T00:00:00.000', 'Variable', 'rbt santé manon', 90.0, 0.0],
    ['2025-05-26T00:00:00.000', 'Variable', 'uniqlo', 209.3, 0.0],
    ['2025-05-26T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-05-26T00:00:00.000', 'LMNP', 'appro lmnp', 575.0, 0.0],
    ['2025-05-26T00:00:00.000', 'Cpt Joint', 'appro mensuelle', 1000.0, 0.0],
    ['2025-05-26T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-05-28T00:00:00.000', 'Variable', 'taxi ?', 1.0, 0.0],
    ['2025-05-30T00:00:00.000', 'Variable', 'repas velo', 8.3, 0.0],
    ['2025-05-30T00:00:00.000', 'Variable', 'repas velo', 10.0, 0.0],
    ['2025-05-30T00:00:00.000', 'Variable', 'repas velo', 10.25, 0.0],
    ['2025-05-30T00:00:00.000', 'Variable', 'repas velo', 11.5, 0.0],
    ['2025-05-30T00:00:00.000', 'Variable', 'camping velo', 14.7, 0.0],
    ['2025-05-30T00:00:00.000', 'Variable', 'repas velo', 24.87, 0.0],
    ['2025-05-30T00:00:00.000', 'Adyen', 'taxi RG', 64.95, 0.0],
    // June
    ['2025-06-02T00:00:00.000', 'Variable', 'laverie velo', 3.0, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'laverie velo', 5.0, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'repas velo', 8.4, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'repas velo', 9.28, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'repas velo', 10.66, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'camping velo', 11.0, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'mcdo amiens', 11.9, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'repas velo', 16.6, 0.0],
    ['2025-06-02T00:00:00.000', 'Variable', 'retrait DAB', 40.0, 0.0],
    ['2025-06-03T00:00:00.000', 'Variable', 'airbnb calais', 50.72, 0.0],
    ['2025-06-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-06-03T00:00:00.000', 'Cpt Joint', 'appro twingo', 288.0, 0.0],
    ['2025-06-04T00:00:00.000', 'Variable', 'cadeau manon', 110.0, 0.0],
    ['2025-06-05T00:00:00.000', 'Variable', 'vente tapis course', 0.0, 170.0],
    ['2025-06-06T00:00:00.000', 'Amazon', 'cadeau manon', 26.0, 0.0],
    ['2025-06-06T00:00:00.000', 'Sport', 'rbt ventoux', 0.0, 116.0],
    ['2025-06-10T00:00:00.000', 'Spotify', 'spotify', 11.12, 0.0],
    ['2025-06-12T00:00:00.000', 'Adyen', 'diner ams benoit', 67.5, 0.0],
    ['2025-06-12T00:00:00.000', 'Amazon', 'livre', 14.99, 0.0],
    ['2025-06-13T00:00:00.000', 'Variable', 'ams tram', 1.21, 0.0],
    ['2025-06-13T00:00:00.000', 'Variable', 'uniqlo', 39.8, 0.0],
    ['2025-06-16T00:00:00.000', 'Variable', 'biere eurostar', 12.0, 0.0],
    ['2025-06-16T00:00:00.000', 'Sport', 'rayon velo', 33.0, 0.0],
    ['2025-06-16T00:00:00.000', 'Sport', 'D4', 37.96, 0.0],
    ['2025-06-16T00:00:00.000', 'Variable', 'manon rbt sage femme', 53.5, 0.0],
    ['2025-06-16T00:00:00.000', 'Amazon', 'amazon prime', 69.9, 0.0],
    ['2025-06-17T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-06-20T00:00:00.000', 'Economies', 'appro santé', 0.0, 400.0],
    ['2025-06-20T00:00:00.000', 'Cpt Joint', 'appro santé', 400.0, 0.0],
    ['2025-06-23T00:00:00.000', 'Variable', 'station service', 2.1, 0.0],
    ['2025-06-23T00:00:00.000', 'Téléphone', 'sosh', 21.45, 0.0],
    ['2025-06-23T00:00:00.000', 'Adyen', 'movenpick repas', 24.0, 0.0],
    ['2025-06-23T00:00:00.000', 'Adyen', 'essence', 70.96, 0.0],
    ['2025-06-23T00:00:00.000', 'Adyen', 'parking', 80.0, 0.0],
    ['2025-06-23T00:00:00.000', 'Adyen', 'expense', 0.0, 132.45],
    ['2025-06-23T00:00:00.000', 'Sport', 'vente guitare', 0.0, 280.0],
    ['2025-06-24T00:00:00.000', 'Santé', 'rbt alan', 0.0, 57.0],
    ['2025-06-24T00:00:00.000', 'Santé', 'rbt alan', 0.0, 137.04],
    ['2025-06-24T00:00:00.000', 'Economies', 'economies', 400.0, 0.0],
    ['2025-06-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4884.03],
    ['2025-06-25T00:00:00.000', 'Variable', 'transport NL', 4.14, 0.0],
    ['2025-06-25T00:00:00.000', 'Adyen', 'movenpick repas', 31.0, 0.0],
    ['2025-06-25T00:00:00.000', 'Santé', 'rbt alan', 0.0, 44.5],
    ['2025-06-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-06-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-06-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-06-25T00:00:00.000', 'LMNP', 'appro lmnp', 575.0, 0.0],
    ['2025-06-25T00:00:00.000', 'Cpt Joint', 'appro mensuelle', 1000.0, 0.0],
    ['2025-06-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-06-26T00:00:00.000', 'Santé', 'rbt gyneco', 0.0, 105.96],
    ['2025-06-26T00:00:00.000', 'Cpt Joint', 'appro', 120.0, 0.0],
    ['2025-06-27T00:00:00.000', 'Restaurant', 'movenpick repas', 40.5, 0.0],
    ['2025-06-27T00:00:00.000', 'Adyen', 'parking', 20.0, 0.0],
    ['2025-06-30T00:00:00.000', 'Variable', 'movenpick', 3.1, 0.0],
    ['2025-06-30T00:00:00.000', 'Variable', 'transport NL', 3.9, 0.0],
    ['2025-06-30T00:00:00.000', 'Variable', 'station service', 6.55, 0.0],
    ['2025-06-30T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-06-30T00:00:00.000', 'Restaurant', 'movenpick petit dej', 26.5, 0.0],
    ['2025-06-30T00:00:00.000', 'Variable', 'kdo martin rbt manon', 0.0, 35.0],
    ['2025-06-30T00:00:00.000', 'Sport', 'strava', 59.99, 0.0],
    ['2025-06-30T00:00:00.000', 'Adyen', 'essence', 64.82, 0.0],
    // July
    ['2025-07-01T00:00:00.000', 'Coiffeur', 'coiffeur', 8.0, 0.0],
    ['2025-07-01T00:00:00.000', 'Amazon', 'kdo martin', 36.39, 0.0],
    ['2025-07-01T00:00:00.000', 'Cpt Joint', 'appro', 180.0, 0.0],
    ['2025-07-01T00:00:00.000', 'Adyen', 'expense', 0.0, 278.95],
    ['2025-07-02T00:00:00.000', 'Variable', 'sg', 45.0, 0.0],
    ['2025-07-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-07-04T00:00:00.000', 'Variable', 'casque audio a rbt', 56.53, 0.0],
    ['2025-07-04T00:00:00.000', 'Amazon', 'variable', 59.86, 0.0],
    ['2025-07-07T00:00:00.000', 'Variable', 'eurostar', 4.0, 0.0],
    ['2025-07-07T00:00:00.000', 'Variable', 'uber maison', 14.97, 0.0],
    ['2025-07-07T00:00:00.000', 'Coiffeur', 'coiffeur', 24.0, 0.0],
    ['2025-07-07T00:00:00.000', 'Variable', 'casque audio', 58.71, 0.0],
    ['2025-07-10T00:00:00.000', 'Variable', 'steam', 11.18, 0.0],
    ['2025-07-10T00:00:00.000', 'Spotify', 'spotify', 12.14, 0.0],
    ['2025-07-10T00:00:00.000', 'Cpt Joint', 'appro charges', 240.0, 0.0],
    ['2025-07-15T00:00:00.000', 'Variable', 'snack hopital', 8.9, 0.0],
    ['2025-07-15T00:00:00.000', 'Variable', 'rbt oney', 0.0, 56.53],
    ['2025-07-15T00:00:00.000', 'Variable', 'couteau japon', 130.0, 0.0],
    ['2025-07-21T00:00:00.000', 'Variable', 'nicolas', 62.1, 0.0],
    ['2025-07-21T00:00:00.000', 'Cpt Joint', 'appro plaques cuisson', 100.0, 0.0],
    ['2025-07-22T00:00:00.000', 'Cpt Joint', 'appro', 70.0, 0.0],
    ['2025-07-22T00:00:00.000', 'Le Monde', 'lemonde', 11.99, 0.0],
    ['2025-07-22T00:00:00.000', 'Variable', 'laposte', 8.23, 0.0],
    ['2025-07-23T00:00:00.000', 'Adyen', 'uber eat AMS', 22.15, 0.0],
    ['2025-07-24T00:00:00.000', 'Adyen', 'uber eat AMS', 26.57, 0.0],
    ['2025-07-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4884.03],
    ['2025-07-25T00:00:00.000', 'Variable', 'cloture sg', 0.0, 3.01],
    ['2025-07-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-07-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-07-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-07-25T00:00:00.000', 'LMNP', 'appro', 575.0, 0.0],
    ['2025-07-25T00:00:00.000', 'Cpt Joint', 'appro mensuelle', 1000.0, 0.0],
    ['2025-07-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-07-28T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-07-28T00:00:00.000', 'Variable', 'café', 7.0, 0.0],
    ['2025-07-28T00:00:00.000', 'Téléphone', 'orange', 21.46, 0.0],
    ['2025-07-28T00:00:00.000', 'Variable', 'D4', 30.95, 0.0],
    ['2025-07-28T00:00:00.000', 'Sport', 'plaquettes velo', 53.37, 0.0],
    ['2025-07-28T00:00:00.000', 'Variable', 'costume', 250.0, 0.0],
    ['2025-07-30T00:00:00.000', 'Variable', 'billets bretagne', 173.9, 0.0],
    // August
    ['2025-08-01T00:00:00.000', 'Santé', 'medecin', 9.0, 0.0],
    ['2025-08-01T00:00:00.000', 'Santé', 'pharmacie', 14.9, 0.0],
    ['2025-08-04T00:00:00.000', 'Variable', 'test adyen', 0.1, 0.0],
    ['2025-08-04T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-08-05T00:00:00.000', 'Santé', 'rbt alan', 0.0, 9.0],
    ['2025-08-05T00:00:00.000', 'Variable', 'casque oney', 55.92, 0.0],
    ['2025-08-06T00:00:00.000', 'Amazon', 'livre', 15.99, 0.0],
    ['2025-08-07T00:00:00.000', 'Variable', 'café', 14.0, 0.0],
    ['2025-08-07T00:00:00.000', 'Retrait DAB', 'cordonnier', 60.0, 0.0],
    ['2025-08-08T00:00:00.000', 'Santé', 'généraliste', 9.0, 0.0],
    ['2025-08-11T00:00:00.000', 'Spotify', 'spotify', 12.14, 0.0],
    ['2025-08-12T00:00:00.000', 'Variable', 'superette jap', 10.5, 0.0],
    ['2025-08-12T00:00:00.000', 'Santé', 'rbt alan', 0.0, 9.0],
    ['2025-08-12T00:00:00.000', 'Amazon', 'bocaux', 19.99, 0.0],
    ['2025-08-12T00:00:00.000', 'Variable', 'chemise cravate', 180.0, 0.0],
    ['2025-08-12T00:00:00.000', 'Variable', 'sandwich lebonmarche', 7.9, 0.0],
    ['2025-08-12T00:00:00.000', 'Variable', 'supermarche', 5.7, 0.0],
    ['2025-08-13T00:00:00.000', 'Loto', 'fdj', 5.0, 0.0],
    ['2025-08-13T00:00:00.000', 'Variable', 'sncf ouigo', 9.0, 0.0],
    ['2025-08-14T00:00:00.000', 'Sport', 'D4', 11.98, 0.0],
    ['2025-08-14T00:00:00.000', 'Variable', 'steam', 19.99, 0.0],
    ['2025-08-14T00:00:00.000', 'Economies', 'economies', 0.0, 8240.0],
    ['2025-08-18T00:00:00.000', 'Variable', 'sncf ouigo', 10.0, 0.0],
    ['2025-08-18T00:00:00.000', 'Variable', 'sandwich paul', 10.9, 0.0],
    ['2025-08-18T00:00:00.000', 'Variable', 'boulanger maman', 14.98, 0.0],
    ['2025-08-18T00:00:00.000', 'Variable', 'ceinture celio', 29.99, 0.0],
    ['2025-08-18T00:00:00.000', 'Variable', 'santos collier', 8155.0, 0.0],
    ['2025-08-19T00:00:00.000', 'Variable', 'sandwich brest', 6.0, 0.0],
    ['2025-08-19T00:00:00.000', 'Cpt Joint', 'appro', 430.0, 0.0],
    ['2025-08-20T00:00:00.000', 'Le Monde', 'lemonde', 12.99, 0.0],
    ['2025-08-20T00:00:00.000', 'Amazon', 'piles', 9.97, 0.0],
    ['2025-08-21T00:00:00.000', 'Amazon', 'etiquettes', 20.98, 0.0],
    ['2025-08-22T00:00:00.000', 'Cpt Joint', 'appro', 37.37, 0.0],
    ['2025-08-22T00:00:00.000', 'Salaire', 'salaire', 0.0, 4884.03],
    ['2025-08-25T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-08-25T00:00:00.000', 'Téléphone', 'orange', 20.99, 0.0],
    ['2025-08-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-08-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-08-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-08-25T00:00:00.000', 'LMNP', 'appro', 575.0, 0.0],
    ['2025-08-25T00:00:00.000', 'Cpt Joint', 'appro budget', 1000.0, 0.0],
    ['2025-08-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-08-26T00:00:00.000', 'Amazon', 'buse vapeur', 28.0, 0.0],
    ['2025-08-26T00:00:00.000', 'Sport', 'cales vélo', 70.01, 0.0],
    ['2025-08-26T00:00:00.000', 'Amazon', 'cadeau maman', 168.99, 0.0],
    ['2025-08-29T00:00:00.000', 'Restaurant', 'creperie', 34.0, 0.0],
    ['2025-08-29T00:00:00.000', 'Variable', 'rbt manon', 0.0, 30.0],
    ['2025-08-29T00:00:00.000', 'Variable', 'variable', 203.45, 0.0],
    // September
    ['2025-09-01T00:00:00.000', 'Variable', 'le bureau francon', 9.8, 0.0],
    ['2025-09-01T00:00:00.000', 'Variable', 'rbt maman', 0.0, 35.0],
    ['2025-09-01T00:00:00.000', 'Variable', 'rbt kdo maman', 0.0, 85.0],
    ['2025-09-01T00:00:00.000', 'Cpt Joint', 'cosy et base cybex', 250.0, 0.0],
    ['2025-09-02T00:00:00.000', 'Amazon', 'livre', 15.99, 0.0],
    ['2025-09-02T00:00:00.000', 'Variable', 'bracelet lip', 54.9, 0.0],
    ['2025-09-03T00:00:00.000', 'Amazon', 'outils montre', 17.99, 0.0],
    ['2025-09-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-09-05T00:00:00.000', 'Variable', 'casque audio', 55.91, 0.0],
    ['2025-09-08T00:00:00.000', 'Variable', 'café', 6.5, 0.0],
    ['2025-09-09T00:00:00.000', 'Spotify', 'spotify', 12.14, 0.0],
    ['2025-09-09T00:00:00.000', 'Santé', 'pharmacie', 15.85, 0.0],
    ['2025-09-11T00:00:00.000', 'Variable', 'vente lbc', 0.0, 45.0],
    ['2025-09-11T00:00:00.000', 'Cpt Joint', 'appro', 140.0, 0.0],
    ['2025-09-15T00:00:00.000', 'Variable', 'bières', 50.3, 0.0],
    ['2025-09-16T00:00:00.000', 'Le Monde', 'lemonde', 12.64, 0.0],
    ['2025-09-17T00:00:00.000', 'Amazon', 'bd maman', 15.95, 0.0],
    ['2025-09-18T00:00:00.000', 'Variable', 'hellobank', 0.0, 3.35],
    ['2025-09-18T00:00:00.000', 'Cpt Joint', 'appro', 100.0, 0.0],
    ['2025-09-22T00:00:00.000', 'Economies', 'economies', 0.0, 310.0],
    ['2025-09-22T00:00:00.000', 'Cpt Joint', 'appro poussette courses', 300.0, 0.0],
    ['2025-09-23T00:00:00.000', 'Santé', 'pharmacie', 4.9, 0.0],
    ['2025-09-23T00:00:00.000', 'Coiffeur', 'coiffeur', 8.0, 0.0],
    ['2025-09-23T00:00:00.000', 'Cpt Joint', 'appro', 180.0, 0.0],
    ['2025-09-24T00:00:00.000', 'Economies', 'appro etf', 0.0, 990.0],
    ['2025-09-24T00:00:00.000', 'Economies', 'appro etf', 1000.0, 0.0],
    ['2025-09-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4884.03],
    ['2025-09-25T00:00:00.000', 'Téléphone', 'orange', 20.99, 0.0],
    ['2025-09-25T00:00:00.000', 'Adyen', 'uber', 37.9, 0.0],
    ['2025-09-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-09-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-09-25T00:00:00.000', 'Impôts', 'ISR', 361.0, 0.0],
    ['2025-09-25T00:00:00.000', 'Cpt Joint', 'appro credit immo', 530.0, 0.0],
    ['2025-09-25T00:00:00.000', 'LMNP', 'appro lmnp', 575.0, 0.0],
    ['2025-09-25T00:00:00.000', 'Cpt Joint', 'budget', 1000.0, 0.0],
    ['2025-09-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-09-26T00:00:00.000', 'Variable', 'café', 7.0, 0.0],
    ['2025-09-26T00:00:00.000', 'Variable', 'cantine', 10.0, 0.0],
    ['2025-09-26T00:00:00.000', 'Santé', 'généraliste', 30.0, 0.0],
    ['2025-09-26T00:00:00.000', 'Amazon', 'amazon café', 88.78, 0.0],
    ['2025-09-29T00:00:00.000', 'Santé', 'rbt alan', 0.0, 9.0],
    ['2025-09-29T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    // October
    ['2025-10-01T00:00:00.000', 'Amazon', 'commande bébé', 69.53, 0.0],
    ['2025-10-02T00:00:00.000', 'Santé', 'pharmacie', 11.4, 0.0],
    ['2025-10-03T00:00:00.000', 'Coiffeur', 'coiffeur', 24.0, 0.0],
    ['2025-10-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-10-06T00:00:00.000', 'Variable', 'café', 7.0, 0.0],
    ['2025-10-06T00:00:00.000', 'Variable', 'mcdo', 17.05, 0.0],
    ['2025-10-06T00:00:00.000', 'Sport', 'D4', 26.97, 0.0],
    ['2025-10-06T00:00:00.000', 'Variable', 'chaussures', 59.99, 0.0],
    ['2025-10-06T00:00:00.000', 'Amazon', 'poele, masque, tubeless', 73.29, 0.0],
    ['2025-10-07T00:00:00.000', 'Variable', 'boulangerie clinique', 7.3, 0.0],
    ['2025-10-07T00:00:00.000', 'Variable', 'coca clinique', 2.0, 0.0],
    ['2025-10-09T00:00:00.000', 'Spotify', 'spotify', 12.14, 0.0],
    ['2025-10-10T00:00:00.000', 'Variable', 'boulangerie clinique', 4.3, 0.0],
    ['2025-10-10T00:00:00.000', 'Economies', 'appro', 0.0, 150.0],
    ['2025-10-10T00:00:00.000', 'Cpt Joint', 'charges', 390.0, 0.0],
    ['2025-10-13T00:00:00.000', 'Santé', 'pharmacie', 4.9, 0.0],
    ['2025-10-13T00:00:00.000', 'Economies', 'appro', 0.0, 250.0],
    ['2025-10-13T00:00:00.000', 'Cpt Joint', 'appro santé', 250.0, 0.0],
    ['2025-10-14T00:00:00.000', 'Le Monde', 'lemonde', 12.99, 0.0],
    ['2025-10-16T00:00:00.000', 'Economies', 'economies', 0.0, 200.0],
    ['2025-10-16T00:00:00.000', 'Cpt Joint', 'appro', 130.0, 0.0],
    ['2025-10-16T00:00:00.000', 'Variable', 'cafe et bluetooth', 59.46, 0.0],
    ['2025-10-17T00:00:00.000', 'Amazon', 'housse cosy', 28.89, 0.0],
    ['2025-10-20T00:00:00.000', 'Economies', 'appro', 0.0, 210.0],
    ['2025-10-20T00:00:00.000', 'Santé', 'rbt alan', 0.0, 20.0],
    ['2025-10-20T00:00:00.000', 'Cpt Joint', 'appro', 320.0, 0.0],
    ['2025-10-21T00:00:00.000', 'Santé', 'rbt alan', 0.0, 750.0],
    ['2025-10-21T00:00:00.000', 'Economies', 'rbt economies', 300.0, 0.0],
    ['2025-10-21T00:00:00.000', 'Cpt Joint', 'rbt anesthesiste', 250.0, 0.0],
    ['2025-10-21T00:00:00.000', 'Variable', 'rbt manon el houari', 250.0, 0.0],
    ['2025-10-21T00:00:00.000', 'Economies', 'appro', 0.0, 50.0],
    ['2025-10-21T00:00:00.000', 'Cpt Joint', 'rbt biberon housse', 0.0, 40.0],
    ['2025-10-21T00:00:00.000', 'Amazon', 'biberon', 13.4, 0.0],
    ['2025-10-23T00:00:00.000', 'Amazon', 'livre', 6.49, 0.0],
    ['2025-10-23T00:00:00.000', 'Amazon', 'tetines', 9.9, 0.0],
    ['2025-10-24T00:00:00.000', 'Salaire', 'salaire', 0.0, 4870.74],
    ['2025-10-24T00:00:00.000', 'Economies', 'virement bourso', 750.0, 0.0],
    ['2025-10-24T00:00:00.000', 'Economies', 'appro pour bourso', 0.0, 740.0],
    ['2025-10-24T00:00:00.000', 'Variable', 'manon rbt sejour mater', 160.0, 0.0],
    ['2025-10-24T00:00:00.000', 'Téléphone', 'orange', 20.99, 0.0],
    ['2025-10-24T00:00:00.000', 'Sport', 'rouvy', 19.99, 0.0],
    ['2025-10-27T00:00:00.000', 'Economies', 'epargne', 1300.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Cpt Joint', 'budget', 1000.0, 0.0],
    ['2025-10-27T00:00:00.000', 'LMNP', 'appro', 575.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Impôts', 'impots', 361.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Amazon', 'café', 151.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Variable', 'appro charges', 100.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-10-27T00:00:00.000', 'Variable', 'variable', 17.23, 0.0],
    ['2025-10-27T00:00:00.000', 'Sport', 'accessoire lumiere', 13.92, 0.0],
    ['2025-10-27T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-10-28T00:00:00.000', 'Variable', 'café neuilly', 18.0, 0.0],
    ['2025-10-30T00:00:00.000', 'Variable', 'leroy merlin', 22.9, 0.0],
    ['2025-10-31T00:00:00.000', 'Economies', 'appro twingo', 0.0, 490.0],
    // November
    ['2025-11-03T00:00:00.000', 'Variable', 'leroy merlin', 21.89, 0.0],
    ['2025-11-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-11-03T00:00:00.000', 'Cpt Joint', 'appro twingo', 700.0, 0.0],
    ['2025-11-04T00:00:00.000', 'Amazon', 'roulements', 11.15, 0.0],
    ['2025-11-05T00:00:00.000', 'Variable', 'café enghien', 9.0, 0.0],
    ['2025-11-07T00:00:00.000', 'Amazon', 'livre', 8.49, 0.0],
    ['2025-11-07T00:00:00.000', 'Amazon', 'boitier pédalier', 14.0, 0.0],
    ['2025-11-10T00:00:00.000', 'Spotify', 'spotify', 12.14, 0.0],
    ['2025-11-12T00:00:00.000', 'Variable', 'vin leclerc', 34.65, 0.0],
    ['2025-11-13T00:00:00.000', 'Variable', 'café', 7.0, 0.0],
    ['2025-11-14T00:00:00.000', 'Variable', 'jogging vinted', 15.76, 0.0],
    ['2025-11-17T00:00:00.000', 'Retrait DAB', 'retrait velo', 100.0, 0.0],
    ['2025-11-18T00:00:00.000', 'Le Monde', 'lemonde', 12.99, 0.0],
    ['2025-11-18T00:00:00.000', 'Economies', 'economies', 0.0, 105.4],
    ['2025-11-19T00:00:00.000', 'Variable', 'oscar livret A', 10.0, 0.0],
    ['2025-11-20T00:00:00.000', 'Economies', 'economies', 55.0, 0.0],
    ['2025-11-21T00:00:00.000', 'Variable', 'vente vinted', 0.0, 55.0],
    ['2025-11-24T00:00:00.000', 'Sport', 'rouvy', 19.99, 0.0],
    ['2025-11-24T00:00:00.000', 'Téléphone', 'sosh', 20.99, 0.0],
    ['2025-11-24T00:00:00.000', 'Salaire', 'adyen partie 1', 0.0, 2710.03],
    ['2025-11-24T00:00:00.000', 'Economies', 'salaire partie 2', 0.0, 2100.0],
    ['2025-11-25T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Cpt Joint', 'appro', 1000.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Economies', '', 621.1, 0.0],
    ['2025-11-25T00:00:00.000', 'Economies', 'bourso', 0.0, 621.1],
    ['2025-11-25T00:00:00.000', 'LMNP', 'lmnp', 575.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Cpt Joint', 'appro charges', 100.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Variable', 'cagnottes boulot', 45.0, 0.0],
    ['2025-11-25T00:00:00.000', 'Loto', 'fdj', 6.6, 0.0],
    ['2025-11-26T00:00:00.000', 'Variable', 'vente lbc', 0.0, 110.0],
    ['2025-11-26T00:00:00.000', 'Economies', 'economies', 110.0, 0.0],
    ['2025-11-26T00:00:00.000', 'Economies', 'paiements impots', 0.0, 362.0],
    ['2025-11-26T00:00:00.000', 'LMNP', 'frais immokip', 346.8, 0.0],
    ['2025-11-27T00:00:00.000', 'Impôts', 'impots', 361.0, 0.0],
    ['2025-11-28T00:00:00.000', 'Amazon', 'livre', 7.99, 0.0],
    ['2025-11-28T00:00:00.000', 'Amazon', 'bouchons oreille', 14.99, 0.0],
    // December
    ['2025-12-01T00:00:00.000', 'Variable', 'resto copains', 91.5, 0.0],
    ['2025-12-03T00:00:00.000', 'Variable', 'jean vinted', 18.7, 0.0],
    ['2025-12-03T00:00:00.000', 'Variable', 'pull patagonia vinted', 38.49, 0.0],
    ['2025-12-03T00:00:00.000', 'Navigo', 'navigo', 88.8, 0.0],
    ['2025-12-05T00:00:00.000', 'Variable', 'frais', 4.5, 0.0],
    ['2025-12-05T00:00:00.000', 'Variable', 'franprix', 4.85, 0.0],
    ['2025-12-05T00:00:00.000', 'Variable', 'pharmacie', 5.9, 0.0],
    ['2025-12-05T00:00:00.000', 'Variable', 'kdo manon', 97.99, 0.0],
    ['2025-12-09T00:00:00.000', 'Coiffeur', 'coiffeur', 8.0, 0.0],
    ['2025-12-09T00:00:00.000', 'Spotify', 'spotify', 12.14, 0.0],
    ['2025-12-11T00:00:00.000', 'Adyen', 'diner ams', 35.0, 0.0],
    ['2025-12-15T00:00:00.000', 'Variable', 'boulangerie paris', 8.9, 0.0],
    ['2025-12-15T00:00:00.000', 'Variable', 'café', 14.9, 0.0],
    ['2025-12-15T00:00:00.000', 'Amazon', 'amazon', 25.61, 0.0],
    ['2025-12-15T00:00:00.000', 'Variable', 'drinks benoit', 74.5, 0.0],
    ['2025-12-15T00:00:00.000', 'Variable', 'kdo manon', 95.0, 0.0],
    ['2025-12-16T00:00:00.000', 'Le Monde', 'lemonde', 12.99, 0.0],
    ['2025-12-16T00:00:00.000', 'Amazon', 'livre', 15.99, 0.0],
    ['2025-12-16T00:00:00.000', 'Economies', 'appro', 0.0, 200.0],
    ['2025-12-16T00:00:00.000', 'Cpt Joint', 'appro', 200.0, 0.0],
    ['2025-12-18T00:00:00.000', 'Variable', 'pull st james', 175.0, 0.0],
    ['2025-12-18T00:00:00.000', 'Cpt Joint', 'appro', 300.0, 0.0],
    ['2025-12-18T00:00:00.000', 'Economies', 'appro', 0.0, 500.0],
    ['2025-12-19T00:00:00.000', 'Coiffeur', 'coiffeur', 24.0, 0.0],
    ['2025-12-23T00:00:00.000', 'Economies', 'appro', 0.0, 238.0],
    ['2025-12-23T00:00:00.000', 'Cpt Joint', 'appro', 250.0, 0.0],
    ['2025-12-23T00:00:00.000', 'Salaire', 'adyen', 0.0, 4848.18],
    ['2025-12-24T00:00:00.000', 'Loto', 'fdj', 5.3, 0.0],
    ['2025-12-24T00:00:00.000', 'Sport', 'rouvy', 19.99, 0.0],
    ['2025-12-24T00:00:00.000', 'Téléphone', 'sosh', 21.67, 0.0],
    ['2025-12-24T00:00:00.000', 'Variable', 'kdo toutou', 0.0, 120.0],
    ['2025-12-26T00:00:00.000', 'Variable', 'provision charges', 100.0, 0.0],
    ['2025-12-26T00:00:00.000', 'Variable', 'kdo papa gaelle', 0.0, 150.0],
    ['2025-12-29T00:00:00.000', 'Variable', 'steam', 4.87, 0.0],
    ['2025-12-29T00:00:00.000', 'Santé', 'pharmacie', 10.99, 0.0],
    ['2025-12-29T00:00:00.000', 'Variable', 'a rbt cpt joint', 0.0, 50.0],
    ['2025-12-29T00:00:00.000', 'Cpt Joint', 'taxe fonciere', 66.0, 0.0],
    ['2025-12-29T00:00:00.000', 'Cpt Joint', 'Fenetres', 78.0, 0.0],
    ['2025-12-29T00:00:00.000', 'Variable', 'kdo maman', 0.0, 80.0],
    ['2025-12-29T00:00:00.000', 'Impôts', 'impots', 362.0, 0.0],
    ['2025-12-29T00:00:00.000', 'Cpt Joint', 'credit immo', 530.0, 0.0],
    ['2025-12-29T00:00:00.000', 'LMNP', 'lmnp', 575.0, 0.0],
    ['2025-12-29T00:00:00.000', 'Cpt Joint', 'budget variable', 1000.0, 0.0],
    ['2025-12-29T00:00:00.000', 'Economies', 'economies', 1300.0, 0.0],
    ['2025-12-30T00:00:00.000', 'Retrait DAB', 'retrait moisselles', 30.0, 0.0],
    ['2025-12-31T00:00:00.000', 'Variable', 'café station service', 5.45, 0.0],
    ['2025-12-31T00:00:00.000', 'Variable', 'patagonia', 230.0, 0.0],
  ];

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

  Future<Balance?> getBalance() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      'balance',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Balance.fromMap(maps.first);
  }

  Future<int> setBalance(Balance balance) async {
    final db = await database;
    await db.delete('balance');
    return await db.insert('balance', balance.toMap());
  }

  Future<int> deleteBalance() async {
    final db = await database;
    return await db.delete('balance');
  }

  Future<double> calculateCurrentBalance() async {
    final balance = await getBalance();
    if (balance == null) return 0.0;

    final db = await database;
    final balanceDateStr = balance.date.toIso8601String();

    final creditResult = await db.rawQuery('''
      SELECT COALESCE(SUM(credit), 0) as total
      FROM transactions
      WHERE date >= ?
    ''', [balanceDateStr]);

    final debitResult = await db.rawQuery('''
      SELECT COALESCE(SUM(debit), 0) as total
      FROM transactions
      WHERE date >= ?
    ''', [balanceDateStr]);

    final totalCredits = (creditResult.first['total'] as num).toDouble();
    final totalDebits = (debitResult.first['total'] as num).toDouble();

    return balance.amount + totalCredits - totalDebits;
  }
}
