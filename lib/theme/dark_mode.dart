import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// ThemeData darkMode = ThemeData(
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme.dark(
//     //background: Colors.green.shade900,
//     primary: Colors.grey.shade600,
//     secondary: Colors.grey.shade800,
//     inversePrimary: Colors.grey.shade900,
    

//   ),
//   textTheme: ThemeData.dark().textTheme.apply(
//     bodyColor:  Colors.grey[200],
//     displayColor: Colors.white,
//   ),
// );

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color.fromARGB(255, 41, 29, 63), 
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 132, 132, 158),      
    secondary: Color.fromARGB(255, 43, 43, 61),   
    tertiary: Color.fromARGB(255, 85, 83, 106),     
    surface: Color(0xFF0D1B2A),      // фон
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFFE8F5E8),    // текст
  ),
  
  // // Шрифты 
  // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
  //   bodyColor: Color(0xFFE8F5E8),
  //   displayColor: Colors.white,
  //   bodySmall: GoogleFonts.inter(color: Color(0xFFB0BEC5)),
  //   bodyMedium: GoogleFonts.inter(),
  //   bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
  //   titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
  //   titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
  //   titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold),
  //   headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
  //   headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w800),
  //   headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900),
  // ),

// ШРИФТЫ с кастомными настройками
  textTheme: ThemeData.dark().textTheme.copyWith(
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFFB0BEC5),
      letterSpacing: 0.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
    ),
  ).apply(
    // Цвета применяются ко всем остальным стилям
    bodyColor: Color(0xFFE8F5E8),
    displayColor: Colors.white,
  ),

  // Стили для карточек и кнопок
  cardTheme: CardTheme(
    // color: Color.fromARGB(255, 30, 36, 45), // фон карточек
    color: Color.fromARGB(255, 38, 43, 66),
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    shadowColor: Color.fromARGB(255, 17, 17, 18).withOpacity(0.5),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 53, 49, 80),
      // backgroundColor: Color.fromARGB(255, 58, 50, 107),
      foregroundColor: Colors.white,
      elevation: 6,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 4, 23, 42),
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: Color.fromARGB(255, 0, 0, 0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    )),
  ),
  tabBarTheme: TabBarTheme(
  indicatorColor: const Color.fromARGB(255, 189, 186, 199),           // Полоска снизу
  labelColor: const Color.fromARGB(255, 204, 202, 211),               // Активный текст
  unselectedLabelColor: const Color.fromARGB(255, 97, 103, 118),  // Неактивный
  indicator: UnderlineTabIndicator(         // Кастом полоска
    borderSide: BorderSide(width: 3, color:const Color.fromARGB(255, 204, 202, 211)),
  ),
),
bottomNavigationBarTheme: BottomNavigationBarThemeData(
  selectedItemColor: Color.fromARGB(255, 255, 255, 255),            // Активная иконка/текст

),
  
  scaffoldBackgroundColor: Color(0xFF0A1929),
);
