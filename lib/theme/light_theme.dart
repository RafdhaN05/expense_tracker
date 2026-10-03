import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.warmCream,
  primaryColor: AppColors.cobaltBlue,
  colorScheme: const ColorScheme.light(
    primary: AppColors.cobaltBlue,
    secondary: AppColors.goldenYellow,
    error: AppColors.brightRed,
    surface: Colors.white,
    onSurface: AppColors.navyBlue,
  ),

  
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.navyBlue),
    titleTextStyle: TextStyle(
      color: AppColors.navyBlue,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);