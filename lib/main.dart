import 'dart:io' show Platform;

import 'package:communal/backend/firebase_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/dark_theme.dart';
import 'package:communal/firebase_options.dart';
import 'package:communal/light_theme.dart';
import 'package:communal/localization.dart';
import 'package:communal/presentation/common/common_toast.dart';
import 'package:communal/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

bool get _isFirebaseSupported => kIsWeb || Platform.isAndroid || Platform.isIOS;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isFirebaseSupported) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  initializeDateFormatting();

  await Hive.initFlutter();

  // const String supabaseURL = 'https://supabase.communal.ar';
  const String supabaseURL = 'https://ddqyylvlywedqjuoqqlh.supabase.co';
  const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRkcXl5bHZseXdlZHFqdW9xcWxoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE0ODIwMjcsImV4cCI6MjEwNzA1ODAyN30.kL-5X4VMLZhFv1eijuNXx3Tr4eZ79MuuyhUrWk8O_LI';

  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  const SvgAssetLoader loader = SvgAssetLoader('assets/crow.svg');

  svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));

  GoRouter.optionURLReflectsImperativeAPIs = true;

  final bool welcomeShown = await UserPreferences.getWelcomeScreenShown();

  final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: GlobalKey<NavigatorState>(),
    routes: routes,
    onException: (_, GoRouterState state, GoRouter router) {
      if (Supabase.instance.client.auth.currentUser != null) {
        router.go(RouteNames.homePage);
      } else {
        router.go(RouteNames.startPage);
      }
    },
    initialLocation: Supabase.instance.client.auth.currentUser == null
        ? (welcomeShown ? RouteNames.startPage : RouteNames.landingPage)
        : RouteNames.homePage,
  );

  if (_isFirebaseSupported) {
    await FirebaseBackend.firebaseInit(router);
  }

  runApp(
    MyApp(
      themeMode: await UserPreferences.getSelectedThemeMode(),
      locale: await UserPreferences.getSelectedLocale(),
      router: router,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  final Locale locale;
  final GoRouter router;
  const MyApp({
    super.key,
    required this.themeMode,
    required this.locale,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Communal',
      theme: lightTheme,
      translations: LocalizationText(),
      smartManagement: SmartManagement.full,
      scrollBehavior: const ScrollBehavior().copyWith(
        overscroll: false,
        physics: const ClampingScrollPhysics(),
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      darkTheme: darkTheme,
      themeMode: themeMode,
      color: Theme.of(context).colorScheme.surface,
      builder: (context, child) {
        return CommonToastHost(child: child!);
      },
    );
  }
}
