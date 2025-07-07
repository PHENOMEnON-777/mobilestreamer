import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  primaryColor: Colors.white,
  fontFamily: 'Lato',
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Colors.blue,
    secondary: Colors.orange, 
    onSurface: Colors.black,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    secondaryFixed: Colors.black,
  ),
  secondaryHeaderColor: Color.fromARGB(255, 128, 189, 232),
  // Override Material 3 defaults to prevent purple colors
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
    ),
  ),
);

ThemeData darkmode = ThemeData(
  primaryColor: Colors.white,
  fontFamily: 'Lato',
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    surface: Color.fromARGB(255, 2, 13, 35),
    primary: Colors.blue,
    secondary: Colors.orange,
    onSurface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    secondaryFixed: Colors.white,
  ),
      secondaryHeaderColor: Color.fromARGB(255, 10, 29, 67),
  // Override Material 3 defaults to prevent purple colors
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
    ),
  ),
);