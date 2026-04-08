import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({
    super.key,
    required this.isDarkMode,
    required this.isFlipped,
    required this.onDarkModeChanged,
    required this.onFlipChanged,
  });

  final bool isDarkMode;
  final bool isFlipped;
  final void Function(bool value) onDarkModeChanged;
  final void Function(bool value) onFlipChanged;

  @override
  ConsumerState<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends ConsumerState<Expenses> {
  var _isLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      await ref.read(expensesProvider.notifier).loadExpenses();
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadingError = null;
      });
    } catch (error) {
      debugPrint('Failed to load expenses in UI: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _loadingError = 'unable_load_expenses';
      });
    }
  }

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

  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
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
        content: Text('expense_deleted'.tr()),
        action: SnackBarAction(
          label: 'undo'.tr(),
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
    final expenses = ref.watch(expensesProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_loadingError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('app_title'.tr()),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('unable_load_expenses'.tr()),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadExpenses,
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    Widget mainContent = const Center(
      child: SizedBox(),
    );

    if (expenses.isEmpty) {
      mainContent = Center(
        child: Text('no_expenses_found'.tr()),
      );
    } else {
      mainContent = ExpensesList(
        expenses: expenses,
        onRemoveExpense: (expense) =>
            _removeExpense(context, ref, expenses, expense),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          IconButton(
            onPressed: () => _openAddExpenseOverlay(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'drawer_title'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            SwitchListTile(
              value: widget.isDarkMode,
              onChanged: widget.onDarkModeChanged,
              title: Text('dark_mode'.tr()),
              secondary: const Icon(Icons.dark_mode),
            ),
            SwitchListTile(
              value: widget.isFlipped,
              onChanged: widget.onFlipChanged,
              title: Text('flip_layout'.tr()),
              secondary: const Icon(Icons.flip),
            ),
            const Divider(),
            ListTile(
              title: Text('language'.tr()),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('lang_en'.tr()),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => _changeLanguage(context, const Locale('en')),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('lang_ar'.tr()),
              trailing: context.locale.languageCode == 'ar'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => _changeLanguage(context, const Locale('ar')),
            ),
          ],
        ),
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
