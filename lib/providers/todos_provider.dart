import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../db/database_helper.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TodosProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;
  List<Todo> get pending => _todos.where((t) => !t.isDone).toList();
  List<Todo> get done => _todos.where((t) => t.isDone).toList();

  final _uuid = const Uuid();

  Future<void> load() async {
    _todos = await DatabaseHelper.instance.getTodos();
    notifyListeners();
  }

  Future<void> add({
    required String title,
    String? description,
    DateTime? dueDate,
  }) async {
    int? notifId;
    if (dueDate != null && dueDate.isAfter(DateTime.now())) {
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
    await DatabaseHelper.instance.insertTodo(todo);
    _todos.insert(0, todo);
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final updated = _todos[idx].copyWith(isDone: !_todos[idx].isDone);
    await DatabaseHelper.instance.updateTodo(updated);
    _todos[idx] = updated;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (todo.notificationId != null) {
      await NotificationService.instance.cancelNotification(todo.notificationId!);
    }
    await DatabaseHelper.instance.deleteTodo(id);
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
