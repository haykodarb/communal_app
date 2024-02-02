import 'package:communal/models/backend_response.dart';
import 'package:communal/models/login_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginBackend {
  static Future<BackendResponse> login({required LoginForm form}) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        password: form.password,
        email: form.email,
      );

      return BackendResponse(
        success: response.session != null,
        payload: response.user,
      );
    } on AuthException catch (exception) {
      return BackendResponse(
        success: false,
        payload: exception.message,
      );
    }
  }

  static Future<BackendResponse> sendRecoveryEmail(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://communal.ar/auth/recovery',
      );

      return BackendResponse(success: true, payload: 'Recovery email sent to $email');
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
