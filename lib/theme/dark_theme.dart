import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep rich dark navy
  primaryColor: AppColors.cobaltBlue,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.cobaltBlue,
    secondary: AppColors.goldenYellow,
    error: AppColors.brightRed,
    surface: Color(0xFF1E293B), // Elevated dark card surface
    onSurface: Colors.white,
  ),


  cardTheme: CardThemeData(
    color: const Color(0xFF1E293B),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);