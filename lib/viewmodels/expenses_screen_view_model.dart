import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expenses_provider.dart';

@immutable
class ExpensesScreenState {
  const ExpensesScreenState({
    required this.isLoading,
    required this.hasLoadingError,
  });

  final bool isLoading;
  final bool hasLoadingError;

  ExpensesScreenState copyWith({
    bool? isLoading,
    bool? hasLoadingError,
  }) {
    return ExpensesScreenState(
      isLoading: isLoading ?? this.isLoading,
      hasLoadingError: hasLoadingError ?? this.hasLoadingError,
    );
  }
}

class ExpensesScreenViewModel extends StateNotifier<ExpensesScreenState> {
  ExpensesScreenViewModel(this._ref)
      : super(
          const ExpensesScreenState(
            isLoading: true,
            hasLoadingError: false,
          ),
        );

  final Ref _ref;

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, hasLoadingError: false);
    final expensesNotifier = _ref.read(expensesProvider.notifier);
    try {
      await expensesNotifier.loadExpenses();
      state = state.copyWith(isLoading: false, hasLoadingError: false);
    } catch (error) {
      debugPrint('Failed to load expenses in view model: $error');
      state = state.copyWith(isLoading: false, hasLoadingError: true);
    }
  }

  Future<void> addExpense(Expense expense) async {
    await _ref.read(expensesProvider.notifier).addExpense(expense);
  }

  Future<void> removeExpense(Expense expense) async {
    await _ref.read(expensesProvider.notifier).removeExpense(expense);
  }

  Future<void> restoreExpense(Expense expense, int index) async {
    await _ref.read(expensesProvider.notifier).restoreExpense(expense, index);
  }
}

final expensesScreenProvider =
    StateNotifierProvider<ExpensesScreenViewModel, ExpensesScreenState>(
  (ref) => ExpensesScreenViewModel(ref),
);
