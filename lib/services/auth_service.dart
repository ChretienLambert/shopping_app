import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user.dart';
import 'hive_service.dart';
import 'auth_utils.dart';
import 'logging_service.dart';

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;
  final _hive = HiveService.instance;

  // Sign up with email and password
  Future<supabase.AuthResponse> signUp(String email, String password, String name) async {
    logger.info('Attempting sign up for $email');
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    
    if (response.user != null) {
      await _cacheUserLocally(response.user!, password, name);
    }
    
    return response;
  }

  // Sign in with email and password
  Future<supabase.AuthResponse> signIn(String email, String password) async {
    logger.info('Attempting sign in for $email');
    
    final connectivityResults = await Connectivity().checkConnectivity();
    final isOnline = connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );

    if (isOnline) {
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (response.user != null) {
          logger.info('Online sign in successful');
          final name = response.user!.userMetadata?['full_name'] ?? 'User';
          await _cacheUserLocally(response.user!, password, name);
        }
        return response;
      } catch (e) {
        logger.warning('Online sign in failed: $e. Falling back to local check.');
      }
    }

    // Offline Fallback
    logger.info('Attempting offline login for $email');
    final users = _hive.usersBox.values.map((e) => User.fromJson(e)).toList();
    final localUser = users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Invalid credentials or no offline account found.'),
    );

    if (localUser.localPasswordHash != null) {
      if (AuthUtils.verifyPassword(password, localUser.localPasswordHash!)) {
        logger.info('Offline login successful');
        return supabase.AuthResponse(user: null); 
      }
    }

    throw Exception('Invalid credentials or no offline account found.');
  }

  // Development Bypass (Secure Manager Account)
  Future<void> signInAsDummy() async {
    const managerEmail = 'wandjichretien@gmail.com';
    const managerPassword = '9+Kh9mK@BNT.cXr';
    
    logger.info('Attempting Manager Bypass Sign-in');
    
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: managerEmail,
        password: managerPassword,
      );
      
      if (response.user != null) {
        logger.info('Manager Bypass successful: ${response.user!.id}');
        return;
      }
    } catch (e) {
      logger.error('Manager Bypass failed. Check if email/password matches the Dashboard.', e);
      rethrow;
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
      logger.info('Cached user profile locally');
    } catch (e) {
      logger.error('Failed to cache user locally', e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    logger.info('Signing out');
    await _supabase.auth.signOut();
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
