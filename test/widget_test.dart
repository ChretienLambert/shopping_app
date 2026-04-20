// Widget test for Shopping App
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_app/main.dart';
import 'package:shopping_app/providers/auth_provider.dart';
import 'package:shopping_app/services/app_config.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(supabaseUrl: '', supabaseAnonKey: ''),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Verify app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
