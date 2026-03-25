import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/todo.dart';
import '../models/event.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'assistant.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        is_done INTEGER NOT NULL DEFAULT 0,
        due_date TEXT,
        notification_id INTEGER,
        synced INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        date TEXT NOT NULL,
        end_date TEXT,
        type TEXT NOT NULL,
        notification_id INTEGER,
        synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // -------- Notes --------
  Future<List<Note>> getNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update('notes', note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // -------- Todos --------
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final rows = await db.query('todos', orderBy: 'created_at DESC');
    return rows.map(Todo.fromMap).toList();
  }

  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update('todos', todo.toMap(),
        where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // -------- Events --------
  Future<List<Event>> getEvents() async {
    final db = await database;
    final rows = await db.query('events', orderBy: 'date ASC');
    return rows.map(Event.fromMap).toList();
  }

  Future<void> insertEvent(Event event) async {
    final db = await database;
    await db.insert('events', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEvent(Event event) async {
    final db = await database;
    await db.update('events', event.toMap(),
        where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> deleteEvent(String id) async {
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // -------- Sync helpers --------
  Future<Map<String, dynamic>> getAllForSync() async {
    final db = await database;
    final notes = await db.query('notes');
    final todos = await db.query('todos');
    final events = await db.query('events');
    return {'notes': notes, 'todos': todos, 'events': events};
  }

  Future<void> markAllSynced() async {
    final db = await database;
    await db.update('notes', {'synced': 1});
    await db.update('todos', {'synced': 1});
    await db.update('events', {'synced': 1});
  }
}
