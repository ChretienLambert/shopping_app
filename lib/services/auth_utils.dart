import 'package:bcrypt/bcrypt.dart';

class AuthUtils {
  /// Computes a bcrypt hash of the password with salt.
  /// Bcrypt is a secure password hashing algorithm with built-in salt.
  static String hashPassword(String password) {
    final salt = BCrypt.gensalt();
    return BCrypt.hashpw(password, salt);
  }

  /// Verifies a password against a bcrypt hash.
  static bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }
}
