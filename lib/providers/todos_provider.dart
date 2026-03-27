import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../db/database_helper.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

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
      _todos = kIsWeb
          ? await ApiService.fetchTodos()
          : await DatabaseHelper.instance.getTodos();
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
    int? notifId;
    if (!kIsWeb && dueDate != null && dueDate.isAfter(DateTime.now())) {
      notifId = await NotificationService.instance.scheduleTodoReminder(
        title: title,
        scheduledAt: dueDate,
      );
    }
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      notificationId: notifId,
      createdAt: DateTime.now(),
    );
    if (kIsWeb) {
      await ApiService.saveTodo(todo);
    } else {
      await DatabaseHelper.instance.insertTodo(todo);
    }
    _todos.insert(0, todo);
    notifyListeners();
  }

  Future<void> update({
    required Todo original,
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    if (!kIsWeb && original.notificationId != null) {
      await NotificationService.instance
          .cancelNotification(original.notificationId!);
    }
    int? notifId;
    if (!kIsWeb && dueDate != null && dueDate.isAfter(DateTime.now())) {
      notifId = await NotificationService.instance.scheduleTodoReminder(
        title: title,
        scheduledAt: dueDate,
      );
    }
    final updated = Todo(
      id: original.id,
      title: title,
      description:
          description?.trim().isEmpty == true ? null : description,
      isDone: original.isDone,
      dueDate: dueDate,
      notificationId: notifId,
      synced: false,
      createdAt: original.createdAt,
    );
    if (kIsWeb) {
      await ApiService.saveTodo(updated);
    } else {
      await DatabaseHelper.instance.updateTodo(updated);
    }
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
    if (kIsWeb) {
      await ApiService.saveTodo(updated);
    } else {
      await DatabaseHelper.instance.updateTodo(updated);
    }
    _todos[idx] = updated;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (!kIsWeb && todo.notificationId != null) {
      await NotificationService.instance
          .cancelNotification(todo.notificationId!);
    }
    if (kIsWeb) {
      await ApiService.deleteTodo(id);
    } else {
      await DatabaseHelper.instance.deleteTodo(id);
    }
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
