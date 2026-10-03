import 'package:cloud_firestore/cloud_firestore.dart';

/// The ExpenseModel represents a single financial transaction.
/// It supports both Expenses and Income, with all fields requested by CyphLab.
class ExpenseModel {
  final String id;          // Firestore document ID (used to edit or delete)
  final String userId;      // ID of the user who owns this transaction
  final String title;       // e.g. "Salary" or "Grocery"
  final double amount;      // e.g. 150.00
  final String category;    // e.g. "Food", "Salary", "Bills"
  final DateTime date;      // Date of the transaction
  final String? note;       // Optional description
  final bool isIncome;      // TRUE = Income (+), FALSE = Expense (-)

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.isIncome = false,  // Defaults to Expense
  });

  /// CONVERT: Dart Object -> Firebase Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note ?? '',
      'isIncome': isIncome,
    };
  }

  /// CONVERT: Firebase Map (JSON) -> Dart Object
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'],
      isIncome: map['isIncome'] ?? false, // Defaults to false if not found
    );
  }

  /// HELPER: Creates a copy with updated fields (used for editing)
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    bool? isIncome,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}