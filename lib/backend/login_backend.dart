import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/login_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginBackend {
  static Future<BackendReponse> login({required LoginForm form}) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        password: form.password,
        email: form.email,
      );

      return BackendReponse(
        success: response.session != null,
        payload: response.user,
      );
    } on AuthException catch (exception) {
      return BackendReponse(
        success: false,
        payload: exception.message,
      );
    }
  }

  static Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
