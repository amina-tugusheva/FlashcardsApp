import 'package:coursework/theme/dark_mode.dart';
import 'package:coursework/theme/light_mode.dart';
import 'package:flutter/material.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvidor with ChangeNotifier {
  ThemeData _themeData = lightMode;
  static const String _themeKey = 'is_dark_theme';  //  Ключ сохранения!


  ThemeData get themeData => _themeData;

  ThemeProvidor() {
    _loadTheme();  //  Загрузка при старте!
  }

  //  Загрузка сохранённой темы
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;  // false = light
    
    _themeData = isDark ? darkMode : lightMode;
    notifyListeners();
  }
  Future<void> toggletheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_themeData == lightMode) {
      _themeData = darkMode;
      await prefs.setBool(_themeKey, true);  //  Сохраняем!
    } else {
      _themeData = lightMode;
      await prefs.setBool(_themeKey, false); //  Сохраняем!
    }
    
    notifyListeners();
  }

  //  Метод для проверки текущей темы
  bool get isDark => _themeData == darkMode;

  // set themeData(ThemeData themeData) {
  //   _themeData = themeData;
  //   notifyListeners();
  // }
  // void toggletheme() {
  //   if (_themeData == lightMode) {
  //     themeData = darkMode;
  //   } else {
  //     themeData = lightMode;
  //   }
  // }
}