import 'dart:io';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_switch.dart';
import 'package:communal/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/start/start_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  static const List<Locale> _locales = [Locale('en', 'US'), Locale('es', 'ES')];

  Widget _dropdownLanguageButton(StartController controller) {
    return CommonSwitch(
      callback: () {
        if (Get.locale == _locales[0]) {
          UserPreferences.setSelectedLocale(_locales[1]);
          Get.updateLocale(_locales[1]);
        } else {
          UserPreferences.setSelectedLocale(_locales[0]);
          Get.updateLocale(_locales[0]);
        }
      },
      value: Get.locale == _locales[0],
      labels: const [
        "EN",
        "ES",
      ],
    );
  }

  Widget _changeThemeButton(StartController controller) {
    return Builder(
      builder: (context) {
        return CommonSwitch(
          value: !UserPreferences.isDarkMode(context),
          callback: () => controller.changeThemeMode(context),
          icons: const [Atlas.sunny_bold, Atlas.moon_bold],
        );
      },
    );
  }

  Widget _loginButton(StartController controller) {
    return CommonButton(
      type: CommonButtonType.outlined,
      onPressed: (BuildContext context) => context.push(
        RouteNames.startPage + RouteNames.loginPage,
      ),
      child: Text(
        'Login'.tr,
      ),
    );
  }

  Widget _registerButton(StartController controller) {
    return CommonButton(
      onPressed: (BuildContext context) => context.push(
        RouteNames.startPage + RouteNames.registerPage,
      ),
      child: Text(
        'Register'.tr,
      ),
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
              AutoSizeText(
                'Communal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
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
    return SafeArea(
    top: false,
      child: GetBuilder(
        init: StartController(context: context),
        initState: (state) async {
          try {
            Uri? uri = GoRouter.of(context).state?.uri;

            await UserPreferences.setWelcomeScreenShown(true);

            if (uri != null) {
              final AuthSessionUrlResponse response =
                  await Supabase.instance.client.auth.getSessionFromUrl(uri);

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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _dropdownLanguageButton(controller),
                            _changeThemeButton(controller),
                          ],
                        ),
                        const Divider(height: 10),
                        Expanded(
                          flex: 3,
                          child: _logo(),
                        ),
                        const Divider(height: 10),
                        Expanded(
                          flex: 2,
                          child: Obx(
                            () {
                              return CommonLoadingBody(
                                loading: controller.loading.value,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _loginButton(controller),
                                    const Divider(height: 10),
                                    _registerButton(controller),
                                    const Divider(height: 10),
                                    Visibility(
                                      visible: kIsWeb || Platform.isAndroid,
                                      child: CommonButton(
                                        onPressed: controller.signInWithGoogle,
                                        child: Text('Enter with Google'.tr),
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
      ),
    );
  }
}
