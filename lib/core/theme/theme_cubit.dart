import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(isDarkMode: false)) {
    _loadTheme();
  }

  // Load saved theme preference
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool('isDarkMode') ?? false;
      emit(ThemeState(isDarkMode: savedTheme));
    } catch (e) {
      // If error, use default (light theme)
      emit(const ThemeState(isDarkMode: false));
    }
  }

  // Save theme preference
  Future<void> _saveTheme(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    final newTheme = !state.isDarkMode;
    emit(ThemeState(isDarkMode: newTheme));
    await _saveTheme(newTheme);
  }

  // Set theme explicitly
  Future<void> setTheme(bool isDarkMode) async {
    emit(ThemeState(isDarkMode: isDarkMode));
    await _saveTheme(isDarkMode);
  }
}