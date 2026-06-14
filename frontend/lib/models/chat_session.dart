class ChatSession {
  final String id;
  final String userId;
  final String title;
  final String flowType; // 'product' or 'home'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? productId; // optional, for product flow

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.flowType,
    required this.createdAt,
    required this.updatedAt,
    this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'flow_type': flowType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product_id': productId,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      userId: map['user_id'] ?? '',
      title: map['title'],
      flowType: map['flow_type'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      productId: map['product_id'],
    );
  }
}

class ChatMessageData {
  final String id;
  final String sessionId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime createdAt;

  ChatMessageData({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChatMessageData.fromMap(Map<String, dynamic> map) {
    return ChatMessageData(
      id: map['id'],
      sessionId: map['session_id'],
      role: map['role'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
