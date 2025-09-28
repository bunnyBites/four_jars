import 'package:flutter/material.dart';

class AppTheme {
  // --- Light Theme ---
  static final ThemeData lightTheme =
      ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ).copyWith(
        // Customize specific widget themes
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004D40), // A darker teal for the app bar
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal[700],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  // --- Dark Theme ---
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
