import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2563EB),
    onPrimary: Colors.white,
    secondary: Color(0xFF8B5CF6),
    onSecondary: Colors.white,
    error: Color(0xFFEF4444),
    onError: Colors.white,
    background: Color(0xFFF8FAFC),
    onBackground: Color(0xFF1E293B),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1E293B),
    outline: Color(0xFFE2E8F0),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0F172A),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF60A5FA),
    onPrimary: Colors.white,
    secondary: Color(0xFFA78BFA),
    onSecondary: Colors.white,
    error: Color(0xFFF87171),
    onError: Colors.white,
    background: Color(0xFF0F172A),
    onBackground: Color(0xFFF1F5F9),
    surface: Color(0xFF1E293B),
    onSurface: Color(0xFFF1F5F9),
    outline: Color(0xFF334155),
  ),
);