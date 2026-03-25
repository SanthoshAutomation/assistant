import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';

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
          message: 'All data synced to cloud successfully! \u2728',
        );
      } else {
        return SyncResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: ${e.toString()}',
      );
    }
  }
}
