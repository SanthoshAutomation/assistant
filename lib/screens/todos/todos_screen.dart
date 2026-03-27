import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/todos_provider.dart';
import '../../models/todo.dart';
import 'add_todo_screen.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTodoScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: Consumer<TodosProvider>(
        builder: (context, provider, _) {
          final pending = provider.pending;
          final done = provider.done;

          if (pending.isEmpty && done.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('All clear! Add a task to get started.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (pending.isNotEmpty)
                ..._buildSection(context, 'Pending', pending, provider),
              if (done.isNotEmpty)
                ..._buildSection(context, 'Completed', done, provider),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSection(
    BuildContext context,
    String label,
    List<Todo> todos,
    TodosProvider provider,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      ...todos.map((t) => _TodoTile(todo: t, provider: provider)),
    ];
  }
}

class _TodoTile extends StatelessWidget {
  final Todo todo;
  final TodosProvider provider;

  const _TodoTile({required this.todo, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.delete(todo.id),
      child: Card(
        child: ListTile(
          // Tap anywhere on the tile to edit
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTodoScreen(todo: todo),
            ),
          ),
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) => provider.toggle(todo.id),
            shape: const CircleBorder(),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              color: todo.isDone ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description != null && todo.description!.isNotEmpty)
                Text(todo.description!,
                    style: const TextStyle(fontSize: 12)),
              if (todo.dueDate != null)
                Row(
                  children: [
                    const Icon(Icons.alarm, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      fmt.format(todo.dueDate!),
                      style: const TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ],
                ),
            ],
          ),
          trailing: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
