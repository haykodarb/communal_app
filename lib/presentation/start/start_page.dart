import 'dart:io';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/start/start_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static const List<Locale> _locales = [Locale('en', 'US'), Locale('es', 'ES')];
  static const List<String> _languages = ['English', 'Español'];

  Widget _dropdownLanguageButton(StartController controller) {
    return Builder(
      builder: (context) {
        return Container(
          height: 60,
          width: 110,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: DropdownButton2(
            isExpanded: true,
            onChanged: controller.changeLanguage,
            dropdownStyleData: const DropdownStyleData(
              elevation: 0,
              offset: Offset(0, -5),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            buttonStyleData: const ButtonStyleData(
              overlayColor: WidgetStateColor.transparent,
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            alignment: Alignment.center,
            menuItemStyleData: const MenuItemStyleData(
              height: 60,
              padding: EdgeInsets.only(top: 5),
              overlayColor: WidgetStateColor.transparent,
            ),
            underline: const SizedBox.shrink(),
            iconStyleData: IconStyleData(
              iconSize: 30,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              openMenuIcon: Icon(
                Icons.keyboard_arrow_up,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            hint: Row(
              children: [
                Icon(
                  Atlas.language_translation_bold,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            items: _locales.mapIndexed(
              (index, element) {
                return DropdownMenuItem<Locale>(
                  value: element,
                  child: Container(
                    width: double.maxFinite,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        _languages[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }

  Widget _changeThemeButton(StartController controller) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 60,
          width: 110,
          child: OutlinedButton(
            onPressed: () => controller.changeThemeMode(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: UserPreferences.isDarkMode(context)
                          ? Colors.transparent
                          : Theme.of(context).colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Atlas.sunny,
                      size: 22,
                      color: UserPreferences.isDarkMode(context)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: UserPreferences.isDarkMode(context)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Atlas.moon,
                      size: 22,
                      color: UserPreferences.isDarkMode(context)
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _loginButton(StartController controller) {
    return Builder(
      builder: (context) {
        return ElevatedButton(
          onPressed: () => context.push(
            RouteNames.startPage + RouteNames.loginPage,
          ),
          child: Text(
            'Login'.tr,
          ),
        );
      },
    );
  }

  Widget _registerButton(StartController controller) {
    return Builder(
      builder: (context) {
        return OutlinedButton(
          onPressed: () => context.push(
            RouteNames.startPage + RouteNames.registerPage,
          ),
          child: Text(
            'Register'.tr,
          ),
        );
      },
    );
  }

  Widget _logo() {
    return Builder(builder: (context) {
      final LinearGradient gradient = LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.tertiary,
        ],
      );

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SvgPicture.asset(
                  'assets/crow.svg',
                  fit: BoxFit.contain,
                ),
              ),
              FittedBox(
                child: Text(
                  'Communal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: StartController(context: context),
      initState: (state) async {
        try {
          Uri? uri = GoRouter.of(context).state?.uri;

          await UserPreferences.setWelcomeScreenShown(true);

          if (uri != null) {
            final AuthSessionUrlResponse response = await Supabase.instance.client.auth.getSessionFromUrl(uri);

            if (response.session.accessToken.isNotEmpty) {
              if (context.mounted) {
                GoRouter.of(context).go(RouteNames.communityListPage);
              }
            }
          }
        } on AuthException catch (_) {
          return;
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      },
      builder: (StartController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),
                child: SizedBox(
                  width: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _dropdownLanguageButton(controller),
                          _changeThemeButton(controller),
                        ],
                      ),
                      Flexible(
                        flex: 2,
                        child: _logo(),
                      ),
                      const Divider(height: 10),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () {
                            return CommonLoadingBody(
                              loading: controller.loading.value,
                              child: Column(
                                children: [
                                  _loginButton(controller),
                                  const Divider(height: 10),
                                  _registerButton(controller),
                                  const Divider(height: 10),
                                  Visibility(
                                    visible: kIsWeb || Platform.isAndroid,
                                    child: OutlinedButton(
                                      onPressed: () => controller.signInWithGoogle(context),
                                      child: Text('Sign in with Google'.tr),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
