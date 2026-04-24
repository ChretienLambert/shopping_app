import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/hive_service.dart';
import 'services/logging_service.dart';
import 'services/app_config.dart';
import 'screens/main_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/sync_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logging Service
  await logger.init();

  // Initialize dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    logger.warning('Could not load .env file: $e');
  }

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.error('FLUTTER_ERROR', details.exception, details.stack);
  };

  // Catch asynchronous Dart errors
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('PLATFORM_ERROR', error, stack);
    return true;
  };

  final appConfig = AppConfig.fromEnvironment();
  if (!appConfig.hasSupabaseConfig) {
    logger.warning(
      'Supabase config missing. Cloud sync and online auth are disabled until '
      'SUPABASE_URL and SUPABASE_ANON_KEY are provided via --dart-define, '
      'desktop environment variables, or a .env file.',
    );
  } else {
    await Supabase.initialize(
      url: appConfig.supabaseUrl,
      anonKey: appConfig.supabaseAnonKey,
    );
  }

  await HiveService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(appConfig),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final languageCode = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Corporate Ladies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  static const _setupCompletedKey = 'app_setup_completed';
  bool _loading = true;
  bool _setupCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadSetupState();
  }

  Future<void> _loadSetupState() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_setupCompletedKey) ?? false;
    
    if (mounted) {
      setState(() {
        _setupCompleted = completed;
        _loading = false;
      });
    }

    // Perform background sync on app open if setup is done
    if (completed) {
      // Use microtask or future.delayed to ensure ProviderScope is ready
      Future.microtask(() {
        if (mounted) {
           final container = ProviderScope.containerOf(context);
           container.read(syncManagerProvider).syncAll();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_setupCompleted) {
      return SetupScreen(
        onCompleted: () {
          if (mounted) setState(() => _setupCompleted = true);
        },
      );
    }
    return const MainScreen();
  }
}
