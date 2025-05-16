import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The ThemeProvider with ChangeNotifier
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// ChangeNotifierProvider for ThemeProvider
final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});
