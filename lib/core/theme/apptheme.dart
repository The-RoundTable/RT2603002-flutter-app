import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF080C14),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00D4FF),
        secondary: Color(0xFF00D4FF),
        surface: Color(0xFF0D1521),
        error: Colors.redAccent,
      ),
      useMaterial3: true,
    );
  }
}