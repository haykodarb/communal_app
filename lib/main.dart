import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/dark_theme.dart';
import 'package:communal/localization.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/routes.dart';
import 'package:communal/light_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting();

  await Hive.initFlutter();

  String supabaseURL = 'https://ievjxqrtftfnwzobklde.supabase.co';
  String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlldmp4cXJ0ZnRmbnd6b2JrbGRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODI4MDYwNTIsImV4cCI6MTk5ODM4MjA1Mn0.45wNq5bt6JUHxJzTEiiKjngSHfLonG8gSXxhzt7Xl5c';

  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  const SvgAssetLoader loader = SvgAssetLoader('assets/crow.svg');

  svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    MyApp(
      themeMode: await UserPreferences.getSelectedThemeMode(),
      locale: await UserPreferences.getSelectedLocale(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kaits',
      theme: lightTheme,
      translations: LocalizationText(),
      scrollBehavior: const ScrollBehavior().copyWith(
        overscroll: false,
        physics: const ClampingScrollPhysics(),
      ),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      darkTheme: darkTheme,
      onInit: () async {
        if (Supabase.instance.client.auth.currentUser != null) {
          RealtimeBackend.subscribeToDatabaseChanges();

          Get.put(CommonDrawerController(), permanent: true);
        }
      },
      themeMode: themeMode,
      getPages: routes,
      color: Theme.of(context).colorScheme.surface,
      initialRoute:
          Supabase.instance.client.auth.currentUser == null ? RouteNames.startPage : RouteNames.communityListPage,
    );
  }
}
