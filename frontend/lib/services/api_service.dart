import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io' show Platform;
import '../models/analysis.dart';

class ApiService {
  static String get baseUrl {
    // If you are using a physical Android device, change this to your PC's local IP (e.g. '192.168.1.100')
    // Android Emulator MUST use 10.0.2.2 to access your PC's localhost.
    const String localIp = '10.0.2.2'; 

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://$localIp:8000'; 
    } else {
      return 'http://127.0.0.1:8000'; // Windows, iOS Simulator, MacOS, Linux
    }
  }

  static Future<AnalysisResponse> analyzeIngredients(String ingredients) async {
    final url = Uri.parse('$baseUrl/analyze');

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
