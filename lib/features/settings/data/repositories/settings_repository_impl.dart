import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._preferences);

  static const _themeModeKey = 'settings.theme_mode';
  static const _localeKey = 'settings.locale';

  final SharedPreferences _preferences;

  @override
  ThemeMode getThemeMode() {
    final value = _preferences.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return _preferences.setString(_themeModeKey, mode.name);
  }

  @override
  Locale? getLocale() {
    final value = _preferences.getString(_localeKey);
    if (value == null) return null;
    return Locale(value);
  }

  @override
  Future<void> setLocale(Locale? locale) {
    if (locale == null) {
      return _preferences.remove(_localeKey);
    }
    return _preferences.setString(_localeKey, locale.languageCode);
  }
}
