import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/models/expense.dart';

class ExpensePrimaryFields extends StatelessWidget {
  const ExpensePrimaryFields({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.selectedDate,
    required this.onPickDate,
  });

  final TextEditingController titleController;
  final TextEditingController amountController;
  final DateTime? selectedDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: titleController,
          maxLength: 50,
          decoration: InputDecoration(label: Text('title'.tr())),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  label: Text('amount'.tr()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    selectedDate == null
                        ? 'no_date_selected'.tr()
                        : formatter.format(selectedDate!),
                  ),
                  IconButton(
                    onPressed: onPickDate,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
