import 'package:expense_tracker/core/config/expense_handler.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  ExpensesNotifier() : super(const AsyncValue.loading()) {
    _loadExpenses();
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
    await ExpenseHandler.instance.insertExpense(expense);
    final currentExpenses = state.value ?? [];
    state = AsyncValue.data([...currentExpenses, expense]);
  }

  Future<void> removeExpense(Expense expense) async {
    await ExpenseHandler.instance.deleteExpense(expense.id);
    final currentExpenses = state.value ?? [];
    state = AsyncValue.data(
      currentExpenses.where((item) => item.id != expense.id).toList(),
    );
  }

  Future<void> restoreExpense(Expense expense, int index) async {
    await ExpenseHandler.instance.insertExpense(expense);
    final currentExpenses = [...(state.value ?? [])];
    if (index < 0 || index > currentExpenses.length) {
      currentExpenses.add(expense);
    } else {
      currentExpenses.insert(index, expense);
    }
    state = AsyncValue.data(currentExpenses);
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>(
  (ref) => ExpensesNotifier(),
);
