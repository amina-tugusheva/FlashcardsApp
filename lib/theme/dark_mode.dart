import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    //background: Colors.green.shade900,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade900,
    

  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor:  Colors.grey[200],
    displayColor: Colors.white,
  ),
);