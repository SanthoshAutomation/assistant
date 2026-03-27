import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/note.dart';
import '../models/todo.dart';
import '../models/event.dart';

class SyncResult {
  final bool success;
  final String message;
  const SyncResult({required this.success, required this.message});
}

class SyncService {
  static const _apiUrlKey = 'api_base_url';

  static Future<String?> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey);
  }

  static Future<void> setApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url.trim());
  }

  /// Push all local data up to the server.
  static Future<SyncResult> syncToCloud() async {
    final baseUrl = await getApiUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      return const SyncResult(
        success: false,
        message: 'No API URL configured. Please set it in Settings.',
      );
    }
    try {
      final data = await DatabaseHelper.instance.getAllForSync();
      final response = await http
          .post(
            Uri.parse('$baseUrl/sync.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await DatabaseHelper.instance.markAllSynced();
        return const SyncResult(
          success: true,
          message: 'All data synced to cloud! ✨',
        );
      }
      return SyncResult(
        success: false,
        message: 'Server error: ${response.statusCode}',
      );
    } catch (e) {
      return SyncResult(success: false, message: 'Sync failed: $e');
    }
  }

  /// Pull all data from the server and upsert into local SQLite.
  /// Use this when reinstalling or switching phones.
  static Future<SyncResult> pullFromCloud() async {
    final baseUrl = await getApiUrl();
    if (baseUrl == null || baseUrl.isEmpty) {
      return const SyncResult(
        success: false,
        message: 'No API URL configured. Please set it in Settings.',
      );
    }
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/pull.php'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return SyncResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final db = DatabaseHelper.instance;
      int notes = 0, todos = 0, events = 0;

      for (final m in (data['notes'] as List? ?? [])) {
        await db.insertNote(Note.fromServerMap(Map<String, dynamic>.from(m as Map)));
        notes++;
      }
      for (final m in (data['todos'] as List? ?? [])) {
        await db.insertTodo(Todo.fromServerMap(Map<String, dynamic>.from(m as Map)));
        todos++;
      }
      for (final m in (data['events'] as List? ?? [])) {
        await db.insertEvent(Event.fromServerMap(Map<String, dynamic>.from(m as Map)));
        events++;
      }

      return SyncResult(
        success: true,
        message: 'Pulled from cloud: $notes notes, $todos todos, $events events 😊',
      );
    } catch (e) {
      return SyncResult(success: false, message: 'Pull failed: $e');
    }
  }
}
