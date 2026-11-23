
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';

class AuthService {
  final AppDatabase _db = AppDatabase.instance;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (name.trim().isEmpty ||
        cleanEmail.isEmpty ||
        password.length < 8) {
      return 'Enter valid details. Password must be at least 8 characters.';
    }

    try {
      final existing = await _db.getAll(
        'users',
        where: 'email = ?',
        whereArgs: [cleanEmail],
      );

      if (existing.isNotEmpty) {
        return 'An account with this email already exists.';
      }

      final passwordHash = BCrypt.hashpw(
        password,
        BCrypt.gensalt(),
      );

      final userId = await _db.insert('users', {
        'name': name.trim(),
        'email': cleanEmail,
        'password_hash': passwordHash,
        'created_at': DateTime.now().toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);

      return null;
    } catch (_) {
      return 'Registration failed. Please try again.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final users = await _db.getAll(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()],
      );

      if (users.isEmpty) {
        return 'Invalid email or password.';
      }

      final user = users.first;
      final storedHash = user['password_hash'] as String;

      if (!BCrypt.checkpw(password, storedHash)) {
        return 'Invalid email or password.';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id'] as int);

      return null;
    } catch (_) {
      return 'Login failed. Please try again.';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}
