import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:uuid/uuid.dart';

import '../databases/chat_db.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  final String flowType; // 'product' or 'home'
  final String? productId;
  final String? productName;
  final String? ingredients;
  final String skinProfile;

  const ChatPage({
    super.key,
    required this.sessionId,
    required this.flowType,
    this.productId,
    this.productName,
    this.ingredients,
    required this.skinProfile,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final core.InMemoryChatController _chatController;
  
  // 使用 core.User 而不是 types.User
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
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      final dbMessages = await db.getMessagesForSession(widget.sessionId);
      // 使用 core.Message.text
      final List<core.Message> uiMessages = dbMessages.map((m) {
        return core.Message.text(
          id: m.id,
          authorId: m.role == 'user' ? _user.id : _ai.id,
          createdAt: m.createdAt,
          text: m.content,
        );
      }).toList();

      await _chatController.setMessages(uiMessages, animated: false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initProductChat() async {
    try {
      // 1. Add User's initial prompt message
      final userPrompt = "Hello! Can you help me analyze ${widget.productName} for my ${widget.skinProfile} skin?\n\nHere are the ingredients:\n${widget.ingredients ?? 'Not provided'}";
      
      final userDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'user',
        content: userPrompt,
        createdAt: DateTime.now(),
      );
      await ChatDb.instance.insertMessage(userDbMsg);

      final userUiMsg = core.Message.text(
        id: userDbMsg.id,
        authorId: _user.id,
        createdAt: userDbMsg.createdAt,
        text: userDbMsg.content,
      );
      await _chatController.insertMessage(userUiMsg);

      // 2. Get and show AI reply
      final reply = await ChatApiService.initProductChat(
        productName: widget.productName!,
        ingredients: widget.ingredients ?? '',
        skinProfile: widget.skinProfile,
      );

      final aiDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'assistant',
        content: reply,
        createdAt: DateTime.now(),
      );
      await ChatDb.instance.insertMessage(aiDbMsg);

      final aiUiMsg = core.Message.text(
        id: aiDbMsg.id,
        authorId: _ai.id,
        createdAt: aiDbMsg.createdAt,
        text: aiDbMsg.content,
      );

      await _chatController.insertMessage(aiUiMsg);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // 3. On error, show a polite AI message instead of just a SnackBar
      final errorDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'assistant',
        content: "I'm sorry, I'm currently having some trouble connecting to the brain. 🧠 Please check your connection or try again in a few seconds!",
        createdAt: DateTime.now(),
      );
      // We don't necessarily need to save the error message to DB, but let's show it in UI
      final errorUiMsg = core.Message.text(
        id: errorDbMsg.id,
        authorId: _ai.id,
        createdAt: errorDbMsg.createdAt,
        text: errorDbMsg.content,
      );
      await _chatController.insertMessage(errorUiMsg);
      
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _handleSendPressed(String text) async {
    final userTextMsg = core.Message.text(
      id: _uuid.v4(),
      authorId: _user.id,
      createdAt: DateTime.now(),
      text: text,
    );
    await _chatController.insertMessage(userTextMsg);

    final userDbMsg = ChatMessageData(
      id: userTextMsg.id,
      sessionId: widget.sessionId,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    await ChatDb.instance.insertMessage(userDbMsg);

    final messages = _chatController.messages;
    // Flyer Chat newest messages are at index 0
    final history = messages.skip(1).toList().reversed.map((m) {
      return m.map(
        text: (t) => {
          'role': t.authorId == _user.id ? 'user' : 'assistant',
          'content': t.text,
        },
        textStream: (_) => {'role': 'assistant', 'content': ''},
        image: (_) => {'role': 'assistant', 'content': '[image]'},
        file: (_) => {'role': 'assistant', 'content': '[file]'},
        video: (_) => {'role': 'assistant', 'content': '[video]'},
        audio: (_) => {'role': 'assistant', 'content': '[audio]'},
        system: (s) => {'role': 'system', 'content': s.text},
        custom: (_) => {'role': 'assistant', 'content': '[custom]'},
        unsupported: (_) => {'role': 'assistant', 'content': '[unsupported]'},
      );
    }).toList();

    // Auto-update title if it's the first user message in a general chat
    if (widget.flowType == 'home' && history.isEmpty) {
      final db = ChatDb.instance;
      final session = await db.getSession(widget.sessionId);
      if (session != null && session.title == 'General Skincare Chat') {
        // Update title with first few words of the message
        String newTitle = text.length > 30 ? '${text.substring(0, 27)}...' : text;
        await db.createSession(ChatSession(
          id: session.id,
          title: newTitle,
          flowType: session.flowType,
          createdAt: session.createdAt,
          updatedAt: DateTime.now(),
          productId: session.productId,
        ));
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ChatApiService.sendMessage(
        flowType: widget.flowType,
        history: history,
        newMessage: text,
        context: {
          'skin_profile': widget.skinProfile,
          'product_name': widget.productName,
          'ingredients': widget.ingredients,
        },
      );

      final aiReply = response['reply'] as String? ?? "I'm sorry, I couldn't understand that.";
      final recommendations = response['recommendations'] as List?;

      String finalReplyText = aiReply;
      if (recommendations != null && recommendations.isNotEmpty) {
        finalReplyText += '\n\n**Recommendations:**\n';
        for (var rec in recommendations) {
          finalReplyText += '- ${rec['product']} (${rec['brand']})\n';
        }
      }

      final aiDbMsg = ChatMessageData(
        id: _uuid.v4(),
        sessionId: widget.sessionId,
        role: 'assistant',
        content: finalReplyText,
        createdAt: DateTime.now(),
      );
      await ChatDb.instance.insertMessage(aiDbMsg);

      final aiUiMsg = core.Message.text(
        id: aiDbMsg.id,
        authorId: _ai.id,
        createdAt: aiDbMsg.createdAt,
        text: aiDbMsg.content,
      );

      await _chatController.insertMessage(aiUiMsg);
    } catch (e) {
      if (!mounted) return;
      final errorUiMsg = core.Message.text(
        id: _uuid.v4(),
        authorId: _ai.id,
        createdAt: DateTime.now(),
        text: "I'm having trouble responding right now. 🚧 Please try sending your message again!",
      );
      await _chatController.insertMessage(errorUiMsg);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                setState(() {
                  _isLoading = true;
                });
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
              backgroundColor: const Color(0xffefe7dd), // WhatsApp background color
              theme: core.ChatTheme(
                colors: core.ChatColors(
                  primary: const Color(0xffdcf8c6), // WhatsApp user bubble color
                  onPrimary: Colors.black,
                  surface: const Color(0xffefe7dd), // WhatsApp background
                  onSurface: Colors.black,
                  surfaceContainer: Colors.white, // WhatsApp AI bubble color
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
                        left: isSentByMe ? 0 : 40.0, // Indent to align with bubble after AI avatar
                        right: isSentByMe ? 40.0 : 0, // Indent to align with bubble before User avatar
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
