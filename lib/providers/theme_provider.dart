import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  static final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: const Color.fromARGB(255, 32, 143, 167),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color.fromARGB(255, 11, 55, 94),
      elevation: 0,
    ),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Color.fromARGB(255, 11, 55, 94)),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 32, 143, 167),
      secondary: Color.fromARGB(255, 11, 55, 94),
      surface: Colors.white,
      background: Colors.white,
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: const Color.fromARGB(255, 32, 143, 167),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color.fromARGB(255, 32, 143, 167),
      elevation: 0,
    ),
    cardColor: const Color(0xFF1E1E1E),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Color.fromARGB(255, 32, 143, 167)),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 32, 143, 167),
      secondary: Color.fromARGB(255, 11, 55, 94),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
    ),
  );
}
