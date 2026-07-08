import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis.dart';

class ApiService {
  static const String _renderUrl = 'https://npra-cosmetic-checker.onrender.com';
  // 10.0.2.2 reaches the host machine from an Android emulator;
  // 192.168.0.8 reaches it from a physical device on the same WiFi.
  static const List<String> _localUrls = [
    'http://10.0.2.2:8000',
    'http://192.168.0.8:8000',
    'http://10.72.142.96:8000',
    'http://10.72.202.87:8000',
    'http://172.20.10.2:8000',
  ];

  static String? _resolvedUrl;

  /// Tries Render first (short timeout so cold-start doesn't freeze the app).
  /// Falls back to local IPs if Render is unreachable.
  /// Returns null if nothing responds.
  static Future<String?> resolveBaseUrl() async {
    if (_resolvedUrl != null) return _resolvedUrl;
    try {
      final response = await http
          .get(Uri.parse('$_renderUrl/'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode < 500) {
        _resolvedUrl = _renderUrl;
        print('🌐 [ApiService] Using Render backend: $_renderUrl');
        return _renderUrl;
      }
    } catch (_) {}
    // Render unreachable — try local URLs (emulator then physical device)
    for (final localUrl in _localUrls) {
      try {
        final response = await http
            .get(Uri.parse('$localUrl/'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode < 500) {
          _resolvedUrl = localUrl;
          print('🏠 [ApiService] Using local backend: $localUrl');
          return localUrl;
        }
      } catch (_) {}
    }
    print('❌ [ApiService] No backend reachable.');
    return null;
  }

  static void resetUrl() {
    _resolvedUrl = null;
    print('🔄 [ApiService] URL cache cleared, will re-resolve on next request.');
  }

  static Future<String> getBaseUrl() async {
    final base = await resolveBaseUrl();
    if (base == null) {
      throw Exception(
        'Cannot reach the backend.\n\nPlease start the backend on your computer:\n  uvicorn main:app --host 0.0.0.0 --port 8000\n\nMake sure your phone and PC are on the same WiFi network.'
      );
    }
    return base;
  }

  static Future<AnalysisResponse> analyzeIngredients(String ingredients) async {
    final base = await resolveBaseUrl();
    if (base == null) {
      throw Exception(
        'Cannot reach the backend.\n\nPlease start the backend on your computer:\n  uvicorn main:app --host 0.0.0.0 --port 8000\n\nMake sure your phone and PC are on the same WiFi network.'
      );
    }
    final url = Uri.parse('$base/analyze');

    print('🚀 [ApiService] Sending request to: $url');
    print('📦 [ApiService] Ingredients: $ingredients');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ingredients_str': ingredients,
        }),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          throw Exception('Connection timed out. Is the backend running? (Note: If using a physical Android device, change 10.0.2.2 to your PC local IP address like 192.168.1.x)');
        },
      );

      print('✅ [ApiService] Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AnalysisResponse.fromJson(data);
      } else {
        throw Exception('Failed to analyze ingredients. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [ApiService] Error: $e');
      throw Exception('Error calling analysis API: $e');
    }
  }
}
