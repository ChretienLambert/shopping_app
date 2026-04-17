import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/user.dart';
import 'hive_service.dart';
import 'auth_utils.dart';
import 'logging_service.dart';
import '../utils/validators.dart';
import '../utils/error_handler.dart';

const _sessionTimeoutDays = 7;
const _lastActivityKey = 'auth_last_activity';

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  final _hive = HiveService.instance;

  // Sign up with email and password
  Future<supabase.AuthResponse> signUp(String email, String password, String name) async {
    // Validate inputs
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(message: emailError);
    }

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      throw ValidationException(message: passwordError);
    }

    final nameError = Validators.validateName(name);
    if (nameError != null) {
      throw ValidationException(message: nameError);
    }

    logger.info('Attempting sign up for $email');
    
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      
      if (response.user != null) {
        await _cacheUserLocally(response.user!, password, name);
      }
      
      return response;
    } catch (e) {
      logger.error('Sign up failed for $email', e);
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(message: ErrorHandler.getUserMessage(e), originalError: e);
    }
  }

  // Sign in with email and password
  Future<supabase.AuthResponse> signIn(String email, String password) async {
    // Validate inputs
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(message: emailError);
    }

    if (password.isEmpty) {
      throw ValidationException(message: 'Password is required');
    }

    logger.info('Attempting sign in for $email');

    // Try online sign-in first (skip connectivity check - let it fail naturally if offline)
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        logger.info('Online sign in successful');
        final name = response.user!.userMetadata?['full_name'] ?? 'User';
        await _cacheUserLocally(response.user!, password, name);
        await _updateLastActivity(); // Refresh session activity
      }
      return response;
    } catch (e) {
      logger.warning('Online sign in failed: $e. Falling back to local check.');
    }

    // Offline Fallback
    logger.info('Attempting offline login for $email');
    final users = _hive.usersBox.values.map((e) => User.fromJson(e)).toList();
    
    try {
      final localUser = users.firstWhere(
        (u) => u.email == email,
      );

      if (localUser.localPasswordHash != null) {
        if (AuthUtils.verifyPassword(password, localUser.localPasswordHash!)) {
          logger.info('Offline login successful');
          return supabase.AuthResponse(user: null); 
        }
      }
      
      throw AuthException(
        message: 'Invalid credentials or no offline account found.',
        code: 'INVALID_CREDENTIALS',
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        message: 'Invalid credentials or no offline account found.',
        code: 'INVALID_CREDENTIALS',
        originalError: e,
      );
    }
  }


  Future<void> signInAsGuest() async {
    logger.info('Development Bypass: Local Guest Mode only');
  }

  Future<void> _cacheUserLocally(supabase.User user, String password, String name) async {
    try {
      final hash = AuthUtils.hashPassword(password);
      
      final users = _hive.usersBox.values.map((e) => User.fromJson(e)).toList();
      final existingIndex = users.indexWhere((u) => u.email == user.email);
      
      final localUser = existingIndex != -1 ? users[existingIndex] : User(name: name, email: user.email!);
      localUser.serverId = user.id;
      localUser.email = user.email!;
      localUser.name = name;
      localUser.localPasswordHash = hash;
      localUser.updatedAt = DateTime.now();
      
      await _hive.usersBox.put(localUser.id, localUser.toJson());
      
      // Initialize session activity tracking
      await _updateLastActivity();
      
      logger.info('Cached user profile locally');
    } catch (e) {
      logger.error('Failed to cache user locally', e);
    }
  }

  /// Updates the last activity timestamp for session timeout tracking
  Future<void> _updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
  }

  /// Checks if the session has expired due to inactivity
  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivityStr = prefs.getString(_lastActivityKey);
    
    if (lastActivityStr == null) return false;
    
    try {
      final lastActivity = DateTime.parse(lastActivityStr);
      final now = DateTime.now();
      final daysSinceActivity = now.difference(lastActivity).inDays;
      
      return daysSinceActivity >= _sessionTimeoutDays;
    } catch (e) {
      logger.error('Error checking session expiration', e);
      return false;
    }
  }

  /// Gets remaining days before session timeout
  Future<int> getDaysUntilTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivityStr = prefs.getString(_lastActivityKey);
    
    if (lastActivityStr == null) return _sessionTimeoutDays;
    
    try {
      final lastActivity = DateTime.parse(lastActivityStr);
      final now = DateTime.now();
      final daysSinceActivity = now.difference(lastActivity).inDays;
      final remaining = _sessionTimeoutDays - daysSinceActivity;
      
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      logger.error('Error calculating timeout days', e);
      return _sessionTimeoutDays;
    }
  }

  /// Signs out user if session has expired
  Future<bool> signOutIfExpired() async {
    if (await isSessionExpired()) {
      logger.info('Session expired after $_sessionTimeoutDays days of inactivity. Signing out.');
      await signOut();
      await _clearSessionData();
      return true;
    }
    return false;
  }

  /// Clears session-related data
  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityKey);
  }

  // Sign out
  Future<void> signOut() async {
    logger.info('Signing out');
    await _supabase.auth.signOut();
    await _clearSessionData();
  }

  // Get current user session
  supabase.User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  supabase.Session? get currentSession => _supabase.auth.currentSession;

  // Check if session exists
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  // Stream of auth changes
  Stream<supabase.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
