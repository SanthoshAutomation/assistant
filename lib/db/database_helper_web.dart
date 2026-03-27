// Web stub — providers use ApiService on web, so this class is never called.
// It exists only to satisfy the compiler when building for web.
import '../models/note.dart';
import '../models/todo.dart';
import '../models/event.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Future<List<Note>> getNotes() async => [];
  Future<void> insertNote(Note note) async {}
  Future<void> updateNote(Note note) async {}
  Future<void> deleteNote(String id) async {}

  Future<List<Todo>> getTodos() async => [];
  Future<void> insertTodo(Todo todo) async {}
  Future<void> updateTodo(Todo todo) async {}
  Future<void> deleteTodo(String id) async {}

  Future<List<Event>> getEvents() async => [];
  Future<void> insertEvent(Event event) async {}
  Future<void> updateEvent(Event event) async {}
  Future<void> deleteEvent(String id) async {}

  Future<Map<String, dynamic>> getAllForSync() async => {};
  Future<void> markAllSynced() async {}
}
