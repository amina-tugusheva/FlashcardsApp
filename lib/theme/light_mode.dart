import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  

  colorScheme: ColorScheme.fromSeed(
    seedColor: Color.fromARGB(255, 74, 71, 138), //
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 76, 77, 108),      // Основной
    secondary: Color.fromARGB(255, 154, 156, 193),    // Светло
    tertiary: Color.fromARGB(255, 144, 149, 183),     // Средний 
    surface: Color.fromARGB(255, 248, 249, 253),      // Очень светлый фон
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color.fromARGB(255, 31, 28, 59),    // текст
  ),

  // СИСТЕМНЫЕ ШРИФТЫ 
  textTheme: ThemeData.light().textTheme.copyWith(
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color.fromARGB(255, 46, 47, 125), // для мелкого текста
      letterSpacing: 0.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Color.fromARGB(255, 27, 35, 94),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Color.fromARGB(255, 54, 55, 88),
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Color.fromARGB(255, 27, 35, 94),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Color.fromARGB(255, 170, 172, 181),
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Color.fromARGB(255, 27, 36, 94),
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Color.fromARGB(255, 27, 37, 94),
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: Color.fromARGB(255, 27, 37, 94),
    ),
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
      color: Color.fromARGB(255, 27, 45, 94),
    ),
  ).apply(
    // Глобальные цвета для остальных стилей
    bodyColor: Color.fromARGB(255, 27, 43, 94),
    displayColor: Color.fromARGB(255, 38, 37, 61),
  ),

  // Стили для карточек и кнопок
  cardTheme: CardTheme(
    color: Color.fromARGB(255, 233, 237, 248), // Мятный фон карточек
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    shadowColor: Color.fromARGB(255, 129, 130, 199).withOpacity(0.3),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 75, 78, 109),
      foregroundColor: Colors.white,
      elevation: 4,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 60, 61, 83),
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: Color.fromARGB(255, 99, 101, 134),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    )),
  ),

  tabBarTheme: TabBarTheme(
  indicatorColor: const Color.fromARGB(255, 189, 186, 199),           // Полоска снизу
  labelColor: Colors.white,               // Активный текст
  unselectedLabelColor: const Color.fromARGB(255, 153, 156, 164),  // Неактивный
  indicator: UnderlineTabIndicator(         // Кастом полоска
    borderSide: BorderSide(width: 3, color: Colors.white),
  ),
),
  
  scaffoldBackgroundColor: Color.fromARGB(255, 248, 248, 253),
);
