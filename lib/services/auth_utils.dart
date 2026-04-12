import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthUtils {
  /// Computes a SHA-256 hash of the password.
  /// Note: In a production app, use a salt and a stronger algorithm like BCrypt/Argon2.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a password against a hash.
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
}
