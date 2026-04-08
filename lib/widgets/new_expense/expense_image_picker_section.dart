import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseImagePickerSection extends StatelessWidget {
  const ExpenseImagePickerSection({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final File? selectedImage;
  final ValueChanged<ImageSource> onPickImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedImage == null)
            Text('no_image_selected_optional'.tr())
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                selectedImage!,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => onPickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: Text('camera'.tr()),
              ),
              OutlinedButton.icon(
                onPressed: () => onPickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text('gallery'.tr()),
              ),
              if (selectedImage != null)
                TextButton(
                  onPressed: onRemoveImage,
                  child: Text('remove'.tr()),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
