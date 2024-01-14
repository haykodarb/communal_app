import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/dark_theme.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/routes.dart';
import 'package:communal/light_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ievjxqrtftfnwzobklde.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlldmp4cXJ0ZnRmbnd6b2JrbGRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODI4MDYwNTIsImV4cCI6MTk5ODM4MjA1Mn0.45wNq5bt6JUHxJzTEiiKjngSHfLonG8gSXxhzt7Xl5c',
  );

  const SvgAssetLoader loader = SvgAssetLoader('assets/crow.svg');

  svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    MyApp(
      themeMode: await UserPreferences.getSelectedThemeMode(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeMode,
  });

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kaits',
      theme: lightTheme,
      darkTheme: darkTheme,
      onInit: () async {
        if (Supabase.instance.client.auth.currentUser != null) {
          Get.put(CommonDrawerController());

          await RealtimeBackend.subscribeToDatabaseChanges();
          await UsersBackend.updateCurrentUserProfile();
        }
      },
      themeMode: themeMode,
      getPages: routes,
      color: Theme.of(context).colorScheme.background,
      initialRoute:
          Supabase.instance.client.auth.currentUser == null ? RouteNames.startPage : RouteNames.communityListPage,
    );
  }
}
