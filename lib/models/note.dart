class Note {
  final String id;
  final String title;
  final String body;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({String? title, String? body, int? color}) => Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        color: color ?? this.color,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  factory Note.fromServerMap(Map<String, dynamic> map) => Note(
        id: map['id'] as String,
        title: map['title'] as String,
        body: (map['body'] ?? '') as String,
        color: int.tryParse(map['color'].toString()) ?? 0xFFFFF9C4,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
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
