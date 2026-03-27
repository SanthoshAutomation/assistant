import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../db/database_helper.dart';
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
      _notes = kIsWeb
          ? await ApiService.fetchNotes()
          : await DatabaseHelper.instance.getNotes();
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
    if (kIsWeb) {
      await ApiService.saveNote(note);
    } else {
      await DatabaseHelper.instance.insertNote(note);
    }
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> update(Note note) async {
    if (kIsWeb) {
      await ApiService.saveNote(note);
    } else {
      await DatabaseHelper.instance.updateNote(note);
    }
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    if (kIsWeb) {
      await ApiService.deleteNote(id);
    } else {
      await DatabaseHelper.instance.deleteNote(id);
    }
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
