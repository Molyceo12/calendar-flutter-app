import 'package:flutter/material.dart';
import 'package:calendar_app/models/note.dart';
import 'package:calendar_app/services/database_helper.dart';

class SQLiteProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SQLiteProvider() {
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _databaseHelper.getNotes();
    } catch (e) {
      _error = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Note?> getNote(int id) async {
    try {
      return await _databaseHelper.getNote(id);
    } catch (e) {
      _error = 'Failed to get note: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addNote(String title, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final note = Note(
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      final id = await _databaseHelper.insertNote(note);
      final newNote = note.copyWith(id: id);
      _notes.insert(0, newNote);
      return true;
    } catch (e) {
      _error = 'Failed to add note: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      await _databaseHelper.updateNote(updatedNote);
      
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNote;
      }
      return true;
    } catch (e) {
      _error = 'Failed to update note: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNote(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseHelper.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      return true;
    } catch (e) {
      _error = 'Failed to delete note: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
