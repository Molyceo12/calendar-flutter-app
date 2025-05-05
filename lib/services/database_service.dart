import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:calendar_app/models/event.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Database name and version
  static const String _databaseName = "minimal_calendar.db";
  static const int _databaseVersion = 1;

  // Table names
  static const String tableEvents = 'events';

  // Private constructor
  DatabaseService._internal();

  // Singleton pattern
  factory DatabaseService() {
    return _instance;
  }

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create events table
    await db.execute('''
      CREATE TABLE $tableEvents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        color TEXT NOT NULL,
        has_notification INTEGER NOT NULL,
        user_id TEXT NOT NULL
      )
    ''');
  }

  // Get events for a specific month and user
  Future<List<Event>> getEventsForMonth(DateTime month, String userId) async {
    final db = await database;

    // First day of month
    final firstDay = DateTime(month.year, month.month, 1);
    // Last day of month
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      tableEvents,
      where: 'date BETWEEN ? AND ? AND user_id = ?',
      whereArgs: [
        firstDay.millisecondsSinceEpoch,
        lastDay.millisecondsSinceEpoch,
        userId,
      ],
    );

    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }

  // Insert event
  Future<void> insertEvent(Event event) async {
    final db = await database;
    await db.insert(
      tableEvents,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update event
  Future<void> updateEvent(Event event) async {
    final db = await database;
    await db.update(
      tableEvents,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    final db = await database;
    await db.delete(
      tableEvents,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all events for a user
  Future<List<Event>> getEventsForUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableEvents,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }
}
