import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppCategory represents an expense category with its display name, icon, and brand color.
class AppCategory {
  final String name;
  final IconData icon;
  final Color color;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  /// The list of available categories in PAWSE
  static const List<AppCategory> categories = [
    AppCategory(name: 'Food', icon: Icons.restaurant_rounded, color: AppColors.goldenYellow),
    AppCategory(name: 'Transport', icon: Icons.directions_car_rounded, color: AppColors.cobaltBlue),
    AppCategory(name: 'Bills', icon: Icons.receipt_long_rounded, color: AppColors.brightRed),
    AppCategory(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: AppColors.softPink),
    AppCategory(name: 'Entertainment', icon: Icons.movie_rounded, color: AppColors.cobaltBlue),
    AppCategory(name: 'Health', icon: Icons.medical_services_rounded, color: AppColors.goldenYellow),
    AppCategory(name: 'Other', icon: Icons.more_horiz_rounded, color: AppColors.navyBlue),
  ];

  /// Helper to find category info by name
  static AppCategory fromName(String name) {
    return categories.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const AppCategory(
        name: 'Other',
        icon: Icons.more_horiz_rounded,
        color: AppColors.navyBlue,
      ),
    );
  }
}