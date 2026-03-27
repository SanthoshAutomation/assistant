import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import '../models/todo.dart';
import '../models/event.dart';

/// All data goes directly to/from the Hostinger PHP API.
/// No local storage — the server is the single source of truth.
class ApiService {
  static const String base = 'https://app.sanlabs.in/assistant/api';

  // -------- Notes --------

  static Future<List<Note>> fetchNotes() async {
    final res = await http.get(Uri.parse('$base/notes.php'));
    _check(res);
    return (jsonDecode(res.body) as List)
        .map((m) => Note.fromServerMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  static Future<void> saveNote(Note note) async {
    final res = await http.post(
      Uri.parse('$base/notes.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(note.toJson()),
    );
    _check(res);
  }

  static Future<void> deleteNote(String id) async {
    final res = await http.delete(Uri.parse('$base/notes.php?id=$id'));
    _check(res);
  }

  // -------- Todos --------

  static Future<List<Todo>> fetchTodos() async {
    final res = await http.get(Uri.parse('$base/todos.php'));
    _check(res);
    return (jsonDecode(res.body) as List)
        .map((m) => Todo.fromServerMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  static Future<void> saveTodo(Todo todo) async {
    final res = await http.post(
      Uri.parse('$base/todos.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(todo.toJson()),
    );
    _check(res);
  }

  static Future<void> deleteTodo(String id) async {
    final res = await http.delete(Uri.parse('$base/todos.php?id=$id'));
    _check(res);
  }

  // -------- Events --------

  static Future<List<Event>> fetchEvents() async {
    final res = await http.get(Uri.parse('$base/events.php'));
    _check(res);
    return (jsonDecode(res.body) as List)
        .map((m) => Event.fromServerMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  static Future<void> saveEvent(Event event) async {
    final res = await http.post(
      Uri.parse('$base/events.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(event.toJson()),
    );
    _check(res);
  }

  static Future<void> deleteEvent(String id) async {
    final res = await http.delete(Uri.parse('$base/events.php?id=$id'));
    _check(res);
  }

  static void _check(http.Response res) {
    if (res.statusCode >= 300) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }
  }
}
