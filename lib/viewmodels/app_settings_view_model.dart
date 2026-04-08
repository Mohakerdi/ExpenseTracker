import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppSettingsState {
  const AppSettingsState({
    required this.themeMode,
    required this.isFlipped,
  });

  final ThemeMode themeMode;
  final bool isFlipped;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? isFlipped,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }
}

class AppSettingsViewModel extends StateNotifier<AppSettingsState> {
  AppSettingsViewModel()
      : super(
          const AppSettingsState(
            themeMode: ThemeMode.system,
            isFlipped: false,
          ),
        );

  void setDarkMode(bool isEnabled) {
    state = state.copyWith(
      themeMode: isEnabled ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void setFlipped(bool isEnabled) {
    state = state.copyWith(isFlipped: isEnabled);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsViewModel, AppSettingsState>(
  (ref) => AppSettingsViewModel(),
);
