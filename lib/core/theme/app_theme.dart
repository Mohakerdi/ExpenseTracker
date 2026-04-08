import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_colors.dart';

final lightColorScheme = ColorScheme.fromSeed(seedColor: appLightSeedColor);
final darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: appDarkSeedColor,
);

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData().copyWith(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: lightColorScheme.onPrimaryContainer,
        foregroundColor: lightColorScheme.primaryContainer,
      ),
      cardTheme: const CardThemeData().copyWith(
        color: lightColorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primaryContainer,
        ),
      ),
      textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: lightColorScheme.onSecondaryContainer,
              fontSize: 16,
            ),
          ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      cardTheme: const CardThemeData().copyWith(
        color: darkColorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primaryContainer,
          foregroundColor: darkColorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
