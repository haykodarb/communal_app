import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/start/start_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  Widget _loginButton(StartController controller) {
    return ElevatedButton(
      onPressed: controller.loginButtonCallback,
      child: const Text(
        'Login',
      ),
    );
  }

  Widget _registerButton(StartController controller) {
    return OutlinedButton(
      onPressed: controller.registerButtonCallback,
      child: const Text(
        'Register',
      ),
    );
  }

  Widget _logo() {
    final BuildContext context = Get.context!;

    final LinearGradient gradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.tertiary,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 50,
      ),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/crow.svg',
              height: 300,
            ),
            Text(
              'Communal',
              textAlign: TextAlign.center,
              style: GoogleFonts.russoOne(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: StartController(),
      builder: (StartController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 50,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          final ThemeMode newThemeMode = Get.isDarkMode ? ThemeMode.light : ThemeMode.dark;

                          Get.changeThemeMode(newThemeMode);

                          UserPreferences.setSelectedThemeMode(newThemeMode);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(
                                Get.isDarkMode ? Atlas.moon : Atlas.sunny,
                              ),
                              const VerticalDivider(),
                              Text(Get.isDarkMode ? 'Light Theme' : 'Dark Theme'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _logo(),
                  const Divider(height: 30),
                  _loginButton(controller),
                  const Divider(height: 30),
                  _registerButton(controller),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
