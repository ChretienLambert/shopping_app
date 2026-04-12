import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/isar_service.dart';
import 'services/seed_data.dart';
import 'services/logging_service.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

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
  await SeedDataService.seedDummyData();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'ShopTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
