import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../services/api_service.dart';

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
      _events = await ApiService.fetchEvents();
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
    final event = Event(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      date: date,
      endDate: endDate,
      type: type,
    );
    await ApiService.saveEvent(event);
    _events.add(event);
    _events.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await ApiService.deleteEvent(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
