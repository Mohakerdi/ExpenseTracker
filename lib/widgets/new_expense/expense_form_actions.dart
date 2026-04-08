import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class ExpenseFormActions extends StatelessWidget {
  const ExpenseFormActions({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.localizedCategoryName,
    required this.onCancel,
    required this.onSubmit,
  });

  final Category selectedCategory;
  final ValueChanged<Category?> onCategoryChanged;
  final String Function(Category category) localizedCategoryName;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton(
          value: selectedCategory,
          items: Category.values
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(localizedCategoryName(category)),
                ),
              )
              .toList(),
          onChanged: onCategoryChanged,
        ),
        const Spacer(),
        TextButton(
          onPressed: onCancel,
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          child: Text('save_expense'.tr()),
        ),
      ],
    );
  }
}
