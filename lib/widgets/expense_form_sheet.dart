// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseFormSheet extends StatefulWidget {
  final ExpenseModel? expenseToEdit;

  const ExpenseFormSheet({super.key, this.expenseToEdit});

  @override
  State<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  final List<String> _categories = [
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
    final item = widget.expenseToEdit;
    _titleController = TextEditingController(text: item?.title ?? '');
    _amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');
    _selectedCategory = item?.category ?? _categories.first;

    // Default to today if new, or keep the existing date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _selectedDate = item?.date ?? today;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today, 
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.cobaltBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.navyBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save expenses.'),
          backgroundColor: AppColors.brightRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();

    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    final newExpense = ExpenseModel(
      id: widget.expenseToEdit?.id ?? '',
      userId: user.uid,
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      note: note.isNotEmpty ? note : null,
    );

    Navigator.pop(context);

    if (widget.expenseToEdit != null) {
      await expenseProvider.updateExpense(newExpense);
    } else {
      await expenseProvider.addExpense(newExpense);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.expenseToEdit != null
                        ? 'Edit Expense'
                        : 'Add New Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navyBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? Colors.white70 : AppColors.navyBlue,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                style: TextStyle(color: isDark ? Colors.white : AppColors.navyBlue),
                decoration: _cleanInputDecoration(
                  label: 'Title',
                  hint: 'Enter expense title',
                  isDark: isDark,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: isDark ? Colors.white : AppColors.navyBlue),
                decoration: _cleanInputDecoration(
                  label: 'Amount in Rs.',
                  hint: 'e.g. 1500.00',
                  isDark: isDark,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category Dropdown (NO ICONS)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.navyBlue,
                  fontSize: 15,
                ),
                decoration: _cleanInputDecoration(
                  label: 'Category',
                  hint: 'Select Category',
                  isDark: isDark,
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: _cleanInputDecoration(
                    label: 'Date',
                    hint: '',
                    isDark: isDark,
                  ),
                  child: Text(
                    DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.navyBlue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Optional Note Field (NO ICONS)
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : AppColors.navyBlue),
                decoration: _cleanInputDecoration(
                  label: 'Note / Description (Optional)',
                  hint: 'Enter note if any',
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 24),

              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobaltBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          widget.expenseToEdit != null
                              ? 'Update Expense'
                              : 'Save Expense',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _cleanInputDecoration({
    required String label,
    required String hint,
    required bool isDark,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: null, // NO ICONS
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : AppColors.navyBlue.withOpacity(0.7),
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : AppColors.navyBlue.withOpacity(0.35),
      ),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF1E293B)
          : AppColors.warmCream.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(
        color: AppColors.brightRed,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : AppColors.navyBlue.withOpacity(0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.cobaltBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brightRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brightRed, width: 2),
      ),
    );
  }
}