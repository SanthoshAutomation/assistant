import 'package:flutter/material.dart';
import '../models/note.dart';
import '../db/database_helper.dart';
import 'package:uuid/uuid.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  final _uuid = const Uuid();

  Future<void> load() async {
    _notes = await DatabaseHelper.instance.getNotes();
    notifyListeners();
  }

  Future<void> add({required String title, required String body, required int color}) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.insertNote(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> update(Note note) async {
    await DatabaseHelper.instance.updateNote(note);
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
