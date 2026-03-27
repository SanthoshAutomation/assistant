class Todo {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime? dueDate;
  final int? notificationId;
  final bool synced;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.dueDate,
    this.notificationId,
    this.synced = false,
    required this.createdAt,
  });

  Todo copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
    int? notificationId,
    bool? synced,
  }) =>
      Todo(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        isDone: isDone ?? this.isDone,
        dueDate: dueDate ?? this.dueDate,
        notificationId: notificationId ?? this.notificationId,
        synced: synced ?? this.synced,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0,
        'due_date': dueDate?.toIso8601String(),
        'notification_id': notificationId,
        'synced': synced ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory Todo.fromMap(Map<String, dynamic> map) => Todo(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        isDone: (map['is_done'] as int) == 1,
        dueDate: map['due_date'] != null
            ? DateTime.parse(map['due_date'] as String)
            : null,
        notificationId: map['notification_id'] as int?,
        synced: (map['synced'] as int) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  /// Parse a row returned by the PHP API (all values are strings from PDO).
  factory Todo.fromServerMap(Map<String, dynamic> map) => Todo(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        isDone: map['is_done'].toString() == '1',
        dueDate: (map['due_date'] != null &&
                (map['due_date'] as String).isNotEmpty)
            ? DateTime.tryParse(map['due_date'] as String)
            : null,
        synced: true,
        createdAt: DateTime.tryParse(
                map['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone,
        'due_date': dueDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
