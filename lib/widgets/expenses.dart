import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';

class Expenses extends ConsumerWidget {
  const Expenses({super.key});

  void _openAddExpenseOverlay(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: (expense) {
          ref.read(expensesProvider.notifier).addExpense(expense);
        },
      ),
    );
  }

  void _removeExpense(
    BuildContext context,
    WidgetRef ref,
    List<Expense> expenses,
    Expense expense,
  ) {
    final expenseIndex = expenses.indexOf(expense);
    ref.read(expensesProvider.notifier).removeExpense(expense);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref
                .read(expensesProvider.notifier)
                .restoreExpense(expense, expenseIndex);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    if (expensesAsync.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (expensesAsync.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter ExpenseTracker'),
        ),
        body: const Center(
          child: Text('Failed to load expenses.'),
        ),
      );
    }

    final expenses = expensesAsync.value ?? [];

    Widget mainContent = const Center(
      child: Text('No expenses found. Start adding some!'),
    );

    if (expenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: expenses,
        onRemoveExpense: (expense) =>
            _removeExpense(context, ref, expenses, expense),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ExpenseTracker'),
        actions: [
          IconButton(
            onPressed: () => _openAddExpenseOverlay(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Chart(expenses: expenses),
          Expanded(
            child: mainContent,
          ),
        ],
      ),
    );
  }
}
