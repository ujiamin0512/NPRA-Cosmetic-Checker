import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_session.dart';

class ChatDb {
  static final ChatDb instance = ChatDb._init();
  static Database? _database;

  ChatDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
CREATE TABLE chat_sessions (
  id $idType,
  title $textType,
  flow_type $textType,
  created_at $textType,
  updated_at $textType,
  product_id $textTypeNull
)
''');

    await db.execute('''
CREATE TABLE chat_messages (
  id $idType,
  session_id $textType,
  role $textType,
  content $textType,
  created_at $textType,
  FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
)
''');
  }

  // Session Operations
  Future<void> createSession(ChatSession session) async {
    final db = await instance.database;
    await db.insert('chat_sessions', session.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ChatSession?> getSession(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'chat_sessions',
      columns: ['id', 'title', 'flow_type', 'created_at', 'updated_at', 'product_id'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ChatSession.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<ChatSession?> getSessionByProductId(String productId) async {
    final db = await instance.database;
    final maps = await db.query(
      'chat_sessions',
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ChatSession.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<ChatSession>> getAllSessions() async {
    final db = await instance.database;
    const orderBy = 'updated_at DESC';
    final result = await db.query('chat_sessions', orderBy: orderBy);
    return result.map((json) => ChatSession.fromMap(json)).toList();
  }

  Future<void> updateSessionTime(String id) async {
    final db = await instance.database;
    await db.update(
      'chat_sessions',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSession(String id) async {
    final db = await instance.database;
    return await db.delete(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Message Operations
  Future<void> insertMessage(ChatMessageData message) async {
    final db = await instance.database;
    await db.insert('chat_messages', message.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await updateSessionTime(message.sessionId);
  }

  Future<List<ChatMessageData>> getMessagesForSession(String sessionId) async {
    final db = await instance.database;
    final result = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return result.map((json) => ChatMessageData.fromMap(json)).toList();
  }

  /// Clear all chat history (sessions and messages)
  Future<void> clearAll() async {
    final db = await instance.database;
    // chat_messages will be cleared automatically due to ON DELETE CASCADE
    await db.delete('chat_sessions');
  }
}
