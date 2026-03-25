import 'package:flutter/material.dart';
import '../models/event.dart';
import '../db/database_helper.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class EventsProvider extends ChangeNotifier {
  List<Event> _events = [];
  List<Event> get events => _events;

  final _uuid = const Uuid();

  Future<void> load() async {
    _events = await DatabaseHelper.instance.getEvents();
    notifyListeners();
  }

  List<Event> eventsForDay(DateTime day) {
    return _events.where((e) {
      final start = DateTime(e.date.year, e.date.month, e.date.day);
      final end = e.endDate != null
          ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
          : start;
      final d = DateTime(day.year, day.month, day.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  Future<void> add({
    required String title,
    String? notes,
    required DateTime date,
    DateTime? endDate,
    required EventType type,
  }) async {
    int? notifId;
    if (date.isAfter(DateTime.now())) {
      notifId = await NotificationService.instance.scheduleEventReminder(
        title: title,
        scheduledAt: date,
      );
    }
    final event = Event(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      date: date,
      endDate: endDate,
      type: type,
      notificationId: notifId,
    );
    await DatabaseHelper.instance.insertEvent(event);
    _events.add(event);
    _events.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final event = _events.firstWhere((e) => e.id == id);
    if (event.notificationId != null) {
      await NotificationService.instance.cancelNotification(event.notificationId!);
    }
    await DatabaseHelper.instance.deleteEvent(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
