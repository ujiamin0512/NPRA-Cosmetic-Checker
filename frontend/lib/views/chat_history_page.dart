import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../databases/chat_db.dart';
import '../models/chat_session.dart';
import 'chat_page.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<ChatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await ChatDb.instance.getAllSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  void _startNewChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          sessionId: const Uuid().v4(),
          flowType: 'home',
        ),
      ),
    ).then((_) => _loadSessions());
  }

  void _resumeChat(ChatSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          sessionId: session.id,
          flowType: session.flowType,
          productId: session.productId,
          productName: session.title,
        ),
      ),
    ).then((_) => _loadSessions());
  }

  @override
  Widget build(BuildContext context) {
    // Grouping by product title
    final Map<String, List<ChatSession>> grouped = {};
    for (var s in _sessions) {
      final key = s.title;
      grouped.putIfAbsent(key, () => []).add(s);
    }

    final productNames = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1D0CC2),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _showClearAllDialog,
              tooltip: 'Clear All History',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: productNames.length,
                  itemBuilder: (context, index) {
                    final productName = productNames[index];
                    final sessions = grouped[productName]!;
                    return _buildProductGroup(productName, sessions);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        backgroundColor: const Color(0xFF26A69A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Chat', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No chat history yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _startNewChat,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
            child: const Text('Start your first chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGroup(String productName, List<ChatSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            productName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D0CC2),
            ),
          ),
        ),
        ...sessions.map((s) => _buildSessionTile(s)),
        const Divider(),
      ],
    );
  }

  Widget _buildSessionTile(ChatSession session) {
    final dateStr = "${session.updatedAt.day}/${session.updatedAt.month}/${session.updatedAt.year} ${session.updatedAt.hour}:${session.updatedAt.minute.toString().padLeft(2, '0')}";

    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE0F2F1),
        child: Icon(Icons.history, color: Color(0xFF26A69A)),
      ),
      title: Text(
        session.flowType == 'product' ? 'Product Advice' : 'General Chat',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Last active: $dateStr'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _resumeChat(session),
      onLongPress: () => _showDeleteDialog(session),
    );
  }

  void _showDeleteDialog(ChatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text('Are you sure you want to delete this chat session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ChatDb.instance.deleteSession(session.id);
              if (mounted) {
                Navigator.pop(context);
                _loadSessions();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will permanently delete all chat sessions and messages. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ChatDb.instance.clearAll();
              if (mounted) {
                Navigator.pop(context);
                _loadSessions();
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
