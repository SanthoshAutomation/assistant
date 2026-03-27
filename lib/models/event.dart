enum EventType { appointment, vacation, reminder, other }

class Event {
  final String id;
  final String title;
  final String? notes;
  final DateTime date;
  final DateTime? endDate;
  final EventType type;

  const Event({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    this.endDate,
    this.type = EventType.other,
  });

  bool get isMultiDay =>
      endDate != null && endDate!.difference(date).inDays > 0;

  Event copyWith({
    String? title,
    String? notes,
    DateTime? date,
    DateTime? endDate,
    EventType? type,
  }) =>
      Event(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        date: date ?? this.date,
        endDate: endDate ?? this.endDate,
        type: type ?? this.type,
      );

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
