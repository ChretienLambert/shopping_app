import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/isar_service.dart';
import 'services/logging_service.dart';
import 'screens/main_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Logging Service
  await logger.init();

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

  await Supabase.initialize(
    url: 'https://cmczzswamnmdpjfulxjo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtY3p6c3dhbW5tZHBqZnVseGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5OTY3NzEsImV4cCI6MjA5MTU3Mjc3MX0.DwX9HNH1-p7IPL573wptJhCXy5539CIIon3I2jhix1A',
  );

  await IsarService.instance.init();
  runApp(const ProviderScope(child: MyApp()));
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
    setState(() {
      _setupCompleted = prefs.getBool(_setupCompletedKey) ?? false;
      _loading = false;
    });
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
