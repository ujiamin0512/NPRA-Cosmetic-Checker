import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_db.dart';
import '../services/api_service.dart';

class SkinProfileDatabase {
  SkinProfileDatabase._();

  /// Updates the user's skin profile in Supabase via FastAPI and syncs the local cache.
  /// Returns null on success, or an error message on failure.
  static Future<String?> updateSkinProfile({
    required List<String> skinTypes,
    required List<String> skinConcerns,
    required List<String> allergies,
  }) async {
    final String? userId = UserDatabase.currentUserId;
    if (userId == null) return 'User not logged in';

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/skin_profile/update');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'skin_types': skinTypes,
          'skin_concerns': skinConcerns,
          'allergies': allergies,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Refresh local cache
          await UserDatabase.getCurrentUser();
          return null;
        } else {
          return data['message'] ?? 'Failed to update skin profile';
        }
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error updating skin profile: $e');
      return e.toString();
    }
  }

  /// Increments the wizard skip count in Supabase via FastAPI and syncs the local cache.
  static Future<bool> incrementWizardSkipCount() async {
    final String? userId = UserDatabase.currentUserId;
    if (userId == null) return false;

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/skin_profile/skip');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Refresh local cache
          await UserDatabase.getCurrentUser();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error incrementing wizard skip count: $e');
      return false;
    }
  }
}
