import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:uuid/uuid.dart';

import '../databases/chat_db.dart';
import '../databases/user_db.dart';
import '../models/chat_session.dart';
import '../models/chat_ai_response.dart';
import '../services/chat_api_service.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  final String flowType; // 'product' or 'home'
  final String? productId;
  final String? productName;

  const ChatPage({
    super.key,
    required this.sessionId,
    required this.flowType,
    this.productId,
    this.productName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final core.InMemoryChatController _chatController;

  final _user = const core.User(
    id: 'user',
    name: 'You',
    imageSource: 'assets/images/user_avatar.png',
  );
  final _ai = const core.User(
    id: 'ai',
    name: 'Skincare AI',
    imageSource: 'assets/images/logo.png',
  );

  bool _isLoading = true;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _chatController = core.InMemoryChatController();
    _loadChatSession();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _loadChatSession() async {
    final db = ChatDb.instance;
    final session = await db.getSession(widget.sessionId);

    if (session == null) {
      final newSession = ChatSession(
        id: widget.sessionId,
        userId: UserDatabase.currentUserId ?? '',
        title: widget.productName ?? 'General Skincare Chat',
        flowType: widget.flowType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productId: widget.productId,
      );
      await db.createSession(newSession);

      if (widget.flowType == 'product' && widget.productName != null) {
        _initProductChat();
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      final dbMessages = await db.getMessagesForSession(widget.sessionId);
      final List<core.Message> uiMessages = dbMessages.map((m) {
        return core.Message.text(
          id: m.id,
          authorId: m.role == 'user' ? _user.id : _ai.id,
          createdAt: m.createdAt,
          text: m.content,
        );
      }).toList();

      await _chatController.setMessages(uiMessages, animated: false);
      setState(() => _isLoading = false);
    }
  }

  String _buildAiDisplayText(ChatAiResponse r) {
    final buffer = StringBuffer(r.reply);
    if (r.flaggedIngredients.isNotEmpty) {
      buffer.write('\n\n⚠️ Flagged ingredients: ${r.flaggedIngredients.join(', ')}');
    }
    if (r.tips != null && r.tips!.isNotEmpty) {
      buffer.write('\n\n💡 Tip: ${r.tips}');
    }
    return buffer.toString();
  }

  Future<void> _initProductChat() async {
    const autoMessage = 'Hello! Please analyze this product for my skin.';
    try {
      final userDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'user',
        content: autoMessage,
        createdAt: DateTime.now(),
      );
      await ChatDb.instance.insertMessage(userDbMsg);
      await _chatController.insertMessage(core.Message.text(
        id: userDbMsg.id,
        authorId: _user.id,
        createdAt: userDbMsg.createdAt,
        text: userDbMsg.content,
      ));

      final aiResponse = await ChatApiService.sendToN8n(
        sessionId: widget.sessionId,
        userId: UserDatabase.currentUserId ?? '',
        productId: widget.productId,
        message: autoMessage,
        flowType: 'product_init',
      );

      final displayText = _buildAiDisplayText(aiResponse);
      final aiDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'assistant',
        content: displayText,
        createdAt: DateTime.now(),
      );
      await ChatDb.instance.insertMessage(aiDbMsg);
      await _chatController.insertMessage(core.Message.text(
        id: aiDbMsg.id,
        authorId: _ai.id,
        createdAt: aiDbMsg.createdAt,
        text: displayText,
      ));

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      await _chatController.insertMessage(core.Message.text(
        id: _uuid.v4(),
        authorId: _ai.id,
        createdAt: DateTime.now(),
        text: "I'm sorry, I'm currently having some trouble connecting. Please check your connection or try again!",
      ));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendPressed(String text) async {
    final userMsg = core.Message.text(
      id: _uuid.v4(),
      authorId: _user.id,
      createdAt: DateTime.now(),
      text: text,
    );
    await _chatController.insertMessage(userMsg);

    await ChatDb.instance.insertMessage(ChatMessageData(
      id: userMsg.id,
      sessionId: widget.sessionId,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    ));

    // Auto-update title on first home message
    if (widget.flowType == 'home') {
      final db = ChatDb.instance;
      final session = await db.getSession(widget.sessionId);
      if (session != null && session.title == 'General Skincare Chat') {
        final newTitle = text.length > 30 ? '${text.substring(0, 27)}...' : text;
        await db.createSession(ChatSession(
          id: session.id,
          userId: session.userId,
          title: newTitle,
          flowType: session.flowType,
          createdAt: session.createdAt,
          updatedAt: DateTime.now(),
          productId: session.productId,
        ));
      }
    }

    setState(() => _isLoading = true);

    try {
      final n8nFlowType = widget.flowType == 'product' ? 'product_ongoing' : 'home';

      final aiResponse = await ChatApiService.sendToN8n(
        sessionId: widget.sessionId,
        userId: UserDatabase.currentUserId ?? '',
        productId: widget.productId,
        message: text,
        flowType: n8nFlowType,
      );

      final displayText = _buildAiDisplayText(aiResponse);
      final aiDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'assistant',
        content: displayText,
        createdAt: DateTime.now(),
      );
      await ChatDb.instance.insertMessage(aiDbMsg);
      await _chatController.insertMessage(core.Message.text(
        id: aiDbMsg.id,
        authorId: _ai.id,
        createdAt: aiDbMsg.createdAt,
        text: displayText,
      ));
    } catch (e) {
      if (!mounted) return;
      final isTimeout = e.toString().contains('TimeoutException') || e.toString().contains('timed out');
      await _chatController.insertMessage(core.Message.text(
        id: _uuid.v4(),
        authorId: _ai.id,
        createdAt: DateTime.now(),
        text: isTimeout
            ? 'The server is warming up. Please wait a moment and try again!'
            : 'Something went wrong. Please check your connection and try again.',
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.flowType == 'product' ? 'Your Personal Beauty Advisor' : 'AI Beauty Advisor',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          if (widget.flowType == 'product')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : () {
                setState(() => _isLoading = true);
                _initProductChat();
              },
              tooltip: 'Retry Analysis',
            ),
        ],
      ),
      body: _isLoading && _chatController.messages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Chat(
              chatController: _chatController,
              currentUserId: _user.id,
              onMessageSend: _handleSendPressed,
              backgroundColor: const Color(0xffefe7dd),
              theme: core.ChatTheme(
                colors: core.ChatColors(
                  primary: const Color(0xffdcf8c6),
                  onPrimary: Colors.black,
                  surface: const Color(0xffefe7dd),
                  onSurface: Colors.black,
                  surfaceContainer: Colors.white,
                  surfaceContainerLow: Colors.white70,
                  surfaceContainerHigh: Colors.white,
                ),
                typography: core.ChatTypography.standard(),
                shape: const BorderRadius.all(Radius.circular(12)),
              ),
              builders: core.Builders(
                chatMessageBuilder: (context, message, index, animation, child, {isRemoved, required isSentByMe, groupStatus}) {
                  final isAi = message.authorId == _ai.id;
                  final user = isAi ? _ai : _user;

                  final avatar = CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(user.imageSource ?? 'assets/images/logo.png'),
                  );

                  return ChatMessage(
                    message: message,
                    index: index,
                    animation: animation,
                    isRemoved: isRemoved,
                    groupStatus: groupStatus,
                    horizontalPadding: 16,
                    leadingWidget: isSentByMe ? null : Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: avatar,
                    ),
                    trailingWidget: isSentByMe ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: avatar,
                    ) : null,
                    topWidget: groupStatus?.isFirst != false ? Padding(
                      padding: EdgeInsets.only(
                        top: 4.0,
                        bottom: 4.0,
                        left: isSentByMe ? 0 : 40.0,
                        right: isSentByMe ? 40.0 : 0,
                      ),
                      child: Text(
                        user.name ?? '',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ) : null,
                    child: child,
                  );
                },
              ),
              resolveUser: (id) async {
                if (id == _user.id) return _user;
                if (id == _ai.id) return _ai;
                return null;
              },
            ),
    );
  }
}
