// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'add_expense_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      DashboardScreen(
        onViewExpenses: () {
          setState(() => _currentIndex = 1);
        },
      ),
      const AddExpenseScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],

      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Dashboard Tab
            _buildNavItem(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              isDark: isDark,
            ),

            // 2. Add Tab
            GestureDetector(
              onTap: () {
                setState(() => _currentIndex = 1);
                AddExpenseScreen.openForm(context);
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? AppColors.goldenYellow : AppColors.cobaltBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cobaltBlue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: _currentIndex == 1 ? AppColors.navyBlue : Colors.white,
                ),
              ),
            ),

            // 3. History Tab
            _buildNavItem(
              index: 2,
              icon: Icons.receipt_long_rounded,
              label: 'History',
              isDark: isDark,
            ),

            // 4. Profile Tab
            _buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: 'Profile',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final unselectedColor = isDark ? Colors.white38 : AppColors.navyBlue.withOpacity(0.35);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? AppColors.cobaltBlue : unselectedColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.cobaltBlue : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}