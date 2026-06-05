import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ChatApiService {
  static Future<String> initProductChat({
    required String productName,
    required String ingredients,
    required String skinProfile,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/chat/init/product');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_name': productName,
          'ingredients': ingredients,
          'skin_profile': skinProfile,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['reply'];
      } else {
        throw Exception('Failed to init chat. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling chat init API: $e');
    }
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String flowType,
    required List<Map<String, String>> history,
    required String newMessage,
    required Map<String, dynamic> context,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/chat/message');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'flow_type': flowType,
          'history': history,
          'new_message': newMessage,
          'context': context,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to send message. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calling chat message API: $e');
    }
  }
}
