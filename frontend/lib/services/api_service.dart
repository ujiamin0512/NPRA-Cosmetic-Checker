import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis.dart';

class ApiService {
  static String get baseUrl {
    // Production backend deployed on Render — replace with your actual Render URL after deploying
    const String renderUrl = 'https://npra-cosmetic-checker-backend.onrender.com';
    return renderUrl;
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
