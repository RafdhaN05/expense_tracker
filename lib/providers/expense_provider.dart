import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

/// ExpenseProvider manages the state of all expenses in memory.
/// Screens listen to this provider to automatically refresh when data changes.
class ExpenseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Internal state
  List<ExpenseModel> _allExpenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter & Search states
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _selectedCategory = 'All';
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  // Stream subscription to listen to Firestore
  StreamSubscription<List<ExpenseModel>>? _expenseSubscription;

  // --- GETTERS ---
  List<ExpenseModel> get allExpenses => _allExpenses;
  List<ExpenseModel> get expenses => _allExpenses; // Compatibility alias
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;
  String get selectedCategory => _selectedCategory;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  String get searchQuery => _searchQuery;

  /// START: Listen to real-time expense updates for the logged-in user
  void startListening(String userId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Cancel any previous listener
    _expenseSubscription?.cancel();

    _expenseSubscription = _firestoreService.getExpensesStream(userId).listen(
      (expensesList) {
        _allExpenses = expensesList;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners(); // Tells all screens to rebuild with new data!
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load expenses: ${error.toString()}';
        notifyListeners();
      },
    );
  }

  /// Compatibility method for manual loading
  Future<void> loadExpenses(String userId) async {
    startListening(userId);
  }

  // --- MONTHLY TOTAL CALCULATION (CyphLab Requirement) ---
  /// Calculates the total spending for the currently selected month
  double get currentMonthTotal {
    return _allExpenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // --- CATEGORY BREAKDOWN (For Summary & FlChart) ---
  /// Returns a map of category names to total amount spent in that category for this month
  Map<String, double> get categoryBreakdown {
    final Map<String, double> breakdown = {};

    final monthlyExpenses = _allExpenses.where((e) =>
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month);

    for (var expense in monthlyExpenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0.0) + expense.amount;
    }

    return breakdown;
  }

  // --- FILTERED EXPENSES LIST (Search & Filter requirement) ---
  /// Returns the expenses list filtered by search query, category, and date range
  List<ExpenseModel> get filteredExpenses {
    return _allExpenses.where((expense) {
      // 1. Search Query Filter (Title or Note contains text)
      final matchesSearch = _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.note != null &&
              expense.note!.toLowerCase().contains(_searchQuery.toLowerCase()));

      // 2. Category Filter
      final matchesCategory = _selectedCategory == 'All' ||
          expense.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 3. Date Range Filter (or falls in selected month if no custom range is picked)
      bool matchesDate;
      if (_selectedDateRange != null) {
        final start = _selectedDateRange!.start;
        // End of the selected end day (23:59:59)
        final end = _selectedDateRange!.end.add(const Duration(days: 1));
        matchesDate = expense.date.isAfter(start) && expense.date.isBefore(end);
      } else {
        matchesDate = expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month;
      }

      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  // --- FILTER ACTIONS ---
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    _selectedDateRange = null; // Reset custom date range when switching month
    notifyListeners();
  }

  void setSelectedDateRange(DateTimeRange? range) {
    _selectedDateRange = range;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- CRUD ACTIONS (WITH INSTANT OPTIMISTIC UI UPDATES) ---

  /// Adds an expense instantly to the local list and syncs to Firestore
  Future<bool> addExpense(ExpenseModel expense) async {
    // 1. Instant local update: Insert immediately so cards show up without delay
    _allExpenses.insert(0, expense);
    _allExpenses.sort((a, b) => b.date.compareTo(a.date));

    // Ensure selected month matches expense date so the card is immediately visible
    _selectedMonth = DateTime(expense.date.year, expense.date.month);
    notifyListeners(); // Instantly rebuilds UI!

    try {
      // 2. Sync with Firestore
      await _firestoreService.addExpense(expense);
      return true;
    } catch (e) {
      // Rollback on failure
      _allExpenses.removeWhere((item) =>
          item == expense ||
          (item.id.isNotEmpty && item.id == expense.id));
      _errorMessage = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Updates an expense instantly in memory and syncs to Firestore
  Future<bool> updateExpense(ExpenseModel expense) async {
    final index = _allExpenses.indexWhere((e) => e.id == expense.id);
    ExpenseModel? previousExpense;

    // 1. Instant local update
    if (index != -1) {
      previousExpense = _allExpenses[index];
      _allExpenses[index] = expense;
      _allExpenses.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners(); // Instantly rebuilds UI!
    }

    try {
      // 2. Sync with Firestore
      await _firestoreService.updateExpense(expense);
      return true;
    } catch (e) {
      // Rollback on failure
      if (index != -1 && previousExpense != null) {
        _allExpenses[index] = previousExpense;
        _allExpenses.sort((a, b) => b.date.compareTo(a.date));
      }
      _errorMessage = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  /// Deletes an expense instantly from memory and syncs to Firestore
  Future<bool> deleteExpense(String expenseId) async {
    final index = _allExpenses.indexWhere((e) => e.id == expenseId);
    ExpenseModel? removedExpense;

    // 1. Instant local removal
    if (index != -1) {
      removedExpense = _allExpenses[index];
      _allExpenses.removeAt(index);
      notifyListeners(); // Instantly rebuilds UI!
    }

    try {
      // 2. Sync with Firestore
      await _firestoreService.deleteExpense(expenseId);
      return true;
    } catch (e) {
      // Rollback on failure
      if (removedExpense != null) {
        _allExpenses.add(removedExpense);
        _allExpenses.sort((a, b) => b.date.compareTo(a.date));
      }
      _errorMessage = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}