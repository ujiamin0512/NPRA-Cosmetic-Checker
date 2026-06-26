import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_ai_response.dart';

class ChatApiService {
  static const _n8nUrl = 'https://ujiamin0512.app.n8n.cloud/webhook/cosmetic-chat';
  static const _timeout = Duration(seconds: 90);

  static Future<ChatAiResponse> sendToN8n({
    required String sessionId,
    required String userId,
    String? productId,
    required String message,
    required String flowType,
  }) async {
    final response = await http.post(
      Uri.parse(_n8nUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'user_id': userId,
        'product_id': productId,
        'message': message,
        'flow_type': flowType,
      }),
    ).timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ChatAiResponse.fromJson(data);
    } else {
      throw Exception('n8n returned status ${response.statusCode}');
    }
  }
}
