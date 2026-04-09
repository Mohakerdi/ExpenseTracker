import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/new_expense/expense_form_actions.dart';
import 'package:expense_tracker/widgets/new_expense/expense_image_picker_section.dart';
import 'package:expense_tracker/widgets/new_expense/expense_primary_fields.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  @override
  void initState() {
    super.initState();
    _retrieveLostData(); // Call this when the widget loads
  }

  Future<void> _retrieveLostData() async {
    // retrieveLostData is specifically for Android
    if (Platform.isAndroid) {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      if (response.file != null) {
        final imageBytes = await _compressImageBytesIfPossible(response.file!);
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedImageData = imageBytes;
        });
      } else {
        // Handle the error if necessary
        print(response.exception);
      }
    }
  }

  static const _compressedImageMaxDimension = 1080;
  static const _compressedImageQuality = 75;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _picker = ImagePicker();

  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;
  Uint8List? _selectedImageData;

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('invalid_input_title'.tr()),
          content: Text('invalid_input_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('okay'.tr()),
            ),
          ],
        ),
      );
      return;
    }

    widget.onAddExpense(
      Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        imageData: _selectedImageData,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );

      if (pickedImage == null) {
        return;
      }

      final imageBytes = await _compressImageBytesIfPossible(pickedImage);

      if (!mounted) {
        return;
      }
      setState(() {
        _selectedImageData = imageBytes;
      });
    } on PlatformException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('image_permission_required'.tr()),
          ),
        );
    }
  }

  Future<Uint8List> _compressImageBytesIfPossible(XFile image) async {
    final originalBytes = await image.readAsBytes();

    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: _compressedImageMaxDimension,
        minHeight: _compressedImageMaxDimension,
        quality: _compressedImageQuality,
        keepExif: true,
      );

      return compressedBytes.isNotEmpty ? compressedBytes : originalBytes;
    } catch (_) {
      return originalBytes;
    }
  }

  String _localizedCategoryName(Category category) {
    switch (category) {
      case Category.food:
        return 'food'.tr();
      case Category.travel:
        return 'travel'.tr();
      case Category.leisure:
        return 'leisure'.tr();
      case Category.work:
        return 'work'.tr();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          48,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            ExpensePrimaryFields(
              titleController: _titleController,
              amountController: _amountController,
              selectedDate: _selectedDate,
              onPickDate: _presentDatePicker,
            ),
            const SizedBox(height: 16),
            ExpenseImagePickerSection(
              selectedImageData: _selectedImageData,
              onPickImage: _pickImage,
              onRemoveImage: () {
                setState(() {
                  _selectedImageData = null;
                });
              },
            ),
            const SizedBox(height: 16),
            ExpenseFormActions(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedCategory = value;
                });
              },
              localizedCategoryName: _localizedCategoryName,
              onCancel: () => Navigator.pop(context),
              onSubmit: _submitExpenseData,
            ),
          ],
        ),
      ),
    );
  }
}
