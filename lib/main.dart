import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/routes.dart';
import 'package:communal/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ievjxqrtftfnwzobklde.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlldmp4cXJ0ZnRmbnd6b2JrbGRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODI4MDYwNTIsImV4cCI6MTk5ODM4MjA1Mn0.45wNq5bt6JUHxJzTEiiKjngSHfLonG8gSXxhzt7Xl5c',
  );

  const loader = SvgAssetLoader('assets/crow.svg');
  svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kaits',
      theme: theme,
      onInit: () async {
        if (Supabase.instance.client.auth.currentUser != null) {
          Get.put(CommonDrawerController());
        }
      },
      getPages: routes,
      color: Theme.of(context).colorScheme.background,
      initialRoute:
          Supabase.instance.client.auth.currentUser == null ? RouteNames.startPage : RouteNames.communityListPage,
    );
  }
}
