import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biblioteca/presentation/start/start_controller.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

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

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 50,
        ),
        child: Text(
          'Pequeña Biblioteca',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                  Expanded(
                    flex: 3,
                    child: _logo(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(child: _loginButton(controller)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(child: _registerButton(controller)),
                  ),
                  const Expanded(
                    flex: 3,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
