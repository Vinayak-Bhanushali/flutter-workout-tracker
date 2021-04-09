import 'package:flutter/material.dart';

class Themes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    accentColor: Colors.indigo,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    accentColor: Colors.indigo,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
