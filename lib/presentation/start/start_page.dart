import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biblioteca/presentation/start/start_controller.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);

  final StartController _startController = StartController();

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _startController.loginButtonCallback,
      child: const Text(
        'Login',
      ),
    );
  }

  Widget _registerButton() {
    return OutlinedButton(
      onPressed: _startController.registerButtonCallback,
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
      init: _startController,
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
                    child: Center(child: _loginButton()),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(child: _registerButton()),
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
