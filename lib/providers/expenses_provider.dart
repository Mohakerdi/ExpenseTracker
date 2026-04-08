import 'package:expense_tracker/core/config/expense_handler.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  ExpensesNotifier() : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> reloadExpenses() async {
    state = const AsyncValue.loading();
    await _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await ExpenseHandler.instance.getExpenses();
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addExpense(Expense expense) async {
    final currentExpenses = state.value ?? [];
    if (currentExpenses.any((item) => item.id == expense.id)) {
      return;
    }
    try {
      await ExpenseHandler.instance.insertExpense(expense);
      state = AsyncValue.data([...currentExpenses, expense]);
    } catch (error) {
      debugPrint(
        'Failed to add expense "${expense.title}" (${expense.id}): $error',
      );
      state = AsyncValue.data(currentExpenses);
    }
  }

  Future<void> removeExpense(Expense expense) async {
    final currentExpenses = state.value ?? [];
    try {
      await ExpenseHandler.instance.deleteExpense(expense.id);
      state = AsyncValue.data(
        currentExpenses.where((item) => item.id != expense.id).toList(),
      );
    } catch (error) {
      debugPrint(
        'Failed to remove expense "${expense.title}" (${expense.id}): $error',
      );
      state = AsyncValue.data(currentExpenses);
    }
  }

  Future<void> restoreExpense(Expense expense, int index) async {
    final currentExpenses = [...(state.value ?? [])];
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
      state = AsyncValue.data(currentExpenses);
    } catch (error) {
      debugPrint(
        'Failed to restore expense "${expense.title}" (${expense.id}): $error',
      );
      state = AsyncValue.data(currentExpenses);
    }
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>(
  (ref) => ExpensesNotifier(),
);
