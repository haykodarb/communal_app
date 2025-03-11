import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserPreferences {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Future<bool> getWelcomeScreenShown() async {
    try {
      final Box box = await Hive.openBox<dynamic>('preferences');

      final bool? welcomeShown = box.get('welcomeShown');

      if (welcomeShown == null) {
        return false;
      }

      await box.close();

      return welcomeShown;
    } catch (e) {
      return false;
    }
  }

  static Future<void> setWelcomeScreenShown(bool value) async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    await box.put('welcomeShown', value);

    await box.close();
  }

  static Future<ThemeMode> getSelectedThemeMode() async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    final bool? isDarkMode = box.get('isDarkMode');

    if (isDarkMode == null) {
      return ThemeMode.light;
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

    if (locale_lang == null || locale_country == null) {
      return const Locale('en', 'US');
    }

    await box.close();

    return Locale(locale_lang, locale_country);
  }

  static Future<void> setSelectedLocale(Locale newLocale) async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    await box.put('locale_lang', newLocale.languageCode);
    await box.put('locale_country', newLocale.countryCode);

    await box.close();
  }

  static Future<List<String>> getPinnedCommunitiesIds() async {
    final Box box = await Hive.openBox<dynamic>('preferences');
    final List<dynamic>? pinned_communities = box.get('pinned_communities') as List<dynamic>?;

    await box.close();

    if (pinned_communities == null) return <String>[];

    final List<String> formatted_list = pinned_communities.map((e) => e as String).toList();

    return formatted_list;
  }

  static Future<void> setPinnedCommunityValue(String id, bool shouldPin) async {
    final Box box = await Hive.openBox<dynamic>('preferences');

    List<dynamic>? pinned_communities = box.get('pinned_communities');

    if (pinned_communities == null) {
      pinned_communities = [];
      await box.put('pinned_communities', []);
    }

    final bool exists = pinned_communities.any((element) => element == id);

    if (exists && shouldPin) {
      await box.close();
      return;
    }

    if (shouldPin && !exists) {
      pinned_communities.add(id);
    }

    if (exists && !shouldPin) {
      pinned_communities.remove(id);
    }

    await box.put('pinned_communities', pinned_communities);

    await box.close();
  }
}
