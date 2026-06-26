import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/user.dart' as model;
import '../models/skin_profile.dart';
import '../services/api_service.dart';

class EmailNotVerifiedException implements Exception {
  final String email;
  const EmailNotVerifiedException(this.email);
}

class UserDatabase {
  UserDatabase._();

  static Database? _cachedDb;
  static String? _currentUserId;

  static String? get currentUserId => _currentUserId;

  static Future<Database> db() async {
    if (_cachedDb != null) return _cachedDb!;

    final String path = p.join(await getDatabasesPath(), 'local_users.db');
    _cachedDb = await openDatabase(
      path,
      version: 4,
      onCreate: (Database database, int version) async {
        await _createTable(database);
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        if (oldVersion < 4) {
          await database.execute('DROP TABLE IF EXISTS ${model.User.tableName}');
          await _createTable(database);
        }
      },
    );
    return _cachedDb!;
  }

  static Future<void> _createTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS ${model.User.tableName}(
        ${model.User.colId} TEXT PRIMARY KEY NOT NULL,
        ${model.User.colUsername} TEXT,
        ${model.User.colEmail} TEXT,
        ${model.User.colPassword} TEXT,
        ${model.User.colConfirmPassword} TEXT,
        profile_completed INTEGER,
        wizard_skip_count INTEGER,
        skin_types TEXT,
        skin_concerns TEXT,
        allergies TEXT
      )
    ''');
  }

  static Future<void> saveUserLocal(model.User user) async {
    final database = await db();
    await database.insert(
      model.User.tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<model.User?> getUserLocal(String id) async {
    final database = await db();
    final rows = await database.query(
      model.User.tableName,
      where: '${model.User.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return model.User.fromMap(rows.first);
    }
    return null;
  }

  static Future<String?> createUser(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['user_id'] != null) {
          return data['user_id'] as String;
        } else {
          throw Exception(data['message'] ?? 'Sign up failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  static Future<bool> emailExists(String email) async {
    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/email_exists');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['exists'] == true;
        }
      }
    } catch (e) {
      print('Error checking email exists: $e');
    }
    return false;
  }

  static Future<void> resendVerificationEmail(String email) async {
    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/resend_verification');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Failed to resend verification email');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  static Future<model.User?> validateCredentials(String email, String password) async {
    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'error' && data['message'] == 'EMAIL_NOT_VERIFIED') {
          throw EmailNotVerifiedException(email);
        }
        if (data['status'] == 'success' && data['user'] != null) {
          final userJson = data['user'];
          final skinProfileJson = userJson['skinProfile'];
          
          final user = model.User(
            id: userJson['id'] as String,
            username: userJson['username'] as String,
            email: userJson['email'] as String,
            password: '',
            confirmPassword: '',
            skinProfile: SkinProfile(
              profileCompleted: skinProfileJson != null && skinProfileJson['profileCompleted'] == true,
              wizardSkipCount: skinProfileJson != null ? (skinProfileJson['wizardSkipCount'] as int? ?? 0) : 0,
              skinTypes: skinProfileJson != null && skinProfileJson['skinTypes'] != null ? List<String>.from(skinProfileJson['skinTypes']) : [],
              skinConcerns: skinProfileJson != null && skinProfileJson['skinConcerns'] != null ? List<String>.from(skinProfileJson['skinConcerns']) : [],
              allergies: skinProfileJson != null && skinProfileJson['allergies'] != null ? List<String>.from(skinProfileJson['allergies']) : [],
            ),
          );
          _currentUserId = user.id;
          await saveUserLocal(user);
          return user;
        }
      }
    } catch (e) {
      print('Error validating credentials: $e');
    }
    return null;
  }

  static Future<model.User?> getCurrentUser() async {
    if (_currentUserId == null) {
      try {
        final dbInst = await db();
        final List<Map<String, dynamic>> maps = await dbInst.query(model.User.tableName, limit: 1);
        if (maps.isNotEmpty) {
          _currentUserId = maps.first[model.User.colId] as String;
        }
      } catch (e) {
        print('Error reading local cache for startup user ID: $e');
      }
    }

    final String? userId = currentUserId;
    if (userId == null) return null;

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/user');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['user'] != null) {
          final userJson = data['user'];
          final skinProfileJson = userJson['skinProfile'];
          
          final user = model.User(
            id: userJson['id'] as String,
            username: userJson['username'] as String,
            email: userJson['email'] as String,
            password: '',
            confirmPassword: '',
            skinProfile: SkinProfile(
              profileCompleted: skinProfileJson != null && skinProfileJson['profileCompleted'] == true,
              wizardSkipCount: skinProfileJson != null ? (skinProfileJson['wizardSkipCount'] as int? ?? 0) : 0,
              skinTypes: skinProfileJson != null && skinProfileJson['skinTypes'] != null ? List<String>.from(skinProfileJson['skinTypes']) : [],
              skinConcerns: skinProfileJson != null && skinProfileJson['skinConcerns'] != null ? List<String>.from(skinProfileJson['skinConcerns']) : [],
              allergies: skinProfileJson != null && skinProfileJson['allergies'] != null ? List<String>.from(skinProfileJson['allergies']) : [],
            ),
          );
          await saveUserLocal(user);
          return user;
        }
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return await getUserLocal(userId);
  }

  static Future<int> updateProfile({
    String? username,
    String? email,
  }) async {
    if (_currentUserId == null) {
      await getCurrentUser();
    }
    final String? userId = currentUserId;
    if (userId == null) return 0;

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/update_profile');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'username': username,
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await getCurrentUser(); // Update local cache
          return 1;
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
    return 0;
  }

  static Future<int> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) return 0;

    if (_currentUserId == null) {
      await getCurrentUser();
    }
    final String? userId = currentUserId;
    if (userId == null) return 0;

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/update_password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'new_password': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return 1;
        }
      }
    } catch (e) {
      print('Error updating password: $e');
    }
    return 0;
  }

  static Future<void> clearLocalUser(String id) async {
    final database = await db();
    await database.delete(
      model.User.tableName,
      where: '${model.User.colId} = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCurrentUser() async {
    if (_currentUserId == null) {
      await getCurrentUser();
    }
    final String? userId = currentUserId;
    if (userId == null) return 0;

    final url = Uri.parse('${await ApiService.getBaseUrl()}/api/auth/delete_user');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          await clearLocalUser(userId);
          _currentUserId = null;
          return 1;
        }
      }
    } catch (e) {
      print('Error deleting current user: $e');
    }
    return 0;
  }

  static Future<void> signOut() async {
    if (_currentUserId != null) {
      await clearLocalUser(_currentUserId!);
    }
    _currentUserId = null;
  }
}