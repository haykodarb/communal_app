import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserPreferences {
  static Future<ThemeMode> getSelectedThemeMode() async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    final bool? isDarkMode = box.get('isDarkMode');

    if (isDarkMode == null) {
      return ThemeMode.system;
    }

    await box.close();

    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setSelectedThemeMode(ThemeMode themeMode) async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    await box.put('isDarkMode', themeMode == ThemeMode.dark);

    await box.close();
  }

  static Future<Locale> getSelectedLocale() async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    final String? locale_lang = box.get('locale_lang');
    final String? locale_country = box.get('locale_country');

    if (locale_lang == null || locale_country == null) return const Locale('en', 'US');

    await box.close();

    return Locale(locale_lang, locale_country);
  }

  static Future<void> setSelectedLocale(Locale newLocale) async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    await box.put('locale_lang', newLocale.languageCode);
    await box.put('locale_country', newLocale.countryCode);

    await box.close();
  }
}
