import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;

  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  factory AppConfig.fromEnvironment() {
    String readValue(String key) {
      // Prioritize --dart-define values
      if (key == 'SUPABASE_URL') {
        const envUrl = String.fromEnvironment('SUPABASE_URL');
        if (envUrl.isNotEmpty) return envUrl;
      }
      if (key == 'SUPABASE_ANON_KEY') {
        const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
        if (envAnonKey.isNotEmpty) return envAnonKey;
      }

      // Check system environment variables
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final platformEnv = Platform.environment[key];
        if (platformEnv != null && platformEnv.isNotEmpty) return platformEnv;
      }

      // Hardcoded defaults for your project
      if (key == 'SUPABASE_URL') {
        return 'https://cmczzswamnmdpjfulxjo.supabase.co';
      }
      if (key == 'SUPABASE_ANON_KEY') {
        return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNtY3p6c3dhbW5tZHBqZnVseGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5OTY3NzEsImV4cCI6MjA5MTU3Mjc3MX0.DwX9HNH1-p7IPL573wptJhCXy5539CIIon3I2jhix1A';
      }

      return '';
    }

    return AppConfig(
      supabaseUrl: readValue('SUPABASE_URL'),
      supabaseAnonKey: readValue('SUPABASE_ANON_KEY'),
    );
  }

  bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
