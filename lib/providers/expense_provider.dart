import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final _repository = ExpenseRepository();

  ExpenseNotifier() : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    final expenses = await _repository.getAll();
    state = expenses..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.save(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.save(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(Expense expense) async {
    await _repository.softDelete(expense);
    await loadExpenses();
  }

  Future<Expense?> getExpenseById(int id) async {
    final expenses = await _repository.getAll();
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<double> getTotalExpenses() async {
    final List<Expense> expenses = await _repository.getAll();
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  Future<double> getExpensesByCategory(ExpenseCategory category) async {
    final List<Expense> expenses = await _repository.getAll();
    double total = 0.0;
    for (var e in expenses) {
      if (e.category == category) {
        total += e.amount;
      }
    }
    return total;
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});
