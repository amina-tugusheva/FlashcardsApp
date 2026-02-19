import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//   brightness: Brightness.light,
//   colorScheme: ColorScheme.light(
//     //background: Colors.blueGrey.shade100,
//     primary: Colors.grey.shade800,
//     secondary: Colors.grey.shade100,
//     inversePrimary: Colors.grey.shade600,
    

//   ),
//   textTheme: ThemeData.light().textTheme.apply(
//     bodyColor:  Colors.grey[900],
//     displayColor: Colors.black,
//   ),
// );

// import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  

  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF83F29B), // Мятный зеленый
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 76, 108, 77),      // Основной зеленый
    secondary: Color.fromARGB(255, 234, 247, 234),    // Светло-зеленый
    tertiary: Color.fromARGB(255, 73, 119, 75),     // Средний зеленый
    surface: Color(0xFFF8FDF9),      // Очень светлый фон
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color.fromARGB(255, 28, 59, 30),    // Темно-зеленый текст
  ),
  
  // // шрифты Google Fonts
  // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
  //   bodyColor: Color(0xFF2E7D32),
  //   displayColor: Color(0xFF1B5E20),
  //   bodySmall: GoogleFonts.inter(),
  //   bodyMedium: GoogleFonts.inter(),
  //   bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
  //   titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
  //   titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
  //   titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold),
  //   headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w700),
  //   headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w800),
  //   headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900),
  // ),

  // СИСТЕМНЫЕ ШРИФТЫ 
  textTheme: ThemeData.light().textTheme.copyWith(
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF2E7D32), // Темно-зеленый для мелкого текста
      letterSpacing: 0.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: Color(0xFF1B5E20),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: Color.fromARGB(255, 54, 88, 56),
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: Color(0xFF1B5E20),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: Color.fromARGB(255, 109, 126, 111),
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Color(0xFF1B5E20),
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: Color(0xFF1B5E20),
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: Color(0xFF1B5E20),
    ),
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
      color: Color(0xFF1B5E20),
    ),
  ).apply(
    // Глобальные цвета для остальных стилей
    bodyColor: Color(0xFF1B5E20),
    displayColor: Color.fromARGB(255, 37, 61, 38),
  ),

  // Стили для карточек и кнопок
  cardTheme: CardTheme(
    color: Color(0xFFF1F8E9), // Мятный фон карточек
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    shadowColor: Color(0xFF81C784).withOpacity(0.3),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 75, 109, 76),
      foregroundColor: Colors.white,
      elevation: 4,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
  
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 60, 83, 61),
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: Color.fromARGB(255, 99, 134, 101),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    )),
  ),
  
  scaffoldBackgroundColor: Color(0xFFF8FDF9),
);
