import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class TodosProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  bool _loading = false;
  String? _error;

  List<Todo> get todos => _todos;
  List<Todo> get pending => _todos.where((t) => !t.isDone).toList();
  List<Todo> get done => _todos.where((t) => t.isDone).toList();
  bool get loading => _loading;
  String? get error => _error;

  final _uuid = const Uuid();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _todos = await ApiService.fetchTodos();
    } catch (e) {
      _error = 'Could not load todos: $e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    await ApiService.saveTodo(todo);
    _todos.insert(0, todo);
    notifyListeners();
  }

  Future<void> update({
    required Todo original,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    final updated = Todo(
      id: original.id,
      title: title,
      description: description?.trim().isEmpty == true ? null : description,
      isDone: original.isDone,
      dueDate: dueDate,
      createdAt: original.createdAt,
    );
    await ApiService.saveTodo(updated);
    final idx = _todos.indexWhere((t) => t.id == original.id);
    if (idx != -1) {
      _todos[idx] = updated;
      notifyListeners();
    }
  }

  Future<void> toggle(String id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final updated = _todos[idx].copyWith(isDone: !_todos[idx].isDone);
    await ApiService.saveTodo(updated);
    _todos[idx] = updated;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await ApiService.deleteTodo(id);
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
