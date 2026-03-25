class Note {
  final String id;
  final String title;
  final String body;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  Note copyWith({
    String? title,
    String? body,
    int? color,
    bool? synced,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'color': color,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        color: map['color'] as int,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
        synced: (map['synced'] as int) == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'color': color,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
