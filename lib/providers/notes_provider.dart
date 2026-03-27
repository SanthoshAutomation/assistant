import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _loading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get loading => _loading;
  String? get error => _error;

  final _uuid = const Uuid();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notes = await ApiService.fetchNotes();
    } catch (e) {
      _error = 'Could not load notes: $e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String title,
    required String body,
    required int color,
  }) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ApiService.saveNote(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> update(Note note) async {
    await ApiService.saveNote(note);
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    await ApiService.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
