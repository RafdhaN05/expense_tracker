import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesCollection.add(expense.toMap());
  }

  Stream<List<ExpenseModel>> getExpensesStream(String userId) {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Sort in memory by date descending (newest first)
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

 
  Future<void> updateExpense(ExpenseModel expense) async {
    await _expensesCollection.doc(expense.id).update(expense.toMap());
  }

  
  Future<void> deleteExpense(String expenseId) async {
    await _expensesCollection.doc(expenseId).delete();
  }
}