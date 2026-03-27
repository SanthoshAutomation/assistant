class Todo {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime? dueDate;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.dueDate,
    required this.createdAt,
  });

  Todo copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
  }) =>
      Todo(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt,
      );

  factory Todo.fromServerMap(Map<String, dynamic> map) => Todo(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        isDone: map['is_done'].toString() == '1',
        dueDate: (map['due_date'] != null &&
                (map['due_date'] as String).isNotEmpty)
            ? DateTime.tryParse(map['due_date'] as String)
            : null,
        createdAt:
            DateTime.tryParse(map['created_at'] as String? ?? '') ??
                DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0,
        'due_date': dueDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
