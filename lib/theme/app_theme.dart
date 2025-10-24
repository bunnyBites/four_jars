import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFFC1E1C1);
  static const Color _darkSeedColor = Color(0xFF53AC53);

  // light mode
  static final ThemeData lightTheme =
      ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          primary: _darkSeedColor,
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ).copyWith(
        // customize specific widget themes
        appBarTheme: const AppBarTheme(
          backgroundColor: _seedColor,
          foregroundColor: Colors.black,
        ),
        cardTheme: CardThemeData(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _seedColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  // dark mode
  static final ThemeData darkTheme =
      ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ).copyWith(
        // Customize specific widget themes for dark mode
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFF121212,
          ), // A very dark color for the app bar
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 4.0,
          color: Colors.grey[850], // Slightly lighter than the background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.teal[400],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
