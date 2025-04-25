import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initiateDatabase();
    return _database!;
  }

  Future<Database> initiateDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "recipe_db.db");
    final db = await openDatabase(
      databasePath,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY,
          currentPage INTEGER,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          imageUrl TEXT,
          cal INTEGER NOT NULL,
          time INTEGER NOT NULL,
          rating TEXT NOT NULL,
          category TEXT NOT NULL
        )
        ''');
      },
      version: 1,
    );
    return db;
  }

  Future<void> insertDraft(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('recipes', {
      ...data,
      'id': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteDraft() async {
    final db = await database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [1]);
  }

  Future<RecipeDraftProps?> getDraft() async {
    final db = await database;
    final data = await db.query(
      'recipes',
      limit: 1,
    );

    if (data.isEmpty) return null;

    return RecipeDraftProps(
      id: data[0]["id"] as int,
      cal: data[0]["cal"] as int,
      category: data[0]["category"] as String,
      currentPage: data[0]["currentPage"] as int,
      description: data[0]["description"] as String,
      name: data[0]["name"] as String,
      image: data[0]["imageUrl"] as String,
      rating: data[0]["rating"] as String,
      time: data[0]["time"] as int,
    );
  }
}

class RecipeDraftProps {
  final int id, currentPage, cal, time;
  final String name, description, rating, category, image;

  RecipeDraftProps({
    required this.id,
    required this.cal,
    required this.category,
    required this.currentPage,
    required this.description,
    required this.name,
    required this.image,
    required this.rating,
    required this.time,
  });
}
