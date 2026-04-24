import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/app_session.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'app_config.dart';
import 'auth_utils.dart';
import 'hive_service.dart';
import 'logging_service.dart';
import 'session_policy.dart';

const _sessionTimeoutDays = 7;
const _lastActivityKey = 'auth_last_activity';
const _activeSessionKey = 'auth_active_session';

class AuthService {
  AuthService(this._config) {
    _bootstrap();
  }

  final AppConfig _config;
  final _hive = HiveService.instance;
  final _sessionController = StreamController<AppSession?>.broadcast();

  AppSession? _currentAppSession;

  Future<void> _bootstrap() async {
    _currentAppSession = await _readStoredSession();
    _sessionController.add(_currentAppSession);

    authStateChanges.listen((state) async {
      final user = state.session?.user;
      if (user == null) {
        if (_currentAppSession?.isOnline == true) {
          await _persistSession(null);
        }
        return;
      }

      final session = AppSession(
        mode: AppSessionMode.online,
        userId: user.id,
        serverUserId: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['full_name'] as String? ?? 'User',
        authenticatedAt: DateTime.now(),
      );
      await _persistSession(session);
    }, onError: (error, stack) {
      logger.warning('Supabase auth state stream error: $error');
      // We do not want to propagate this error to our session stream
      // if we already have a session, to keep the app working offline.
    });
  }

  supabase.SupabaseClient? get _client {
    if (!_config.hasSupabaseConfig) {
      return null;
    }
    try {
      return supabase.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<supabase.AuthResponse> signUp(
    String email,
    String password,
    String name,
  ) async {
    _validateCredentials(email, password, name: name);

    final client = _client;
    if (client == null) {
      throw AuthException(
        message:
            'Cloud auth is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
        code: 'CONFIG_MISSING',
      );
    }

    logger.info('Attempting sign up for $email');

    try {
      final response = await client.auth.signUp(
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

  Future<supabase.AuthResponse> signIn(String email, String password) async {
    _validateCredentials(email, password);

    logger.info('Attempting sign in for $email');
    final client = _client;

    if (client != null) {
      try {
        final response = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          logger.info('Online sign in successful');
          final name = response.user!.userMetadata?['full_name'] as String? ?? 'User';
          await _cacheUserLocally(response.user!, password, name);
          await _persistSession(
            AppSession(
              mode: AppSessionMode.online,
              userId: response.user!.id,
              serverUserId: response.user!.id,
              email: response.user!.email ?? email,
              name: name,
              authenticatedAt: DateTime.now(),
            ),
          );
          await _updateLastActivity();
        }
        return response;
      } catch (e) {
        logger.warning('Online sign in failed: $e. Falling back to local check.');
      }
    }

    final localUser = await _findLocalUser(email);
    if (localUser == null ||
        localUser.localPasswordHash == null ||
        !AuthUtils.verifyPassword(password, localUser.localPasswordHash!)) {
      throw AuthException(
        message: 'Invalid credentials or no offline account found.',
        code: 'INVALID_CREDENTIALS',
      );
    }

    final session = AppSession(
      mode: AppSessionMode.offline,
      userId: localUser.id,
      serverUserId: localUser.serverId,
      email: localUser.email,
      name: localUser.name,
      authenticatedAt: DateTime.now(),
    );
    await _persistSession(session);
    await _updateLastActivity();
    logger.info('Offline login successful');
    return supabase.AuthResponse(user: null);
  }

  Future<void> signInAsGuest() async {
    await _persistSession(
      AppSession(
        mode: AppSessionMode.guest,
        userId: 'guest',
        email: 'guest@local',
        name: 'Guest',
        authenticatedAt: DateTime.now(),
      ),
    );
    await _updateLastActivity();
    logger.info('Guest mode enabled');
  }

  Future<void> signOut() async {
    logger.info('Signing out');
    try {
      await _client?.auth.signOut();
    } catch (e) {
      logger.warning('Remote sign out failed: $e');
    }
    await _clearSessionData();
    await _persistSession(null);
  }

  Future<void> _cacheUserLocally(
    supabase.User user,
    String password,
    String name,
  ) async {
    try {
      final hash = AuthUtils.hashPassword(password);
      final localUser = await _findLocalUser(user.email!) ??
          User(name: name, email: user.email!);

      localUser.serverId = user.id;
      localUser.email = user.email!;
      localUser.name = name;
      localUser.localPasswordHash = hash;
      localUser.updatedAt = DateTime.now();

      await _hive.usersBox.put(localUser.id, localUser.toJson());
      await _updateLastActivity();
      logger.info('Cached user profile locally');
    } catch (e) {
      logger.error('Failed to cache user locally', e);
    }
  }

  Future<User?> _findLocalUser(String email) async {
    final users = _hive.usersBox.values
        .whereType<Map>()
        .map(User.fromJson)
        .toList(growable: false);
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  void _validateCredentials(String email, String password, {String? name}) {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      throw ValidationException(message: emailError);
    }

    if (name != null) {
      final nameError = Validators.validateName(name);
      if (nameError != null) {
        throw ValidationException(message: nameError);
      }
    }

    if (password.isEmpty) {
      throw ValidationException(message: 'Password is required');
    }

    if (name != null) {
      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        throw ValidationException(message: passwordError);
      }
    }
  }

  Future<void> _persistSession(AppSession? session) async {
    _currentAppSession = session;
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_activeSessionKey);
    } else {
      await prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
    }
    _sessionController.add(_currentAppSession);
  }

  Future<AppSession?> _readStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_activeSessionKey);
    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    try {
      return AppSession.fromJson(jsonDecode(rawSession) as Map<String, dynamic>);
    } catch (e) {
      logger.warning('Stored auth session was invalid and has been cleared: $e');
      await prefs.remove(_activeSessionKey);
      return null;
    }
  }

  Future<void> _updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
  }

  Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivityStr = prefs.getString(_lastActivityKey);
    if (lastActivityStr == null) return false;

    try {
      return SessionPolicy.isExpired(
        lastActivity: DateTime.parse(lastActivityStr),
        now: DateTime.now(),
        timeoutDays: _sessionTimeoutDays,
      );
    } catch (e) {
      logger.error('Error checking session expiration', e);
      return false;
    }
  }

  Future<int> getDaysUntilTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivityStr = prefs.getString(_lastActivityKey);
    if (lastActivityStr == null) return _sessionTimeoutDays;

    try {
      return SessionPolicy.remainingDays(
        lastActivity: DateTime.parse(lastActivityStr),
        now: DateTime.now(),
        timeoutDays: _sessionTimeoutDays,
      );
    } catch (e) {
      logger.error('Error calculating timeout days', e);
      return _sessionTimeoutDays;
    }
  }

  Future<bool> signOutIfExpired() async {
    if (await isSessionExpired()) {
      logger.info(
        'Session expired after $_sessionTimeoutDays days of inactivity. Signing out.',
      );
      await signOut();
      return true;
    }
    return false;
  }

  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityKey);
    await prefs.remove(_activeSessionKey);
  }

  AppSession? get currentAppSession => _currentAppSession;
  bool get isAuthenticated => SessionPolicy.canUseOfflineSession(_currentAppSession);

  supabase.User? get currentUser => _client?.auth.currentUser;
  supabase.Session? get currentSession => _client?.auth.currentSession;

  Stream<supabase.AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  Stream<AppSession?> get sessionChanges async* {
    yield _currentAppSession;
    yield* _sessionController.stream;
  }
}
