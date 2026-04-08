import 'package:expense_tracker/core/config/expense_handler.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]);

  Future<void> loadExpenses() async {
    final expenses = await ExpenseHandler.instance.getExpenses();
    state = expenses;
  }

  Future<void> addExpense(Expense expense) async {
    final currentExpenses = [...state];
    if (currentExpenses.any((item) => item.id == expense.id)) {
      return;
    }
    try {
      await ExpenseHandler.instance.insertExpense(expense);
      state = [...currentExpenses, expense];
    } catch (error) {
      debugPrint(
        'Failed to add expense "${expense.title}" (${expense.id}): $error',
      );
      state = currentExpenses;
    }
  }

  Future<void> removeExpense(Expense expense) async {
    final currentExpenses = [...state];
    try {
      await ExpenseHandler.instance.deleteExpense(expense.id);
      state = currentExpenses.where((item) => item.id != expense.id).toList();
    } catch (error) {
      debugPrint(
        'Failed to remove expense "${expense.title}" (${expense.id}): $error',
      );
      state = currentExpenses;
    }
  }

  Future<void> restoreExpense(Expense expense, int index) async {
    final currentExpenses = [...state];
    if (currentExpenses.any((item) => item.id == expense.id)) {
      return;
    }
    try {
      await ExpenseHandler.instance.insertExpense(expense);
      if (index < 0 || index > currentExpenses.length) {
        currentExpenses.add(expense);
      } else {
        currentExpenses.insert(index, expense);
      }
      state = currentExpenses;
    } catch (error) {
      debugPrint(
        'Failed to restore expense "${expense.title}" (${expense.id}): $error',
      );
      state = currentExpenses;
    }
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>(
  (ref) => ExpensesNotifier(),
);
