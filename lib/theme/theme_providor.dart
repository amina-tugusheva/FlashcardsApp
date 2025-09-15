import 'package:coursework/theme/dark_mode.dart';
import 'package:coursework/theme/light_mode.dart';
import 'package:flutter/material.dart'; 

class ThemeProvidor with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
  void toggletheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}