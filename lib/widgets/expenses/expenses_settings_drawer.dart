import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ExpensesSettingsDrawer extends StatelessWidget {
  const ExpensesSettingsDrawer({
    super.key,
    required this.isDarkMode,
    required this.isFlipped,
    required this.onDarkModeChanged,
    required this.onFlipChanged,
    required this.onLanguageChanged,
  });

  final bool isDarkMode;
  final bool isFlipped;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onFlipChanged;
  final ValueChanged<Locale> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              'drawer_title'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SwitchListTile(
            value: isDarkMode,
            onChanged: onDarkModeChanged,
            title: Text('dark_mode'.tr()),
            secondary: const Icon(Icons.dark_mode),
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
            onTap: () => onLanguageChanged(const Locale('en')),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('lang_ar'.tr()),
            trailing: context.locale.languageCode == 'ar'
                ? const Icon(Icons.check)
                : null,
            onTap: () => onLanguageChanged(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}
