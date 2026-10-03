// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_form_sheet.dart';


class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  
  static void openForm(BuildContext context, [ExpenseModel? expenseToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormSheet(expenseToEdit: expenseToEdit),
    );
  }

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final List<String> _filterCategories = [
    'All',
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Provider.of<ExpenseProvider>(context, listen: false).startListening(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    final expenses = expenseProvider.filteredExpenses;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.warmCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Expenses',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.navyBlue,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TextField(
                onChanged: (val) => expenseProvider.setSearchQuery(val.trim()),
                style: TextStyle(color: isDark ? Colors.white : AppColors.navyBlue),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.cobaltBlue),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                itemCount: _filterCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _filterCategories[index];
                  final isSelected = expenseProvider.selectedCategory.toLowerCase() == cat.toLowerCase();

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.cobaltBlue,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.navyBlue),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.cobaltBlue
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                      ),
                    ),
                    onSelected: (_) => expenseProvider.setSelectedCategory(cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: expenseProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.cobaltBlue),
                    )
                  : expenses.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses found',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final item = expenses[index];
                            return ExpenseCard(
                              expense: item,
                              onTap: () {
                               
                                historyProvider.addExpenseToHistory(item);

                              
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Viewed "${item.title}"Saved to History'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.cobaltBlue,
                                  ),
                                );
                              },
                              onEdit: () {
                                AddExpenseScreen.openForm(context, item);
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Expense'),
                                    content: Text('Delete "${item.title}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: AppColors.brightRed),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await expenseProvider.deleteExpense(item.id);
                                }
                              },
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