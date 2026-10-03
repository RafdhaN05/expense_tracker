import 'package:flutter/material.dart';
import '../models/expense_model.dart';

/// HistoryProvider manages the recently viewed transactions in memory.
class HistoryProvider with ChangeNotifier {
  // List holding the recently viewed expenses in memory
  final List<ExpenseModel> _viewedExpenses = [];

  // Getter to access the list safely
  List<ExpenseModel> get viewedExpenses => List.unmodifiable(_viewedExpenses);

  // Adds an expense when the user taps on it
  void addExpenseToHistory(ExpenseModel expense) {
    // If it was already visited earlier, remove old entry so it moves to top
    _viewedExpenses.removeWhere((item) => item.id == expense.id);

    // Insert at index 0 so newest visited appears first
    _viewedExpenses.insert(0, expense);
    notifyListeners();
  }

  // Removes a single item from the history
  void removeFromHistory(String expenseId) {
    _viewedExpenses.removeWhere((item) => item.id == expenseId);
    notifyListeners();
  }

  // Clears all history
  void clearHistory() {
    _viewedExpenses.clear();
    notifyListeners();
  }
}