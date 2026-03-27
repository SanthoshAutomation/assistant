import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../db/database_helper.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class EventsProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _loading = false;
  String? _error;

  List<Event> get events => _events;
  bool get loading => _loading;
  String? get error => _error;

  final _uuid = const Uuid();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _events = kIsWeb
          ? await ApiService.fetchEvents()
          : await DatabaseHelper.instance.getEvents();
    } catch (e) {
      _error = 'Could not load events: $e';
    }
    _loading = false;
    notifyListeners();
  }

  List<Event> eventsForDay(DateTime day) {
    return _events.where((e) {
      final start = DateTime(e.date.year, e.date.month, e.date.day);
      final end = e.endDate != null
          ? DateTime(
              e.endDate!.year, e.endDate!.month, e.endDate!.day)
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
    if (!kIsWeb && date.isAfter(DateTime.now())) {
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
    if (kIsWeb) {
      await ApiService.saveEvent(event);
    } else {
      await DatabaseHelper.instance.insertEvent(event);
    }
    _events.add(event);
    _events.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final event = _events.firstWhere((e) => e.id == id);
    if (!kIsWeb && event.notificationId != null) {
      await NotificationService.instance
          .cancelNotification(event.notificationId!);
    }
    if (kIsWeb) {
      await ApiService.deleteEvent(id);
    } else {
      await DatabaseHelper.instance.deleteEvent(id);
    }
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
