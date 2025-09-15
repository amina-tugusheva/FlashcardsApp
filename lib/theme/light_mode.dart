import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    //background: Colors.blueGrey.shade100,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade100,
    inversePrimary: Colors.grey.shade600,
    

  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor:  Colors.grey[900],
    displayColor: Colors.black,
  ),
);