// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/expense_model.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;

  // Opens the date picker to filter viewed transactions
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final allViewed = historyProvider.viewedExpenses;

    final List<ExpenseModel> displayedExpenses = _selectedDate == null
        ? allViewed
        : allViewed.where((e) {
            return e.date.year == _selectedDate!.year &&
                e.date.month == _selectedDate!.month &&
                e.date.day == _selectedDate!.day;
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.warmCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.navyBlue,
                    ),
                  ),

                  if (allViewed.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        historyProvider.clearHistory();
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: AppColors.brightRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.navyBlue,
                      side: BorderSide(
                        color: _selectedDate != null
                            ? AppColors.cobaltBlue
                            : (isDark ? Colors.white24 : AppColors.navyBlue.withOpacity(0.2)),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () => _pickDate(context),
                    icon: Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: _selectedDate != null
                          ? AppColors.cobaltBlue
                          : (isDark ? Colors.white70 : AppColors.navyBlue),
                    ),
                    label: Text(
                      _selectedDate == null
                          ? 'Filter by Date'
                          : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _selectedDate != null
                            ? AppColors.cobaltBlue
                            : (isDark ? Colors.white : AppColors.navyBlue),
                      ),
                    ),
                  ),

                  if (_selectedDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white70 : AppColors.navyBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: displayedExpenses.isEmpty
                  ? Center(
                      child: Text(
                        _selectedDate == null
                            ? 'No recently viewed transactions.'
                            : 'No visited transactions on this date.',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white54 : AppColors.navyBlue.withOpacity(0.5),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: displayedExpenses.length,
                      separatorBuilder: (context, index) => Divider(
                        color: isDark ? Colors.white12 : AppColors.navyBlue.withOpacity(0.1),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final expense = displayedExpenses[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Row(
                            children: [
                              // Title and Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppColors.navyBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(expense.date),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white54 : AppColors.navyBlue.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                'Rs. ${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.navyBlue,
                                ),
                              ),

                              const SizedBox(width: 12),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.brightRed,
                                  size: 20,
                                ),
                                onPressed: () {
                                  historyProvider.removeFromHistory(expense.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}