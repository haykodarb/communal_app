import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:communal/presentation/start/start_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:collection/collection.dart';

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
            onPressed: controller.changeThemeMode,
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
          onPressed: () => context.go(RouteNames.loginPage),
          child: Text(
            'login'.tr,
          ),
        );
      },
    );
  }

  Widget _registerButton(StartController controller) {
    return Builder(
      builder: (context) {
        return OutlinedButton(
          onPressed: () => context.go(RouteNames.registerPage),
          child: Text(
            'register'.tr,
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: StartController(),
      builder: (StartController controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 30,
              ),
              child: SafeArea(
                child: SizedBox(
                  width: 600,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _dropdownLanguageButton(controller),
                          _changeThemeButton(controller),
                        ],
                      ),
                      const Divider(height: 20),
                      _logo(),
                      const Divider(height: 20),
                      _loginButton(controller),
                      const Divider(height: 10),
                      _registerButton(controller),
                      const Expanded(child: SizedBox()),
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
