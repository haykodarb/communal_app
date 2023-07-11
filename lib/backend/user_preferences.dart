import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserPreferences {
  static Future<ThemeMode> getSelectedThemeMode() async {
    final Box box = await Hive.openBox<bool>('preferences');

    final bool? isDarkMode = box.get('isDarkMode');

    if (isDarkMode == null) {
      return ThemeMode.system;
    }

    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setSelectedThemeMode(ThemeMode themeMode) async {
    final Box box = await Hive.openBox<bool>('preferences');

    box.put('isDarkMode', themeMode == ThemeMode.dark);
  }
}
