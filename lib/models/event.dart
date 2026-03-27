enum EventType { appointment, vacation, reminder, other }

class Event {
  final String id;
  final String title;
  final String? notes;
  final DateTime date;
  final DateTime? endDate;
  final EventType type;
  final int? notificationId; // mobile only
  final bool synced;         // mobile only

  const Event({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    this.endDate,
    this.type = EventType.other,
    this.notificationId,
    this.synced = false,
  });

  bool get isMultiDay =>
      endDate != null && endDate!.difference(date).inDays > 0;

  Event copyWith({
    String? title,
    String? notes,
    DateTime? date,
    DateTime? endDate,
    EventType? type,
    int? notificationId,
    bool? synced,
  }) =>
      Event(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        date: date ?? this.date,
        endDate: endDate ?? this.endDate,
        type: type ?? this.type,
        notificationId: notificationId ?? this.notificationId,
        synced: synced ?? this.synced,
      );

  // ---- SQLite (mobile) ----
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'notes': notes,
        'date': date.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'type': type.name,
        'notification_id': notificationId,
        'synced': synced ? 1 : 0,
      };

  factory Event.fromMap(Map<String, dynamic> map) => Event(
        id: map['id'] as String,
        title: map['title'] as String,
        notes: map['notes'] as String?,
        date: DateTime.parse(map['date'] as String),
        endDate: map['end_date'] != null
            ? DateTime.parse(map['end_date'] as String)
            : null,
        type: EventType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => EventType.other,
        ),
        notificationId: map['notification_id'] as int?,
        synced: (map['synced'] as int) == 1,
      );

  // ---- PHP API (web + Android pull) ----
  factory Event.fromServerMap(Map<String, dynamic> map) => Event(
        id: map['id'] as String,
        title: map['title'] as String,
        notes: map['notes'] as String?,
        date: DateTime.parse(map['date'] as String),
        endDate: (map['end_date'] != null &&
                (map['end_date'] as String).isNotEmpty)
            ? DateTime.tryParse(map['end_date'] as String)
            : null,
        type: EventType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => EventType.other,
        ),
        synced: true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'date': date.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'type': type.name,
      };
}
