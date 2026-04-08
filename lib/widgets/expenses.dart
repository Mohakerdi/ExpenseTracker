import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:expense_tracker/viewmodels/app_settings_view_model.dart';
import 'package:expense_tracker/viewmodels/expenses_screen_view_model.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/expenses/expenses_settings_drawer.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expensesScreenProvider.notifier).loadExpenses();
    });
  }

  void _openAddExpenseOverlay(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: (expense) {
          ref.read(expensesScreenProvider.notifier).addExpense(expense);
        },
      ),
    );
  }

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
  }

  void _removeExpense(
    BuildContext context,
    List<Expense> expenses,
    Expense expense,
  ) {
    final expenseIndex = expenses.indexOf(expense);
    ref.read(expensesScreenProvider.notifier).removeExpense(expense);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Text('expense_deleted'.tr()),
          action: SnackBarAction(
            label: 'undo'.tr(),
            onPressed: () {
              ref
                  .read(expensesScreenProvider.notifier)
                  .restoreExpense(expense, expenseIndex);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final screenState = ref.watch(expensesScreenProvider);
    final appSettings = ref.watch(appSettingsProvider);

    if (screenState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (screenState.hasLoadingError) {
      return Scaffold(
        appBar: AppBar(title: Text('app_title'.tr())),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('unable_load_expenses'.tr()),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(expensesScreenProvider.notifier).loadExpenses(),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    final Widget mainContent = expenses.isEmpty
        ? Center(child: Text('no_expenses_found'.tr()))
        : ExpensesList(
            expenses: expenses,
            onRemoveExpense: (expense) =>
                _removeExpense(context, expenses, expense),
          );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpenseOverlay(context),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('app_title'.tr())),
      drawer: ExpensesSettingsDrawer(
        isDarkMode: appSettings.themeMode == ThemeMode.dark,
        isFlipped: appSettings.isFlipped,
        onDarkModeChanged: ref.read(appSettingsProvider.notifier).setDarkMode,
        onFlipChanged: ref.read(appSettingsProvider.notifier).setFlipped,
        onLanguageChanged: (locale) => _changeLanguage(context, locale),
      ),
      body: Column(
        children: [
          Chart(expenses: expenses),
          Expanded(child: mainContent),
        ],
      ),
    );
  }
}
