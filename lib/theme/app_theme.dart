import 'package:flutter/material.dart';

class AppTheme {
  // Brand Gradients (Indigo/Blue Standard)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB), // blue-600
      Color(0xFF1E40AF), // blue-800
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // blue-500
      Color(0xFF60A5FA), // blue-400
    ],
  );
  
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Layout Colors
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  static const Color primary = primaryBlue;
  static const Color accent = accentBlue;
  static const Color primaryForeground = Colors.white;
  
  static const Color secondary = slate100;
  static const Color secondaryForeground = slate900;
  
  static const Color muted = slate100;
  static const Color mutedForeground = slate500;
  
  static const Color accentForeground = primaryBlue;
  
  static const Color logoGradientSecondary = accentBlue;
  
  static const LinearGradient logoGradient = primaryGradient;
  static const Color destructive = Color(0xFFEF4444); // red-500
  static const Color destructiveForeground = Colors.white;
  
  static const Color border = slate200;
  static const Color inputBackground = slate50;
  static const Color switchBackground = slate300;
  
  static const Color card = Colors.white;
  static const Color cardForeground = slate900;
  
  static const Color background = slate50;
  static const Color foreground = slate900;
  
  static const Color sidebar = Colors.white;
  static const Color sidebarForeground = slate600;
  static const Color sidebarPrimary = primaryBlue;
  static const Color sidebarPrimaryForeground = Colors.white;
  static const Color sidebarAccent = slate50;
  static const Color sidebarAccentForeground = slate900;
  static const Color sidebarBorder = slate200;
  
  // Charts
  static const Color chart1 = Color(0xFF3B82F6); // Blue
  static const Color chart2 = Color(0xFF8B5CF6); // Violet
  static const Color chart3 = Color(0xFFEC4899); // Pink
  static const Color chart4 = Color(0xFFF59E0B); // Amber
  static const Color chart5 = Color(0xFF10B981); // Emerald
  
  // Spacing & Radiology
  static const double radius = 12.0; 
  static const double radiusSm = 8.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  
  static const double paddingXs = 8.0;
  static const double paddingSm = 12.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 20.0;
  static const double paddingXl = 24.0;

  static const String _fontFamily = 'Inter'; // Prefer Inter if available, defaults gracefully

  static TextTheme _buildTextTheme(Color baseColor, Color mutedColor) {
    return TextTheme(
      displayLarge: TextStyle(color: baseColor, fontSize: 57, fontWeight: FontWeight.normal, fontFamily: _fontFamily),
      displayMedium: TextStyle(color: baseColor, fontSize: 45, fontWeight: FontWeight.normal, fontFamily: _fontFamily),
      displaySmall: TextStyle(color: baseColor, fontSize: 36, fontWeight: FontWeight.normal, fontFamily: _fontFamily),
      headlineLarge: TextStyle(color: baseColor, fontSize: 32, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
      headlineMedium: TextStyle(color: baseColor, fontSize: 28, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
      headlineSmall: TextStyle(color: baseColor, fontSize: 24, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
      titleLarge: TextStyle(color: baseColor, fontSize: 22, fontWeight: FontWeight.w600, fontFamily: _fontFamily),
      titleMedium: TextStyle(color: baseColor, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: _fontFamily),
      titleSmall: TextStyle(color: baseColor, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: _fontFamily),
      bodyLarge: TextStyle(color: baseColor, fontSize: 16, fontWeight: FontWeight.normal, fontFamily: _fontFamily),
      bodyMedium: TextStyle(color: baseColor, fontSize: 14, fontWeight: FontWeight.normal, fontFamily: _fontFamily),
      bodySmall: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.normal, fontFamily: _fontFamily),
      labelLarge: TextStyle(color: baseColor, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: _fontFamily),
      labelMedium: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: _fontFamily),
      labelSmall: TextStyle(color: mutedColor, fontSize: 11, fontWeight: FontWeight.w500, fontFamily: _fontFamily),
    );
  }
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: Color(0xFFEFF6FF), // blue-50
        onSecondary: primaryBlue,
        error: destructive,
        onError: destructiveForeground,
        surface: Colors.white,
        onSurface: slate900,
        outline: border,
      ),
      scaffoldBackgroundColor: slate50,
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate900,
        elevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: border, width: 1)),
        titleTextStyle: TextStyle(
          color: slate900,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: _fontFamily,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: slate400),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryBlue.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: _fontFamily);
          }
          return const TextStyle(color: slate500, fontSize: 12, fontFamily: _fontFamily);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBlue);
          }
          return const IconThemeData(color: slate500);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: slate500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: _buildTextTheme(slate900, slate500),
      chipTheme: ChipThemeData(
        backgroundColor: slate100,
        selectedColor: primaryBlue,
        labelStyle: const TextStyle(color: slate900, fontFamily: _fontFamily),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: slate900,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: _fontFamily),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Dark Theme
  static const Color darkBg = slate950;
  static const Color darkCard = slate900;
  static const Color darkBorder = slate800;
  static const Color darkForeground = slate50;
  static const Color darkMutedForeground = slate400;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: Color(0xFF1E3A8A), // blue-900
        onSecondary: Colors.white,
        error: destructive,
        onError: Colors.white,
        surface: darkBg,
        onSurface: darkForeground,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkForeground,
        elevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: darkBorder, width: 1)),
        titleTextStyle: TextStyle(
          color: darkForeground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: _fontFamily,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: slate900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: darkMutedForeground),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: primaryBlue.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12, fontFamily: _fontFamily);
          }
          return const TextStyle(color: darkMutedForeground, fontSize: 12, fontFamily: _fontFamily);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: darkMutedForeground);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: primaryBlue,
        unselectedItemColor: darkMutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: _buildTextTheme(darkForeground, darkMutedForeground),
      chipTheme: ChipThemeData(
        backgroundColor: darkBorder,
        selectedColor: primaryBlue,
        labelStyle: const TextStyle(color: darkForeground, fontFamily: _fontFamily),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkForeground,
        contentTextStyle: const TextStyle(color: darkBg, fontFamily: _fontFamily),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
