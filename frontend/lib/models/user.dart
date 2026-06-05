import 'skin_profile.dart';

class User {
  // SQLite table & column names
  static const String tableName = 'users';
  static const String colId = 'id';
  static const String colUsername = 'username';
  static const String colEmail = 'email';
  static const String colPassword = 'password';
  static const String colConfirmPassword = 'confirm_password';

  final String? id;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  
  final SkinProfile skinProfile;

  const User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.skinProfile = const SkinProfile(),
  });

  /// Create a User instance from a database row.
  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map[colId] as String?,
      username: map[colUsername] as String,
      email: map[colEmail] as String,
      password: map[colPassword] as String? ?? '',
      confirmPassword: map[colConfirmPassword] as String? ?? '',
      skinProfile: SkinProfile.fromMap(map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      colId: id,
      colUsername: username,
      colEmail: email,
      colPassword: password,
      colConfirmPassword: confirmPassword,
      ...skinProfile.toMap(),
    };
  }
}
